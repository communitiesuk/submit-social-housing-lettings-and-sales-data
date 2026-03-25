module TimecopHelper
  def without_timecop(&block)
    if defined?(Timecop)
      Timecop.return(&block)
    else
      yield
    end
  end
end
