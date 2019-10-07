require 'rake'
require 'rubygems/package_task'
require 'fileutils'

spec = eval(File.read('daemonite.gemspec'))
Gem::PackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
  FileUtils.mkdir 'pkg' rescue nil
  FileUtils.rm_rf Dir.glob('pkg/*')
  FileUtils.ln_sf "#{pkg.name}.gem", "pkg/#{spec.name}.gem"
end

task :default => :gem

task :push => :gem do |r|
  `gem push pkg/#{spec.name}.gem`
end

task :install => :gem do |r|
  `gem install pkg/#{spec.name}.gem`
end
