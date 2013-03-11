class TallyGameController < GameController
  stylesheet :tally_game

  layout :root do
    subview(UIImageView, :notepad_top)

    @player_names = subview(UIScrollView, :player_names) do
      @player_box = subview(UIView, :player_box)
    end

    @scoreboard = subview(UIScrollView, :scoreboard)

    @buttons_view = subview(UIView, :buttons) do
      subview(UIView, :clear_shadow)
      subview(UIView, :ok_shadow)
      subview(UIView, :minusplus5_shadow)
      subview(UIButton.custom, :clear_btn)
      @minus_sml_btn = subview(UIButton.custom, :minus_sml_btn)
      @plus_sml_btn = subview(UIButton.custom, :plus_sml_btn)
      subview(UIView, :minusplus_shadow)
      @minus_big_btn = subview(UIButton.custom, :minus_big_btn)
      @plus_big_btn = subview(UIButton.custom, :plus_big_btn)
      subview(UIButton.custom, :ok_btn)
    end

    subview(UIView, :control_board) do
      subview(UIImageView, :plus)
      subview(UIImageView, :equals)

      subview(BigButton.custom, :calc_up)
      subview(BigButton.custom, :calc_down)

      @current_score_view = subview(DigitalView, :current_score)
      @this_score_view = subview(DigitalView, :this_score)
      @new_score_view = subview(DigitalView, :new_score)
    end

    @scale = 1
    refresh_tally_scale

    @buttons_view.on_swipe :left { tally_scale_down }
    @buttons_view.on_swipe :right { tally_scale_up }
  end

  def tally_scale_down
    @scale = [@scale - 1, 1].max
    refresh_tally_scale
  end

  def tally_scale_up
    @scale = [@scale + 1, 4].min
    refresh_tally_scale
  end

  def refresh_tally_scale
    case @scale
    when 1
      @small_scale = 1
      @big_scale = 5
    when 2
      @small_scale = 5
      @big_scale = 25
    when 3
      @small_scale = 25
      @big_scale = 100
    when 4
      @small_scale = 100
      @big_scale = 500
    end

    @minus_sml_btn.style(normal: { bg_image: "button-sml-minus-#{@big_scale}" },
                       highlighted: { bg_image: "button-sml-minus-#{@big_scale}-down" })
    @plus_sml_btn.style( normal: { bg_image: "button-sml-plus-#{@big_scale}" },
                       highlighted: { bg_image: "button-sml-plus-#{@big_scale}-down" })
    @minus_big_btn.style(  normal: { bg_image: "button-big-minus-#{@small_scale}" },
                       highlighted: { bg_image: "button-big-minus-#{@small_scale}-down" })
    @plus_big_btn.style(   normal: { bg_image: "button-big-plus-#{@small_scale}" },
                       highlighted: { bg_image: "button-big-plus-#{@small_scale}-down" })
  end

  def layoutDidLoad
    self.title = "Tally"

    # setup undo button
    self.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(
        :undo.uibarbuttonitem,
        target: self,
        action: :undo)

    # reset scores
    update_current_scores

    ##|
    ##|  create all the score and player views
    ##|
    prev_width = 0
    total_width = 0
    @score_views = []
    self.game.players.each_with_index do |player, index|
      player_view = TallyScorePlayerView.alloc.initWithPlayer(player, game: self.game)

      frame = player_view.frame
      frame.origin.y = 0
      frame.origin.x = total_width
      player_view.frame = frame
      player_view.on :touch { self.focus_on index }
      @player_names << player_view

      score_view = TallyScoreView.alloc.initWithPlayerView(player_view)
      frame = score_view.frame
      frame.origin.y = 0
      frame.origin.x = total_width
      score_view.frame = frame
      @score_views << score_view
      @scoreboard << score_view

      total_width += frame.size.width
    end

    @player_box.frame = [[0, 0], [0, 0]]
    @player_names.delegate = self
    @scoreboard.delegate = self
    update_scrollviews(false)

    ##|
    ##|  bind buttons
    ##|
    self.view[:ok_btn].on :touch do
      self.game.undo_stack << [self.game.this_player, self.game.this_score]

      self.game.addScore(self.game.this_score, toPlayerAt:self.game.this_player)
      @score_views[self.game.this_player].sizeToFit
      @score_views[self.game.this_player].setNeedsDisplay
      unless self.game.is_locked
        self.game.this_player = (self.game.this_player + 1) % @score_views.length
      end
      update_scrollviews(true)

      self.game.current_score = @score_views[self.game.this_player].scores.reduce(0) {|sum,value| sum + value}
      self.game.this_score = 0

      update_current_scores
    end

    @timer = nil
    self.view[:clear_btn].on :touch do
      self.game.this_score = 0
      update_current_scores
    end

    @plus_big_btn.on :touch do
      self.game.this_score += @small_scale
      update_current_scores
    end

    @plus_sml_btn.on :touch do
      self.game.this_score += @big_scale
      update_current_scores
    end

    @minus_big_btn.on :touch do
      self.game.this_score -= @small_scale
      update_current_scores
    end

    @minus_sml_btn.on :touch do
      self.game.this_score -= @big_scale
      update_current_scores
    end

    self.view[:calc_up].on :touch_down, :touch_drag_enter do |event|
      self.game.this_score += @big_scale * 2
      update_current_scores
      @timer = 0.1.every do
        self.game.this_score += @big_scale * 2
        update_current_scores
      end
    end

    self.view[:calc_down].on :touch_down, :touch_drag_enter do
      self.game.this_score -= @big_scale * 2
      update_current_scores
      @timer = 0.1.every do
        self.game.this_score -= @big_scale * 2
        update_current_scores
      end
    end

    self.view[:calc_up].on :touch_up, :touch_drag_exit, :touch_cancel do
      @timer.invalidate if @timer
    end

    self.view[:calc_down].on :touch_up, :touch_drag_exit, :touch_cancel do
      @timer.invalidate if @timer
    end

    ##|  /layoutDidLoad
  end

  def undo
    undo = self.game.undo_stack[-1]
    if undo
      self.game.this_player = undo[0]
      scores = self.game.scoresFor(self.game.players[self.game.this_player])
      old_score = scores.pop
      @score_views[self.game.this_player].sizeToFit
      @score_views[self.game.this_player].setNeedsDisplay
      update_scrollviews(true)

      self.game.current_score = scores.reduce(0) {|sum,value| sum + value}
      self.game.this_score = old_score || 0

      update_current_scores
      self.game.undo_stack.pop
      undo = nil
    end
  end

  def focus_on index
    new_index = index % @score_views.length
    if self.game.this_player == new_index
      self.game.is_locked = ! self.game.is_locked
    else
      self.game.this_player = new_index
      self.game.is_locked = false
    end

    self.game.current_score = @score_views[self.game.this_player].scores.reduce(0) {|sum,value| sum + value}
    self.game.this_score = 0
    update_scrollviews(true)
    update_current_scores
  end

  def update_scrollviews(animated)
    total_width = 0
    total_height = 0
    content_x = 0
    @score_views.each_index do |index|
      score_view = @score_views[index]
      frame = score_view.frame
      if index == self.game.this_player
        content_x = total_width

        if score_view.player_view.name
          name_width = score_view.player_view.name_width
          frame = Rect(score_view.frame)
          origin = [frame.max_x - name_width - 4, 0]
          size = [name_width + 4, TallyScoreView::Height]

          if animated
            UIView.beginAnimations("update_scrollviews", context: nil)
            UIView.setAnimationDuration(0.3)
            UIView.setAnimationCurve(UIViewAnimationCurveEaseOut)
          end
          # vv-- does stuff --vv
          @player_box.frame = [origin, size]
          if self.game.is_locked
            @player_box.backgroundColor = 0xE57E75.uicolor
          else
            @player_box.backgroundColor = 0xFFF945.uicolor
          end

          if animated
            UIView.commitAnimations
          end
        end
      end
      total_width += frame.size.width
      if frame.size.height > total_height
        total_height = frame.size.height
      end
    end

    @scoreboard.contentSize = [total_width, total_height]
    @player_names.contentSize = [total_height, TallyScorePlayerView::Height]

    if content_x + @scoreboard.bounds.size.width > total_width
      content_x = total_width - @scoreboard.bounds.size.width
    end
    if content_x < 0
      content_x = 0
    end

    content_y = total_height - @scoreboard.bounds.size.height
    if content_y < 0
      content_y = 0
    end
    @scoreboard.setContentOffset([content_x, content_y], animated: true)
  end

  def update_current_scores
    @current_score_view.text = self.game.current_score.to_s
    @this_score_view.text = self.game.this_score.to_s
    @new_score_view.text = (self.game.current_score + self.game.this_score).to_s
  end

  ##|  scrollview delegate
  def scrollViewDidScroll(scroll_view)
    if scroll_view == @scoreboard
      # use the contentOffset.x to adjust player_names
      offset = @player_names.contentOffset
      offset.x = @scoreboard.contentOffset.x
      @player_names.contentOffset = offset
    else
      # use the contentOffset.x to adjust scoreboard
      offset = @scoreboard.contentOffset
      offset.x = @player_names.contentOffset.x
      @scoreboard.contentOffset = offset
    end
  end

end
