class ExchangeWorker
  @queue = :utils
  def self.perform
     Ws::MnbExchange.download_currencies
  end
end