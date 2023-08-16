class MultiLogger
  def initialize(file_logger)
    @rails_logger = Rails.logger
    @file_logger = file_logger
  end

  def info(data)
    @rails_logger.info(data)
  end

  def warn(data)
    @rails_logger.warn(data)
  end

  def error(data)
    @rails_logger.error(data)
    @file_logger.error(data)
  end
end
