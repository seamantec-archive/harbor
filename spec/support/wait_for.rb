module WaitFor
  def wait_for
    Timeout.timeout(60) do
      start_time = Time.now
      loop until Time.now-start_time < 60
    end
  end

end
