class TimerSetupController < UIViewController
  include TimerGameConstants

  TimerSection = 0
    GameLengthRow = 0
    RandomizeRow = 1
    AutoRepeatRow = 2
  DisplaySection = 1
  SoundsSection = 2
    TickingRow = 0
    BuzzerRow = 1
  SubmitSection = 3
    SaveRow = 0
    StartGameRow = 1

  stylesheet :timer_setup

  layout :root do
    @table_view = subview(UITableView.grouped, :table,
      dataSource: self,
      delegate: self
      )

    @modal = subview(UIControl, :modal, alpha: 0)
    @modal_view = nil

    @game_length_keyboard = subview(UIView, :keyboard_down) do

      subview(UINavigationBar, :navigation) do |nav|
        item = UINavigationItem.new
        item.leftBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(
            UIBarButtonSystemItemCancel,
            target: self,
            action: :cancelGameLengthPicker)

        item.rightBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(
            UIBarButtonSystemItemDone,
            target: self,
            action: :doneGameLengthPicker)
        nav.items = [item]
      end

      @game_length_delegate = GameLengthPickerDelegate.new
      @game_length_picker = subview(UIPickerView, :picker,
        dataSource: @game_length_delegate,
        delegate: @game_length_delegate
        )
    end

    @randomize_keyboard = subview(UIView, :keyboard_down) do

      subview(UINavigationBar, :navigation) do |nav|
        item = UINavigationItem.new
        item.leftBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(
            UIBarButtonSystemItemCancel,
            target: self,
            action: :cancelRandomizePicker)

        item.rightBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(
            UIBarButtonSystemItemDone,
            target: self,
            action: :doneRandomizePicker)
        nav.items = [item]
      end

      @randomize_delegate = RandomizePickerDelegate.new
      @randomize_picker = subview(UIPickerView, :picker,
        dataSource: @randomize_delegate,
        delegate: @randomize_delegate
        )
    end
  end

  def init
    super
    setHidesBottomBarWhenPushed(true)
    @game_length = [0, 1, 0]
    @randomize = nil
    @auto_repeat = false
    @display_index = 0  # => Off
    @ticking_index = TickingOn
    @buzzer = true
    @game_save = false

    self
  end

  def viewDidLoad
    super
    self.title = "Timer"

    @modal.on :touch do
      if @modal_view == @game_length_keyboard
        hide_game_length_keyboard
      elsif @modal_view == @randomize_keyboard
        hide_randomize_keyboard
      end
    end
  end

  def start_game
    game = TimerGame.new

    started = NSDateFormatter.localizedStringFromDate(NSDate.date, dateStyle:NSDateFormatterMediumStyle, timeStyle:NSDateFormatterShortStyle)
    game.name = "Timer – #{started}"
    game.subtitle = time_display(@game_length)
    if @auto_repeat
      game.subtitle << ', Auto-repeats'
    end
    if @randomize
      game.subtitle << ', ' << RandomizeChoiceMap[@randomize]
    end
    game.auto_repeat = @auto_repeat
    game.game_length = @game_length
    game.randomize = @randomize
    game.display = @display_index == DisplayLabels.length ? nil : @display_index
    game.ticking = @ticking_index == TickingOff ? nil : @ticking_index
    game.buzzer = @buzzer
    game.save = @game_save

    if game.save
      Game << game
    end

    timer_controller = TimerGameController.alloc.initWithGame(game)
    # create list of controllers that doesn't include the current controller
    ctlrs = self.navigationController.viewControllers[0...-1]
    ctlrs << timer_controller
    self.navigationController.setViewControllers(ctlrs, animated:true)
  end

  def tableView(table_view, cellForRowAtIndexPath:index_path)
    case index_path
    when IndexPath[TimerSection, GameLengthRow]
      identifier = 'Timer-GameLengthRow'
      cell = table_view.dequeueReusableCellWithIdentifier(identifier) ||
             UITableViewCell.alloc.initWithStyle(:value1.uitablecellstyle, reuseIdentifier: identifier).tap do |cell|
                cell.textLabel.text = "Game Length"
                # cell.accessoryType = :disclosure.uitablecellaccessory
             end

      cell.detailTextLabel.text = time_display(@game_length)
    when IndexPath[TimerSection, RandomizeRow]
      identifier = 'Timer-RandomizeRow'
      cell = table_view.dequeueReusableCellWithIdentifier(identifier) ||
             UITableViewCell.alloc.initWithStyle(:value1.uitablecellstyle, reuseIdentifier: identifier).tap do |cell|
                cell.textLabel.text = "Randomize"
                # cell.accessoryType = :disclosure.uitablecellaccessory
             end

      cell.detailTextLabel.text = RandomizeChoiceMap[@randomize]
    when IndexPath[TimerSection, AutoRepeatRow]
      identifier = 'Timer-AutoRepeatRow'
      cell = table_view.dequeueReusableCellWithIdentifier(identifier) ||
             UITableViewCell.alloc.initWithStyle(:default.uitablecellstyle, reuseIdentifier: identifier).tap do |cell|
                cell.textLabel.text = "Auto repeats"
                switch = UISwitch.new
                switch.on = @auto_repeat
                switch.on :changed do
                  @auto_repeat = switch.on?
                end

                cell.accessoryView = switch
                cell.selectionStyle = :none.uitablecellselectionstyle
             end

    when IndexPath[DisplaySection]
      identifier = 'Timer-DisplayRow'
      cell = table_view.dequeueReusableCellWithIdentifier(identifier) ||
           UITableViewCell.alloc.initWithStyle(:default.uitablecellstyle, reuseIdentifier: identifier).tap do |cell|
           end

      if index_path.row == DisplayLabels.length
        cell.textLabel.text = 'None'
      else
        cell.textLabel.text = DisplayLabels[index_path.row]
      end

      if index_path.row == @display_index
        cell.accessoryType = :checkmark.uitablecellaccessory
      else
        cell.accessoryType = :none.uitablecellaccessory
      end

    when IndexPath[SoundsSection, TickingRow]
      identifier = 'Timer-TickingRow'
      cell = table_view.dequeueReusableCellWithIdentifier(identifier) ||
           UITableViewCell.alloc.initWithStyle(:default.uitablecellstyle, reuseIdentifier: identifier).tap do |cell|
                cell.textLabel.text = 'Ticking'
                segment = UISegmentedControl.bar(TickingLabels)
                segment.apportionsSegmentWidthsByContent = true
                segment.frame = [[139, 8], [164, 30]]
                cell.accessoryView = segment
                segment.on :change {
                  @ticking_index = segment.selectedSegmentIndex
                }
           end
      cell.accessoryView.selectedSegmentIndex = @ticking_index

    when IndexPath[SoundsSection, BuzzerRow]
      identifier = 'Timer-BuzzerRow'
      cell = table_view.dequeueReusableCellWithIdentifier(identifier) ||
             UITableViewCell.alloc.initWithStyle(:default.uitablecellstyle, reuseIdentifier: identifier).tap do |cell|
                cell.textLabel.text = 'Buzzer'
                switch = UISwitch.new
                switch.on = @buzzer
                switch.on :changed do
                  @buzzer = switch.on?
                end

                cell.accessoryView = switch
                cell.selectionStyle = :none.uitablecellselectionstyle
             end

    when IndexPath[SubmitSection, SaveRow]
      identifier = 'Timer-SaveRow'
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
      identifier = 'Timer-StartGameRow'
      cell = table_view.dequeueReusableCellWithIdentifier(identifier) ||
           UITableViewCell.alloc.initWithStyle(:default.uitablecellstyle, reuseIdentifier: identifier).tap do |cell|
              cell.accessoryType = :disclosure.uitablecellaccessory
              cell.textLabel.text = 'Start Game'
           end

    else
      cell = nil
    end

    return cell
  end

  def numberOfSectionsInTableView(table_view)
    4
  end

  def tableView(table_view, titleForHeaderInSection:section)
    case section
    when TimerSection
      "Timer"
    when DisplaySection
      "Display"
    when SoundsSection
      "Sounds"
    else
      nil
    end
  end

  def tableView(table_view, numberOfRowsInSection:section)
    case section
    when TimerSection
      3
    when DisplaySection
      DisplayLabels.length + 1
    when SoundsSection
      2
    when SubmitSection
      2
    end
  end

  def tableView(table_view, didSelectRowAtIndexPath:index_path)
    table_view.deselectRowAtIndexPath(index_path, animated:true)

    case index_path
    when IndexPath[TimerSection, GameLengthRow]
      show_game_length_keyboard
    when IndexPath[TimerSection, RandomizeRow]
      show_randomize_keyboard
    when IndexPath[DisplaySection]
      if @display_index != index_path.row
        table_view.cellForRowAtIndexPath([DisplaySection, @display_index].nsindexpath).accessoryType = :none.uitablecellaccessory
        table_view.cellForRowAtIndexPath(index_path).accessoryType = :checkmark.uitablecellaccessory
        @display_index = index_path.row
      end
    when IndexPath[SubmitSection]
      start_game
    end
  end

  ##|
  ##|  GAME LENGTH + PICKER
  ##|
  def cancelGameLengthPicker
    hide_game_length_keyboard
  end

  def doneGameLengthPicker
    picker_view = @game_length_picker
    if picker_view[Hours] == 0 and picker_view[Minutes] == 0 and picker_view[Seconds] == SecondsQuickpick.length
      # can't pick all zeroes - this selects 1 second, even though '0' is selected
      @game_length[Seconds] = 1
    elsif picker_view[Seconds] < SecondsQuickpick.length
      @game_length[Seconds] = SecondsQuickpick[picker_view[Seconds]]
    else
      @game_length[Seconds] = picker_view[Seconds] - SecondsQuickpick.length
    end
    @game_length[Minutes] = picker_view[Minutes]
    @game_length[Hours] = picker_view[Hours]

    @table_view.reloadRowsAtIndexPaths([[TimerSection, GameLengthRow].nsindexpath],
                     withRowAnimation: :automatic.uitablerowanimation)

    hide_game_length_keyboard
  end

  def show_game_length_keyboard
    @game_length_picker.selectRow(@game_length[Hours], inComponent:Hours, animated:false)
    @game_length_picker.selectRow(@game_length[Minutes], inComponent:Minutes, animated:false)
    if SecondsQuickpick.include? @game_length[Seconds]
      @game_length_picker.selectRow(SecondsQuickpick.index(@game_length[Seconds]), inComponent:Seconds, animated:false)
    else
      @game_length_picker.selectRow(SecondsQuickpick.length + @game_length[Seconds], inComponent:Seconds, animated:false)
    end

    @modal.fade_in
    @modal_view = @game_length_keyboard
    @game_length_keyboard.animate_to_stylename(:keyboard_up)
  end

  def hide_game_length_keyboard
    @modal.fade_out
    @game_length_keyboard.animate_to_stylename(:keyboard_down)
  end

  def cancelRandomizePicker
    hide_randomize_keyboard
  end

  def doneRandomizePicker
    @randomize = RandomizeChoiceMap.key(RandomizeChoices[@randomize_picker[0]])

    @table_view.reloadRowsAtIndexPaths([[TimerSection, RandomizeRow].nsindexpath],
                      withRowAnimation: :automatic.uitablerowanimation)

    hide_randomize_keyboard
  end

  def show_randomize_keyboard
    randomize_choice = RandomizeChoiceMap[@randomize]
    @randomize_picker.selectRow(RandomizeChoices.index(randomize_choice), inComponent:0, animated:false)

    @modal.fade_in
    @modal_view = @randomize_keyboard
    @randomize_keyboard.animate_to_stylename(:keyboard_up)
  end

  def hide_randomize_keyboard
    @modal.fade_out
    @randomize_keyboard.animate_to_stylename(:keyboard_down)
  end

  ##|
  ##|  MISC
  ##|
  def time_display(time)
    hours = time[Hours]
    minutes = time[Minutes]
    seconds = time[Seconds]

    ret = ""
    if hours > 0
      ret += hours.to_s + ":"
    end

    if hours > 0 and minutes < 10
      ret += "0"
    end

    if minutes > 0
      ret += minutes.to_s
    else
      ret += "0"
    end
    ret += ":"

    if seconds < 10
      ret += "0"
    end
    ret += seconds.to_s
    return ret
  end

end


class GameLengthPickerDelegate
  include TimerGameConstants

  def numberOfComponentsInPickerView(picker_view)
    3
  end

  def pickerView(picker_view, numberOfRowsInComponent:section)
    case section
    when Hours  # hours - 0..100
      100
    when Minutes  # minutes - 0..59
      60
    when Seconds  # seconds - 15,30,45,0..59
      SecondsQuickpick.length + 60
    end
  end

  def pickerView(picker_view, titleForRow:row, forComponent:section)
    if section == Seconds and row < SecondsQuickpick.length
      r = SecondsQuickpick[row].to_s
    elsif section == Seconds
      r = (row - SecondsQuickpick.length).to_s
    else
      r = row.to_s
    end

    if section == Hours
      r
    else
      r.rjust(2, '0')
    end
  end

  def pickerView(picker_view, widthForComponent:section)
    if section == Seconds
      102
    elsif section == Minutes
      99
    else
      81
    end
  end

end


class RandomizePickerDelegate
  include TimerGameConstants

  def numberOfComponentsInPickerView(picker_view)
    1
  end

  def pickerView(picker_view, numberOfRowsInComponent:section)
    RandomizeChoices.length
  end

  def pickerView(picker_view, titleForRow:row, forComponent:section)
    RandomizeChoices[row].to_s
  end

end
