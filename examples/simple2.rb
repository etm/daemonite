require_relative '../lib/daemonite'

daemon = Daemonite.new do |opts|
  opts['bla'] = 42
end
daemon.run do |opts|
  p opts
  sleep 1
end
daemon.at_exit do
  p 'rrr'
end
daemon.loop!
