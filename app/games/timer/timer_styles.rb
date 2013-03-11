Teacup::Stylesheet.new(:timer_game) do
  style :root,
    background: :white

  style :display_view,
    constraints: [
      constrain_top(8),
      :center_x,
    ]
  style :digital_display, extends: :display_view,
    constraints: [
      constrain_top(8),
      constrain(:width).equals(:superview, :width),
      :center_x,
    ]
  style :stopwatch_display, extends: :display_view
  style :strobe_display, extends: :display_view

  style :ding!,
    text: 'DING!',
    font: :italic.uifont(100),
    background: :clear,
    constraints: [
      :center_x,
      :center_y,
    ]

  style :big_red_button,
    normal: { image: "timer-pushme" },
    highlighted: { image: "timer-pushedme" },
    constraints: [
      :center_x,
      constrain_bottom(-8),
    ]
end


Teacup::Stylesheet.new(:timer_setup) do

  style :root

  style :table, constraints: [:full]

  style :modal,
    constraints: [:full],
    backgroundColor: :black.uicolor(0.5)

  if device_is? iPhone4
    style :keyboard_down,
      portrait: {
        frame: [[0, 568], [320, 260]]
      },
      landscape: {
        frame: [[0, 320], [568, 260]]
      }
  elsif device_is? iPhone
    style :keyboard_down,
      portrait: {
        frame: [[0, 480], [320, 260]]
      },
      landscape: {
        frame: [[0, 320], [480, 260]]
      }
  else
    style :keyboard_down,
      portrait: {
        frame: [[0, 1024], [768, 260]]
      },
      landscape: {
        frame: [[0, 768], [1024, 260]]
      }
  end

  if device_is? iPhone4
    style :keyboard_up,
      portrait: {
        frame: [[0, 244], [320, 260]]
      },
      landscape: {
        frame: [[0, 8], [568, 260]]
      }
  elsif device_is? iPhone
    style :keyboard_up,
      portrait: {
        frame: [[0, 156], [320, 260]]
      },
      landscape: {
        frame: [[0, 8], [480, 260]]
      }
  else
    style :keyboard_up,
      portrait: {
        frame: [[0, 700], [768, 260]]
      },
      landscape: {
        frame: [[0, 444], [1024, 260]]
      }
  end

  style :navigation,
    constraints: [
      :top,
      :full_width,
      constrain_height(44),
    ]

  style :picker,
    constraints: [
      :full_width,
      constrain_below(:navigation),
      constrain_height(216),
    ],
    showsSelectionIndicator: true

end
