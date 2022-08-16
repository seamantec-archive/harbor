class TempFileWorker
  @queue = :utils

  def self.perform
     TempFile.clean_up
  end

end