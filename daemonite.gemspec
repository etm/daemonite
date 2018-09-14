Gem::Specification.new do |s|
  s.name             = "daemonite"
  s.version          = "0.4.0"
  s.platform         = Gem::Platform::RUBY
  s.license          = "LGPL-3.0"
  s.summary          = "Daemonite - Process.daemon and argparse wrapper for loopies."

  s.description      = "Daemonite - Process.daemon and argparse wrapper for loopies."

  s.files            = Dir['{example/**/*,lib/*}'] + %w(COPYING Changelog Rakefile daemonite.gemspec README.md AUTHORS TODO)
  s.require_path     = 'lib'
  s.extra_rdoc_files = ['README.md']

  s.required_ruby_version = '>=1.9.3'

  s.authors          = ['Juergen eTM Mangler']
  s.email            = 'juergen.mangler@gmail.com'
  s.homepage         = 'https://github.com/etm/daemonite.rb'
end
