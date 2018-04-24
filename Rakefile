require 'rake'
require 'rubygems/package_task'
require 'rake/testtask'

spec = eval(File.read('daemonite.gemspec'))
Gem::PackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
  `rm pkg/* -rf`
  `ln -sf #{pkg.name}.gem pkg/daemonite.gem`
end

task :push => :gem do |r|
  `gem push pkg/daemonite.gem`
end

task :install => :gem do |r|
  `gem install pkg/daemonite.gem`
end
