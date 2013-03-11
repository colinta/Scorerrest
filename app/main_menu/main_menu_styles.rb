
Teacup::Stylesheet.new(:main_menu) do

  style :root,
    backgroundColor:  :black.uicolor  # :table_view.uicolor

  style :bg,
    startColor: 0x000000,
    finalColor: 0x505050,
    angle:      0.5.pi,
    origin: [0, 0],
    constraints: [:full]

  style :apps,
    background: :clear,
    constraints: [:full]

  if device_is? iPhone
    style :apps,
      portrait: {
        left_margin: 25,
        right_margin: 25,
        top_margin: 15,
        horizontal_spacing: 15,
        vertical_spacing: 13,
      },
      landscape: {
        left_margin: 30,
        right_margin: 30,
        top_margin: 1,
        horizontal_spacing: 27,
        vertical_spacing: 0,
      }
  else
    style :apps,
      portrait: {
        left_margin: 25,
        right_margin: 25,
        top_margin: 15,
        horizontal_spacing: 26,
        vertical_spacing: 15,
      },
      landscape: {
        left_margin: 30,
        right_margin: 30,
        top_margin: 1,
        horizontal_spacing: 46,
        vertical_spacing: 12,
      }
    end
end


Teacup::Stylesheet.new(:player_manager) do

  style :root

  style :table,
    constraints: [:full]

end


Teacup::Stylesheet.new(:edit_player) do

  style :root,
    backgroundColor: :black.uicolor

  style :name,
    frame: [[10, 30], [300, 40]],
    borderStyle: UITextBorderStyleRoundedRect,
    font: UIFont.systemFontOfSize(14),
    minimumFontSize: 17,
    contentVerticalAlignment: UIControlContentVerticalAlignmentCenter,
    adjustsFontSizeToFitWidth: true,
    placeholder: "Name",
    returnKeyType: UIReturnKeyDone

end


Teacup::Stylesheet.new(:game_manager) do

  style :root

  style :table,
    constraints: [:full]

end
