class CollectorServer < EM::Connection
  attr_accessor :db

  def initialize(db_connection)
    @db = db_connection
  end

  def receive_data(data)
    begin
      data.strip!
      return if data.length == 0

      name, value, hmac = data.split(':', 3)
      value = value.include?('.') ? value.to_f : value.to_i

      db[:metrics].insert(name: name, value: value, hmac: hmac, created_at: Time.now.utc)
    rescue StandardError => e
      App.logger.error('CollectorServer') { e.message }
    end
  end
end
