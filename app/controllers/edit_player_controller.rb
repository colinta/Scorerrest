
class EditPlayerController < UIViewController
  attr_accessor :delegate
  stylesheet :edit_player

  layout :root do
    @name_field = subview(UITextField, :name, delegate: self)
  end

  def viewWillAppear(is_animated)
    super

    # we will be using this view to *add* a player, in which case player will be nil.
    if not @player
      # assign empty or default values
      self.title = "New Player"
      @name_field.text = ""
    else
      # assign values from @player
      self.title = @player['name']
      @name_field.text = @player['name']
    end
    @name_field.becomeFirstResponder
  end

  def viewWillUnload
    NSNotificationCenter.defaultCenter.removeObserver(self)
    self.player = nil
  end

  # the "Add" view will use this to get the newly created player info
  def player
    return nil if not @name_field

    name = @name_field.text.to_s

    if name.length > 0
      {
        'name' => name,
      }
    else
      nil
    end
  end

  def player=(player)
    @player = player
  end

  def navigationController(nav_ctlr, willShowViewController:ctlr, animated:is_animated)
    if ctlr != self
      if @name_field.isFirstResponder
        @name_field.resignFirstResponder
      end
      nav_ctlr.delegate = nil
    end
  end

  def textFieldShouldReturn(text_field)
    @name_field.resignFirstResponder
    if self.delegate
      self.delegate.player_editor_should_return(self) if self.delegate.respondsToSelector('player_editor_should_return:')
    end
  end

  def textFieldDidBeginEditing(text_field)
    NSNotificationCenter.defaultCenter.addObserver(self,
        selector: "textFieldChanged",
        name: UITextFieldTextDidChangeNotification,
        object: nil)
  end

  def textFieldDidEndEditing(text_field)
    NSNotificationCenter.defaultCenter.removeObserver(self)

    if @player
      if text_field == @name_field
        @player['name'] = text_field.text
      end
      NSNotificationCenter.defaultCenter.postNotificationName(PlayersChangedNotification, object:self)
    end
  end

  def textFieldChanged
    if not @player
      # enable or disable the button, depending on whether the data is valid
      self.navigationItem.rightBarButtonItem.enabled = self.player ? true : false
    end
  end

end
