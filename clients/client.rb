#! /usr/bin/env ruby

require 'socket'

probe_name  = 'temp1'
value       = rand(100)
hmac        = '74e6f7298a9c2d168935f58c001bad88'

collector = {
  :host => '::1',
  :port => 28000
}

udp = UDPSocket.new(Socket::AF_INET6)
udp.send "#{probe_name}:#{value}:#{hmac}", 0, collector[:host], collector[:port]
