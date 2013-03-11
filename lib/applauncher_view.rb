class AppLauncherView < UIControl

  def initialize(name, icon)
    self.init
    self.stylesheet = :app_launcher
    self.stylename = :app_launcher

    if Device.ipad?
      icon += '72'
    end

    @icon = icon.uiimage
    @pressed_icon = "#{icon}-Pressed".uiimage
    unless @pressed_icon
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


Teacup::Stylesheet.new(:app_launcher) do

  if device_is? iPhone
    style :app_launcher,
      width: 80,
      height: 84
  else
    style :app_launcher,
      width: 98,
      height: 102
  end

  style :icon, constraints: [
      :center_x, constrain_top(10)
    ]

  style :title, constraints: [
      :center_x, constrain_below(:icon, 2)
    ],
    textAlignment: :center.uialignment,
    textColor: :white.uicolor,
    backgroundColor: :clear.uicolor

  if device_is? iPhone
    style :title,
      font: :bold.uifont(10)
  else
    style :title,
      font: :bold.uifont(14)
  end

end
