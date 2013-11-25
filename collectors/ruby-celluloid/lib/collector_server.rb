require 'celluloid/io'

# Hack to allow IPv6
class Celluloid::IO::UDPSocket
  def initialize(address_family = nil)
    @socket = ::UDPSocket.new(address_family)
  end
end

class CollectorServer
  include Celluloid::IO

  attr_accessor :db

  MAX_PACKET_SIZE = 1024

  def initialize(addr, port, db_connection)
    @db = db_connection

    @socket = UDPSocket.new(::Socket::AF_INET6)
    @socket.bind(addr, port)
    async.run
  end

  def run
    loop do
      data, _ = @socket.recvfrom(MAX_PACKET_SIZE)
      receive_data data
    end
  end

  def receive_data(data)
    begin
      data.strip!
      return if data.length == 0

      name, value, hmac = data.split(':', 3)
      value = value.to_f

      db[:metrics].insert(name: name, value: value, hmac: hmac, created_at: Time.now.utc)
    rescue StandardError => e
      App.logger.error('CollectorServer') { e.message }
    end
  end
end
