require_relative '../lib/daemonite'

opts = {
  :host => 'localhost',
  :port => 8298,
  :runtime_opts => [
    ["--port [PORT]", "-p [PORT]", "Specify http port.", ->(p){
      @opts[:port] = p.to_i
      @opts[:pidfile] = @opts[:pidfile].gsub(/\.pid/,'') + '-' + @opts[:port].to_s + '.pid'
    }],
    ["--http-only", "-s", "Only http, no other protocols.", ->(){ @opts[:http_only] = true }]
  ],
  :runtime_cmds => [
    [
      "startclean", "Delete instances before starting.", Proc.new { |status|
        Dir.glob(File.join(__dir__,'instances/*')).each do |d|
          FileUtils.rm_r(d) if File.basename(d) =~ /^\d+$/
        end
      }
    ]
  ]
}

Daemonite.new(opts) do |opts|
  opts['bla'] = 42
  opts[:runtime_proc] = Proc.new do
    opts[:cmdl_info] = opts[:url] = (opts[:secure] ? 'https://' : 'http://') + opts[:host] + ':' + opts[:port].to_s
  end

  run do |opts|
    p opts
    sleep 1
  end
  at_exit do
    p 'rrr'
  end
end.loop!
