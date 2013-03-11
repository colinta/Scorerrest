
class AppLauncherView < UIControl

  def initialize(name, icon)
    self.init
    self.stylesheet = :app_launcher
    self.stylename = :app_launcher

    if Device.ipad?
      icon += '72'
    end
    @icon = icon.uiimage
    unless @pressed_icon = "#{icon}-Pressed".uiimage
      @pressed_icon = @icon.darken
    end

    # properties = CIFilter.filterNamesInCategory(KCICategoryBuiltIn)
    # properties.each do |filter_name|
    #   filter = CIFilter.filterWithName(filter_name)
    #   NSLog "\n#{filter_name}\n----------------\n#{filter.attributes.inspect}"
    # end

    @image_view = subview(UIImageView, :icon,
      image: @icon)

    @label = subview(UILabel, :title,
      text: name)

    self.on :touch_down, :touch_drag_enter do
      @image_view.image = @pressed_icon
    end

    self.on :touch_up, :touch_drag_exit, :touch_cancel do
      @image_view.image = @icon
    end

    Teacup.should_restyle! {
      self.restyle!
    }
  end

  def intrinsicContentSize
    @icon.size + CGSize.new(26, 30)
  end

end
