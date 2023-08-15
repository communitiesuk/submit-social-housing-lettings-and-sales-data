class MultiLogger
  def initialize(*targets)
    @targets = targets
  end

  def info(data)
    @targets.each { |t| t.info(data) }
  end

  def warn(data)
    @targets.each { |t| t.warn(data) }
  end

  def error(data)
    @targets.each { |t| t.error(data) }
  end
end
