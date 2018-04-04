require_relative '../lib/daemonite'

daemon = Daemonite.new do |opts|
  opts['bla']
end
daemon.run do |opts|
  p opts
  sleep 1
end
daemon.at_exit do
  p 'rrr'
end
daemon.loop!
