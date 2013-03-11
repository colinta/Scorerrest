class TallySetupController < UIViewController
  PlayersSection = 0
  SubmitSection = 1
    SaveRow = 0
    StartGameRow = 1
    ResetRow = 2

  stylesheet :tally_setup

  def init
    super.tap do
      setHidesBottomBarWhenPushed(true)
      # stores names and "order", which is assigned when you touch a row
      @players = Player.players.map { |p| {'name' => p['name'], 'order' => nil} }
      @game_save = true
      @next_player_order = 1
    end
  end

  layout :root do
    @table_view = subview(UITableView.grouped, :table,
      dataSource: self,
      delegate: self
      )
  end

  def start_game
    players = @players.select{|player| player['order']}           # only select ordered
                      .sort{|a,b| a['order'] <=> b['order']}      # in the order selected
                      .map{|player| {'name' => player['name'] } } # and only include the name

    game = TallyGame.new
    game.players = players
    game.save = @game_save

    started = NSDateFormatter.localizedStringFromDate(NSDate.date, dateStyle:NSDateFormatterMediumStyle, timeStyle:NSDateFormatterShortStyle)
    game.name = "Tally – #{started}"

    if game.players.empty?
      game.players << {'name' => nil}
      game.subtitle = 'One player'
    else
      player_names = game.players.map{|p| p['name'] }
      last_player = player_names.pop
      if player_names.empty?
        players = last_player
      else
        players = player_names.join(', ') + ' and ' + last_player
      end
      game.subtitle = players
    end

    if game.save
      Game << game
    end

    tally_controller = TallyGameController.alloc.initWithGame(game)
    # create list of controllers that doesn't include the current controller
    ctlrs = self.navigationController.viewControllers[0...-1]
    ctlrs << tally_controller
    self.navigationController.setViewControllers(ctlrs, animated:true)
  end

  def tableView(table_view, cellForRowAtIndexPath:index_path)
    case index_path
    when IndexPath[PlayersSection]
      identifier = 'Tally-PlayerRow'
      cell = table_view.dequeueReusableCellWithIdentifier(identifier) ||
             UITableViewCell.alloc.initWithStyle(:value1.uitablecellstyle, reuseIdentifier: identifier)

      cell.textLabel.text = @players[index_path.row]['name']
      cell.detailTextLabel.text = (@players[index_path.row]['order'] || "").to_s

    when IndexPath[SubmitSection, SaveRow]
      identifier = 'Tally-SaveRow'
      cell = table_view.dequeueReusableCellWithIdentifier(identifier) ||
             UITableViewCell.alloc.initWithStyle(:default.uitablecellstyle, reuseIdentifier: identifier).tap do |cell|
                cell.textLabel.text = 'Save?'
                switch = UISwitch.new
                switch.on = @game_save
                switch.on :changed do
                  @game_save = switch.on?
                end

                cell.accessoryView = switch
                cell.selectionStyle = :none.uitablecellselectionstyle
             end

    when IndexPath[SubmitSection, StartGameRow]
      identifier = 'Tally-StartGameRow'
      cell = table_view.dequeueReusableCellWithIdentifier(identifier) ||
             UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: identifier)

      cell.accessoryType = :disclosure.uitablecellaccessory
      cell.textLabel.text = 'Start Game'

    when IndexPath[SubmitSection, ResetRow]
      identifier = 'Tally-ResetRow'
      cell = table_view.dequeueReusableCellWithIdentifier(identifier) ||
             UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: identifier)

      cell.textLabel.text = 'Reset Players'
      cell.accessoryType = :none.uitablecellaccessory
    else
      cell = nil
    end

    return cell
  end

  def numberOfSectionsInTableView(table_view)
    2
  end

  def tableView(table_view, titleForHeaderInSection:section)
    if section == 0
      'Choose players:'
    else
      nil
    end
  end

  def tableView(table_view, numberOfRowsInSection:section)
    case section
    when PlayersSection
      @players.length
    else
      3
    end
  end

  def tableView(table_view, didSelectRowAtIndexPath:index_path)
    table_view.deselectRowAtIndexPath(index_path, animated:true)

    case index_path
    when IndexPath[PlayersSection]
      choose_player(index_path.row)

    when IndexPath[SubmitSection, StartGameRow]
      start_game

    when IndexPath[SubmitSection, ResetRow]
      reset_players
    end
  end

  def viewDidLoad
    super
    self.title = "Tally"

    self.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(
        UIBarButtonSystemItemAdd,
        target: self,
        action: :add_player)
  end

  ##|
  ##|  ADD PLAYER
  ##|  this is duplicate code from PlayerManagerController :-/
  ##|
  def reset_players
    @players.each { |player| player['order'] = nil }
    @next_player_order = 1
    @table_view.reloadData
  end

  def choose_player(player_row)
    if @players[player_row]['order']
      old_chosen = @players[player_row]['order']
      @players[player_row]['order'] = nil

      row_updates = []
      row_updates << [0, player_row].nsindexpath
      @players.each_with_index do |player, index|
        if player['order'] && player['order'] > old_chosen
          player['order'] -= 1
          row_updates << [0, index].nsindexpath
        end
      end
      @next_player_order -= 1
      @table_view.reloadRowsAtIndexPaths(row_updates,
                       withRowAnimation: :automatic.uitablerowanimation)
    else
      @players[player_row]['order'] = @next_player_order
      @next_player_order += 1
      @table_view.reloadRowsAtIndexPaths([[PlayersSection, player_row].nsindexpath],
                       withRowAnimation: :automatic.uitablerowanimation)
    end
  end

  def add_player
    self.add_player_controller.player = nil

    # create and customize the navigation controller.  This gives us an easy
    # place to put the "Cancel" and "Done" buttons, and a "New Player" title.
    ctlr = UINavigationController.alloc.initWithRootViewController(self.add_player_controller)
    ctlr.modalTransitionStyle = UIModalTransitionStyleCoverVertical
    ctlr.delegate = self

    self.presentViewController(ctlr, animated:true, completion:nil)
  end

  def cancel_add_player
    self.dismissViewControllerAnimated(true, completion:nil)
  end

  def done_add_player
    if player = self.add_player_controller.player
      @players << {'name' => player['name'], 'order' => @next_player_order}
      @next_player_order += 1

      Player << player
      PlayersChangedNotification.post_notification

      index_path = [0, @players.length - 1].nsindexpath
      @table_view.insertRowsAtIndexPaths([index_path], withRowAnimation: :left.uitablerowanimation)
    end

    self.dismissViewControllerAnimated(true, completion:nil)
  end

  def player_editor_should_return(ctlr)
    self.done_add_player
  end

  def add_player_controller
    @add_player_controller ||= EditPlayerController.new.tap do |ctlr|
        ctlr.delegate = self

        ctlr.navigationItem.leftBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(
            UIBarButtonSystemItemCancel,
            target: self,
            action: :cancel_add_player)

        ctlr.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(
            UIBarButtonSystemItemDone,
            target: self,
            action: :done_add_player)

        ctlr.navigationItem.rightBarButtonItem.enabled = false
    end
  end

end
