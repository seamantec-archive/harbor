class ReportWorker
  @queue = :utils

  def self.perform
    Report.create_reports
  end
end