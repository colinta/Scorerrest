
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
