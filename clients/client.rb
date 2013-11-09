#! /usr/bin/env ruby

require 'socket'
require 'openssl'
require 'optparse'

COLLECTOR = {
  :host => '::1',
  :port => 28000
}

SECRET_KEY = '74e6f7298a9c2d168935f58c001bad88'
PROBE_NAME = 'temp1'

SETTINGS = {}
OptionParser.new do |opts|
  opts.banner = "Usage: client.rb [options]"

  opts.on("-v", "--verbose", "Be verbose") do |v|
    SETTINGS[:verbose] = v
  end
  opts.on("-l", "--loop", "Run in endless loop") do |v|
    SETTINGS[:loop] = v
  end
end.parse!

def send_data
  udp   = UDPSocket.new(Socket::AF_INET6)
  value = rand(100)
  data  = "#{PROBE_NAME}:#{value}"
  hmac  = gen_hmac(data)

  puts "#{data}:#{hmac}" if SETTINGS[:verbose]
  udp.send "#{data}:#{hmac}", 0, COLLECTOR[:host], COLLECTOR[:port]
end

def gen_hmac(data)
  OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA256.new, SECRET_KEY, data)
end

if SETTINGS[:loop]
  loop { send_data }
else
  send_data
end
