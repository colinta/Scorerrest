class Numeric

  # returns the duration as a list of hours, minutes, and seconds
  def to_duration_ary
    remainder = self
    num_seconds = (remainder % 60).in_seconds.floor
    remainder -= num_seconds
    num_minutes = (remainder % 3600).in_minutes.floor
    remainder -= num_minutes.minutes
    num_hours = remainder.in_hours.floor
    num_milliseconds = self - num_seconds - num_minutes.minutes - num_hours.hours
    [num_hours, num_minutes, num_seconds]
  end

  # returns the duration as [HH:]mm:ss
  def to_duration_str
    h, m, s = to_duration_ary
    retval = ''
    if h > 0
      retval << h.to_s.rjust(2, '0') << ':'
    end
    retval << m.to_s.rjust(2, '0') << ':'
    retval << s.to_s.rjust(2, '0')
    return retval
  end

end


class NSArray

  def to_duration
    hours, minutes, seconds = self
    seconds + minutes.minutes + hours.hours
  end

end
