class ContainerView < UIView
  def extra=(value)
    @extra = value
  end

  def extra
    @extra
  end

  def intrinsicContentSize
    size = CGSize.new(0, 0)
    subviews.each do |subview|
      right = CGRectGetMaxX(subview.frame)
      size.width = right if right > size.width

      bottom = CGRectGetMaxY(subview.frame)
      size.height = bottom if bottom > size.height
    end

    if @extra
      size.width += @extra[0]
      size.height += @extra[1]
    end

    size
  end

end