require 'rubygems'
require 'bundler/setup'

Bundler.require

$LOAD_PATH.unshift __dir__ unless $LOAD_PATH.include?(__dir__)

require 'lib/app'
require 'lib/db'
require 'lib/collector_server'

App.config.load File.join(App.root, 'config.yml')
App.logger = Logger.new(STDOUT)
# App.logger = Logger.new(File.expand_path File.join(App.root, 'log/collector.log'))


Signal.trap("INT")  { EventMachine.stop }
Signal.trap("TERM") { EventMachine.stop }

EventMachine.run do
  Db.connect App.config.database['nodes'], App.config.database['name']
  EventMachine.open_datagram_socket App.config.application['host'], App.config.application['port'], CollectorServer, Db.connection
end
