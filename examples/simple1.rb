require_relative '../lib/daemonite'

Daemonite.new do |opts|
  opts[:bla] = 42

  run do |opts|
    p opts
    sleep 1
  end
  at_exit do
    p 'bye bye'
  end
end.loop!
