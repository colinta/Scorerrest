class BigButton < UIButton
  DEFAULT_MARGIN = 5

  def margin=(value)
    @margin = value
  end

  def margin
    @margin || DEFAULT_MARGIN
  end

  def pointInside(test_point, withEvent: event)
    return true if super

    margin = - self.margin
    insets = UIEdgeInsets.new(margin, margin, margin, margin)
    test_rect = UIEdgeInsetsInsetRect(self.bounds, insets)
    CGRectContainsPoint(test_rect, test_point)
  end

end
