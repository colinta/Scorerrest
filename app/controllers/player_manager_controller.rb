
class PlayerManagerController < UIViewController

  stylesheet :player_manager

  def init
    self.tabBarItem = UITabBarItem.alloc.initWithTitle(
        "Players",
        image:"tabbar_mainmenu".uiimage,
        tag:1)
    super
  end

  layout :root do
    @table_view = subview(UITableView.plain, :table,
      dataSource: self,
      delegate: self
      )
  end

  def viewDidLoad
    super

    self.title = "Players"

    self.navigationItem.leftBarButtonItem = self.editButtonItem
    self.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(
        UIBarButtonSystemItemAdd,
        target: self,
        action: :addPlayer)

    NSNotificationCenter.defaultCenter.addObserver(self,
        selector: :playersChanged,
        name: PlayersChangedNotification,
        object: nil)
  end

  def viewWillDisappear(is_animated)
    super

    setEditing(false, animated:false)
    @table_view.setEditing(false, animated:false)
  end

  def viewWillUnload
    NSNotificationCenter.defaultCenter.removeObserver(self)
    super
  end

  def tableView(table_view, cellForRowAtIndexPath:index_path)
    cell = table_view.dequeueReusableCellWithIdentifier(cell_identifier) ||
          UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault,
                              reuseIdentifier:cell_identifier)
    cell.textLabel.text = Player.players[index_path.row]['name']
    cell.accessoryType = :disclosure.uitablecellaccessory

    return cell
  end

  def tableView(table_view, numberOfRowsInSection: section)
    case section
    when 0
      Player.players.length
    else
      0
    end
  end

  def tableView(table_view, didSelectRowAtIndexPath:index_path)
    table_view.deselectRowAtIndexPath(index_path, animated:true)

    self.edit_player_controller.player = Player.players[index_path.row]

    self.navigationController.delegate = self.edit_player_controller
    self.navigationController << self.edit_player_controller
  end

  def playersChanged(reload=true)
    if reload
      @table_view.reloadData
    end
  end

  def addPlayer
    self.add_player_controller.player = nil

    # create and customize the navigation controller.  This gives us an easy
    # place to put the "Cancel" and "Done" buttons, and a "New Player" title.
    ctlr = UINavigationController.alloc.initWithRootViewController(self.add_player_controller)
    ctlr.modalTransitionStyle = UIModalTransitionStyleCoverVertical
    ctlr.delegate = self

    self.presentViewController(ctlr, animated:true, completion:nil)
  end

  def cancelAddPlayer
    self.dismissViewControllerAnimated(true, completion:nil)
  end

  def doneAddPlayer
    if self.add_player_controller.player
      Player << self.add_player_controller.player
      self.playersChanged
    end
    self.dismissViewControllerAnimated(true, completion:nil)
  end

  def player_editor_should_return(ctlr)
    if ctlr == self.add_player_controller
      self.doneAddPlayer
    else
      self.navigationController.pop(self)
    end
  end

  ##|
  ##|  EDITING TABLE
  ##|
  def tableView(table_view, commitEditingStyle:editing_style, forRowAtIndexPath:index_path)
    if editing_style == UITableViewCellEditingStyleDelete
      Player.players.delete_at(index_path.row)
      @table_view.deleteRowsAtIndexPaths([index_path], withRowAnimation:UITableViewRowAnimationAutomatic)
      self.playersChanged(false)
    end
  end

  def tableView(table_view, moveRowAtIndexPath:from_index_path, toIndexPath:to_index_path)
    @move = Player.players[from_index_path.row]
    Player.players.delete_at(from_index_path.row)
    if @move
      Player.players.insert(to_index_path.row, @move)
      self.playersChanged(false)
    end
  end

  def setEditing(is_editing, animated:is_animated)
    @table_view.setEditing(is_editing, animated:is_animated)
    super
  end

  ##|
  ##|  uninteresting stuff:
  ##|
  def cell_identifier
    @@cell_identifier ||= 'PlayerCell'
  end

  def edit_player_controller
    @edit_player_controller ||= EditPlayerController.new.tap do |ctlr|
      ctlr.delegate = self
    end
  end

  def add_player_controller
    @add_player_controller ||= EditPlayerController.new.tap do |ctlr|
      ctlr.delegate = self

      ctlr.navigationItem.leftBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(
          UIBarButtonSystemItemCancel,
          target: self,
          action: :cancelAddPlayer)

      ctlr.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(
          UIBarButtonSystemItemDone,
          target: self,
          action: :doneAddPlayer)

      ctlr.navigationItem.rightBarButtonItem.enabled = false
    end
  end

end