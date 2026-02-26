class MultiLogger
  def initialize(file_logger)
    @rails_logger = Rails.logger
    @file_logger = file_logger
  end

  delegate :info, to: :@rails_logger

  delegate :warn, to: :@rails_logger

  def error(data)
    @rails_logger.error(data)
    @file_logger.error(data)
  end
end
