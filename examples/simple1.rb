require_relative '../lib/daemonite'

Daemonite.new do |opts|
  opts['bla']

  run do |opts|
    p opts
    sleep 1
  end
  at_exit do
    p 'rrr'
  end
end.loop!
