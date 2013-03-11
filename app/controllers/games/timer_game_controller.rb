module TimerGameConstants
  Hours = 0
  Minutes = 1
  Seconds = 2
  SecondsQuickpick = [45, 30, 15]

  # DisplayLabels = ['Digital Clock', 'Stopwatch', 'Strobe Lights', 'Hour Glass']
  DisplayLabels = ['Digital Clock', 'Stopwatch']
    DisplayDigital = 0
    DisplayStopwatch = 1
    DisplayStrobe = 2
  TickingLabels = %w[Off On Increases]
    TickingOff = 0
    TickingOn = 1
    TickingIncreases = 2

  RandomizeChoices = ['Off', '±15 seconds', '±30 seconds', '±1 minute']
  RandomizeChoiceMap = {nil => 'Off', 15 => '±15 seconds', 30 => '±30 seconds', 60 => '±1 minute', 300 => '±5 minutes'}
end


class TimerGameController < GameController
  include TimerGameConstants

  stylesheet :timer_game

  layout :root do
    case game.display
    when DisplayDigital
      @time_display = subview(DigitalView, :digital_display)
    when DisplayStopwatch
      @time_display = subview(StopwatchView, :stopwatch_display)
    when DisplayStrobe
      @time_display = subview(StrobeView, :strobe_display)
    end

    @ding = subview(UILabel, :ding!)
    @ding.hide

    @big_red_button = subview(UIButton.custom, :big_red_button)
    @big_red_button.on :touch {
      toggle_timer
    }
  end

  def initWithGame(game)
    super.tap do
      @timer = nil

      error_ptr = Pointer.new(:id)
      url = 'tick.aif'.resource_url
      @tick_player = @game.ticking && AVAudioPlayer.alloc.initWithContentsOfURL(url, error:error_ptr)
      if @tick_player
        @tick_player.currentTime = 0
        @tick_player.volume = 1
      end

      url = 'buzzer.aif'.resource_url
      @buzzer_player = @game.buzzer && AVAudioPlayer.alloc.initWithContentsOfURL(url, error:error_ptr)
      if @buzzer_player
        @buzzer_player.currentTime = 0
        @buzzer_player.volume = 1
      end
    end
  end

  def viewWillAppear(animated)
    super
    zero_clock
  end

  def viewWillDisappear(animated)
    super
    stop_timer
  end

  def zero_clock
    case game.display
    when DisplayDigital
      @time_display.text = 0.to_duration_str
    when DisplayStopwatch
      @time_display.time = 0
    end
  end

  def toggle_timer
    start = !@timer
    if @timer
      stop_timer
    else
      start_timer
    end
  end

  def stop_timer
    @timer.invalidate if @timer
    @timer = nil
  end

  def start_timer
    @game_time = @game.game_length.to_duration

    if @game.randomize
      @game_time += (rand * @game.randomize * 2).round - @game.randomize

      # at least 5 seconds, even if the player did "something stupid" with
      # the duration / randomization
      @game_time = [5, @game_time].max
    end

    if @game.randomize
      @five_seconds = 5 + rand * -2
      @ten_seconds = @five_seconds + 5 + rand * -2
      @fifteen_seconds = @ten_seconds + 5 + rand * -2
    else
      @five_seconds = 5
      @ten_seconds = 10
      @fifteen_seconds = 15
    end

    @game_remaining = @game_time
    update_clock

    @start_time = NSDate.new.to_f
    @last_ticked = @start_time
    @timer = 0.01.second.every do
      tick!
    end
    unless @game.auto_repeat
      @ding.hide
    end
  end

  def tick!
    now = NSDate.new.to_f
    delta = now - @start_time
    @game_remaining = @game_time - delta

    if @game_remaining <= 0.05
      ding!
    else
      if @tick_player
        threshold = 1
        if @game.ticking == TickingIncreases
          if @game_remaining < @five_seconds
            threshold = 0.1
          elsif @game_remaining < @ten_seconds
            threshold = 0.25
          elsif @game_remaining < @fifteen_seconds
            threshold = 0.5
          end
        end

        if now - @last_ticked >= threshold
          @last_ticked += threshold
          @tick_player.play
        end
      end
      update_clock
    end
  end

  def ding!
    if @buzzer_player
      @buzzer_player.play
    end
    @ding.show
    @ding.shake repeat: 15, duration: 1.5
    if @game.auto_repeat
      1.5.seconds.later {
        @ding.hide
      }
    end

    stop_timer
    if @game.auto_repeat
      start_timer
    end
    zero_clock
  end

  def update_clock
    case game.display
    when DisplayDigital
      @time_display.text = @game_remaining.ceil.to_duration_str
    when DisplayStopwatch
      @time_display.time = @game_remaining.ceil
    end
  end

end
