Teacup::Stylesheet.new(:tally_setup) do
  style :root

  style :table,
    constraints: [:full]

end


Teacup::Stylesheet.new(:tally_game) do
  score_top = 286
  control_board_height = 70
  control_board_margin_left = 10
  control_board_margin_right = 7
  calc_top = 25
  calc_size = [73, 34]

  style :root,
    backgroundColor: :white,
    frame: :full,
    autoresizingMask: flexible_width | flexible_height

  style :scoreboard,
    backgroundColor: "notepad".uiimage.uicolor,
    constraints: [
      :full_width,
      constrain_below(:notepad_top),
      constrain_above(:control_board),
    ]

  style :notepad_top,
    image: "notepad-top".uiimage.tileable,
    constraints: [:top, :full_width]

  style :player_names,
    showsHorizontalScrollIndicator: false,
    showsVerticalScrollIndicator: false,
    constraints: [
      :top,
      :full_width,
      constrain_height(TallyScorePlayerView::Height).priority(:required)
    ]

  style :player_box

  style :buttons,
    constraints: [
      :bottom,
      constrain_width(320),
      constrain_height(48),
      :center_x,
    ]

  style :control_board,
    constraints: [
      constrain_above(:buttons),
      constrain_below(:scoreboard),
      constrain_width(320),
      constrain_height(control_board_height),
      :center_x,
    ]

  style :current_score,
    constraints: [
      constrain(:left).is_at_least(:control_board, :left).plus(control_board_margin_left),
      constrain_top(calc_top),
      constrain_width(72),
      constrain_height(35),
    ]

  style :plus,
    image: "plus",
    constraints: [
      constrain(:left).equals(:current_score, :right).plus(12),
      constrain(:top).equals(:current_score, :top).plus(8),
    ]

  style :this_score,
    constraints: [
      constrain(:left).equals(:plus, :right).plus(12),
      constrain(:top).equals(:current_score, :top),
      constrain_width(72),
      constrain_height(35),
    ]

  style :equals,
    image: "equals",
    constraints: [
      constrain(:left).equals(:this_score, :right).plus(12),
      constrain(:top).equals(:current_score, :top).plus(8),
    ]

  style :calc_up,
    normal: { image: "calc-arrow-up" },
    highlighted: { image: "calc-arrow-up-pressed" },
    constraints: [
      constrain(:bottom).equals(:equals, :top),
      constrain(:center_x).equals(:equals, :center_x).plus(1),
    ]

  style :calc_down,
    normal: { image: "calc-arrow-down" },
    highlighted: { image: "calc-arrow-down-pressed" },
    constraints: [
      constrain(:top).equals(:equals, :bottom),
      constrain(:center_x).equals(:equals, :center_x).plus(1),
    ]

  style :new_score,
    constraints: [
      constrain(:left).equals(:equals, :right).plus(12),
      constrain(:right).is_at_least(:control_board, :right).minus(control_board_margin_right),
      constrain(:top).equals(:current_score, :top),
      constrain_width(72),
      constrain_height(35),
    ]

  y = 4
  x = 3
  w = 54
  h = 34
  shadow_path = UIBezierPath.bezierPath
  shadow_path.moveToPoint(Point(0, 0))
  shadow_path.addLineToPoint(Point(w, 0))
  shadow_path.addLineToPoint(Point(w, h))
  shadow_path.addLineToPoint(Point(0, h))
  shadow_path.addLineToPoint(Point(0, 0))
  style :clear_shadow,
    frame: [[x, y + 2], [w, h]],
    shadow: {
      color: :black,
      opacity: 0.6,
      radius: 3.0,
      offset: [0, 0],
      path: shadow_path.CGPath,
    }

  w = 57
  style :clear_btn,
    origin: [x, y + 3],
    normal: { image: "button-clear" },
    highlighted: { image: "button-clear-down" }
  x += w

  w = 194
  h = 34
  shadow_path = UIBezierPath.bezierPath
  shadow_path.moveToPoint(Point(0, 0))
  shadow_path.addLineToPoint(Point(w, 0))
  shadow_path.addLineToPoint(Point(w, h))
  shadow_path.addLineToPoint(Point(0, h))
  shadow_path.addLineToPoint(Point(0, 0))
  style :minusplus5_shadow,
    frame: [[x, y + 2], [w, h]],
    shadow: {
      color: :black,
      opacity: 0.6,
      radius: 3.0,
      offset: [0, 0],
      path: shadow_path.CGPath,
    }

  big_btn_font = 'Arial Black'.uifont(25)
  small_btn_font = 'Arial Black'.uifont(20)
  w = 45
  style :minus_sml_btn,
    titleLabel: { font: small_btn_font },
    origin: [x, y + 3],
    size: [45, 35]
  x += w

  w = 104
  h = 43
  shadow_path = UIBezierPath.bezierPath
  shadow_path.moveToPoint(Point(0, 0))
  shadow_path.addLineToPoint(Point(w, 0))
  shadow_path.addLineToPoint(Point(w, h))
  shadow_path.addLineToPoint(Point(0, h))
  shadow_path.addLineToPoint(Point(0, 0))
  style :minusplus_shadow,
    frame: [[x, y - 2], [w, h]],
    shadow: {
      color: :black,
      opacity: 0.6,
      radius: 3.0,
      offset: [0, 0],
      path: shadow_path.CGPath,
    }

  w = 52
  style :minus_big_btn,
    titleLabel: { font: big_btn_font },
    origin: [x, y - 2],
    size: [53, 45]
  x += w

  w = 52
  style :plus_big_btn,
    titleLabel: { font: big_btn_font },
    origin: [x, y - 2],
    size: [53, 45]
  x += w

  w = 49
  style :plus_sml_btn,
    titleLabel: { font: small_btn_font },
    origin: [x, y + 3],
    size: [45, 35]
  x += w

  w = 54
  h = 34
  shadow_path = UIBezierPath.bezierPath
  shadow_path.moveToPoint(Point(0, 0))
  shadow_path.addLineToPoint(Point(w, 0))
  shadow_path.addLineToPoint(Point(w, h))
  shadow_path.addLineToPoint(Point(0, h))
  shadow_path.addLineToPoint(Point(0, 0))
  style :ok_shadow,
    frame: [[x, y + 2], [w, h]],
    shadow: {
      color: :black,
      opacity: 0.6,
      radius: 3.0,
      offset: [0, 0],
      path: shadow_path.CGPath,
    }

  w = 54
  style :ok_btn,
    origin: [x, y + 3],
    normal: { image: "button-ok" },
    highlighted: { image: "button-ok-down" }

end
