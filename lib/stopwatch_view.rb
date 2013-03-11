class StopwatchView < UIView

  def initWithFrame(frame)
    super.tap do
      @bg = subview(UIImageView.alloc.initWithImage('stopwatch-bg'.uiimage))
      @second = subview(UIImageView.alloc.initWithImage('stopwatch-second'.uiimage))
      @minute = subview(UIImageView.alloc.initWithImage('stopwatch-minute'.uiimage))
      @hour = subview(UIImageView.alloc.initWithImage('stopwatch-hour'.uiimage))

      self.seconds = 0
      self.minutes = 0
      self.hours = 0
    end
  end

  def intrinsicContentSize
    @bg.frame.size
  end

  def time=(value)
    h, m, s = value.to_duration_ary
    self.hours = h
    self.minutes = m
    self.seconds = s
  end

  def seconds=(value)
    value = value % 60
    @second.transform = CGAffineTransformMakeRotation((value * 6).degrees)
  end

  def minutes=(value)
    value = value % 60
    @minute.transform = CGAffineTransformMakeRotation((value * 6).degrees)
  end

  def hours=(value)
    value = value % 12
    @hour.transform = CGAffineTransformMakeRotation((value * 30).degrees)
  end

end
