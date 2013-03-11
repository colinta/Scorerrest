class TallyScorePlayerView < UIControl
  attr_accessor :player
  attr_accessor :game
  attr_reader :name

  MinWidth = 80
  Height = 25
  RightPad = 4

  def initWithPlayer(player, game: game)
    self.player = player
    self.game = game

    self.initWithFrame([[0, 0], sizeThatFits([0, 0])])
    self.opaque = false
    self.backgroundColor = :clear.uicolor

    self
  end

  def name
    self.player['name']
  end

  def scores
    self.game.scoresFor(self.player)
  end

  def name_width
    return 0 unless self.name
    self.name.sizeWithFont(TallyScoreView.font).width + RightPad
  end

  def sizeThatFits(size)
    [name_width > MinWidth ? name_width : MinWidth, Height]
  end

  def drawRect(rect)
    view_width = self.bounds.size.width
    if self.name and self.name.length
      width = name_width
      y = self.bounds.origin.y + 4
      x = view_width - width
      self.name.drawAtPoint([x, y], withFont:TallyScoreView.font)
    end
  end

end


class TallyScoreView < UIView
  attr_accessor :player_view
  attr_reader :scores

  MinWidth = 80
  Height = 25
  RightPad = 4

  # designated initializer
  def initWithPlayerView(player_view)
    self.player_view = player_view

    self.initWithFrame([[0, 0], sizeThatFits([0, 0])])
    self.opaque = false
    self.backgroundColor = :clear.uicolor

    self
  end

  def scores
    self.player_view.scores
  end

  def self.font
    "Ampersand".uifont(18)
  end

  def width_of word
    @word_widths ||= {}
    @word_widths[word] ||= RightPad + word.sizeWithFont(TallyScoreView.font).width
  end

  def sizeThatFits(size)
    width = @player_view.name_width
    if width < MinWidth
      width = MinWidth
    end

    height = 0
    if self.scores.length > 0
      # 1, 3, 5, 7, ... times the height of the row
      height += (1 + (self.scores.length - 1) * 2) * Height
    end

    Size(width, height)
  end

  def drawRect(rect)
    view_width = self.bounds.size.width

    y = self.bounds.origin.y
    total_score = nil
    self.scores.each do |score|
      draw_me = score.to_s
      if total_score and score >= 0
        draw_me = "+#{draw_me}"
      end
      score_width = width_of draw_me
      x = view_width - score_width
      draw_me.drawAtPoint([x, y], withFont:TallyScoreView.font)

      if total_score
        draw_image = "pencil-line".uiimage
        y += Height
        draw_image.drawAtPoint([view_width - draw_image.size.width, y - draw_image.size.height / 2.0])

        total_score += score
        draw_me = total_score.to_s
        score_width = width_of draw_me
        x = view_width - score_width
        draw_me.drawAtPoint([x, y], withFont:TallyScoreView.font)
      else
        total_score = score
      end
      y += Height
    end
  end

end
