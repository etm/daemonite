#!/usr/bin/ruby
# encoding: utf-8
#
# This file is part of Daemonite.
#
# Daemonite is free software: you can redistribute it and/or modify it under the terms
# of the GNU General Public License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
#
# Daemonite is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Daemonite (file COPYING in the main directory).  If not, see
# <http://www.gnu.org/licenses/>.

require 'optparse'
require 'psych'

module Daemonism
  @@daemonism_restart = false

  DAEMONISM_DEFAULT_OPTS = {
    :mode            => :debug,
    :verbose         => false,
    :basepath        => File.expand_path(File.dirname($0)),
    :pidfile         => File.basename($0,'.rb') + '.pid',
    :pidwrite        => true,
    :conffile        => File.basename($0,'.rb') + '.conf',
    :runtime_cmds    => [],
    :runtime_opts    => [],
    :runtime_proc    => nil,
    :cmdl_info       => nil,
    :cmdl_parsing    => true,
    :cmdl_operation  => 'start'
  }

  def daemonism(opts={},&block)
    if File.exists?(opts[:basepath] + '/' + opts[:conffile])
      opts.merge!(Psych::load_file(opts[:basepath] + '/' + opts[:conffile]))
    end
    Dir.chdir(opts[:basepath])

    # set more default options and do other stuff
    opts[:block] = nil
    instance_exec(opts,&block) if block_given?

    ########################################################################################################################
    # parse arguments
    ########################################################################################################################
    if opts[:cmdl_parsing]
      opts[:cmdl_operation] = "start"
      ARGV.options { |opt|
        opt.summary_indent = ' ' * 4
        opt.banner = "Usage:\n#{opt.summary_indent}ruby #{$PROGRAM_NAME} [options] start|stop|restart|info" + (opts[:runtime_cmds].length > 0 ? '|' : '') + opts[:runtime_cmds].map{|ro| ro[0]}.join('|') + "\n"
        opts[:runtime_opts].each do |ro|
          opt.on(*ro)
        end
        opt.on("--verbose", "-v", "Do not daemonize. Write ouput to console.") { opts[:verbose] = true }
        opt.on("--config=FNAME", "-cFNAME", "Config file location.") { |f,a|
          if File.exists?(opts[:basepath] + '/' + f)
            opts.merge!(Psych::load_file(opts[:basepath] + '/' + f))
          end
        }
        opt.on("--help", "-h", "This text.") { puts opt; exit }
        opt.separator(opt.summary_indent + "start|stop|restart|info".ljust(opt.summary_width+1) + "Do operation start, stop, restart or get information.")
        opts[:runtime_cmds].each do |ro|
          opt.separator(opt.summary_indent + ro[0].ljust(opt.summary_width+1) + ro[1])
        end
        opt.parse!
      }
      unless (%w{start stop restart info} + opts[:runtime_cmds].map{|ro| ro[0] }).include?(ARGV[0])
        puts ARGV.options
        exit
      end
      opts[:cmdl_operation] = ARGV[0]
      @at_exit = nil
    end
    ########################################################################################################################
    opts[:runtime_proc].call(opts) unless opts[:runtime_proc].nil?

    ########################################################################################################################
    # status and info
    ########################################################################################################################
    pid = File.read(opts[:basepath] + '/' + opts[:pidfile]).to_i rescue pid = -1
    status = Proc.new do
      begin
        Process.getpgid pid
        true
      rescue Errno::ESRCH
        false
      end
    end
    unless @@daemonism_restart
      if opts[:cmdl_operation] == "info" && status.call == false
        puts "Server #{opts[:cmdl_info].nil? ? '' : '(' + opts[:cmdl_info].to_s + ') '}not running"
        exit
      end
      if opts[:cmdl_operation] == "info" && status.call == true
        puts "Server #{opts[:cmdl_info].nil? ? '' : '(' + opts[:cmdl_info].to_s + ') '}running as #{pid}"
        begin
          stats = `ps -o "vsz,rss,lstart,time" -p #{pid}`.split("\n")[1].strip.split(/ +/)
          puts "Virtual:  #{"%0.2f" % (stats[0].to_f/1024)} MiB"
          puts "Resident: #{"%0.2f" % (stats[1].to_f/1024)} MiB"
          puts "Started:  #{stats[2..-2].join(' ')}"
          puts "CPU Time: #{stats.last}"
        rescue
        end
        exit
      end
      if %w{start}.include?(opts[:cmdl_operation]) && status.call == true
        puts "Server #{opts[:cmdl_info].nil? ? '' : '(' + opts[:cmdl_info].to_s + ') '}already started"
        exit
      end
    end

    ########################################################################################################################
    # stop/restart server
    ########################################################################################################################
    unless @@daemonism_restart
      if %w{stop restart}.include?(opts[:cmdl_operation])
        if status.call == false
          puts "Server #{opts[:cmdl_info].nil? ? '' : '(' + opts[:cmdl_info].to_s + ') '}maybe not started?"
        else
          puts "Server #{opts[:cmdl_info].nil? ? '' : '(' + opts[:cmdl_info].to_s + ') '}stopped"
          puts "Waiting while server goes down ..."
          while status.call
            Process.kill "SIGTERM", pid
            sleep 0.3
          end
        end
        exit unless opts[:cmdl_operation] == "restart"
      end
    end

    ########################################################################################################################
    # go through user defined startup thingis
    ########################################################################################################################
    unless @@daemonism_restart
      opts[:runtime_cmds].each do |ro|
        ro[2].call(status.call) if opts[:cmdl_operation] == ro[0]
      end
      @@daemonism_restart = true

      retain = $stdout.dup
      Process.daemon(opts[:basepath]) unless opts[:verbose]
      retain.puts "Server #{opts[:cmdl_info].nil? ? '' : '(' + opts[:cmdl_info].to_s + ') '}started as PID:#{Process.pid}"
      File.write(opts[:basepath] + '/' + opts[:pidfile],Process.pid) # after daemon, so that we get the forked pid
      Dir.chdir(opts[:basepath])
      ::Kernel::at_exit do
        File.unlink(opts[:basepath] + '/' + opts[:pidfile])
        @at_exit.call if @at_exit
      end
    end
  end

  def at_exit(&blk)
    @at_exit = blk
  end
end

class Daemonite
  include Daemonism

  def initialize(opts={},&blk)
    @opts = DAEMONISM_DEFAULT_OPTS.merge(opts)
    daemonism @opts, &blk
  end

  def run(&block)
    @opts[:block] = block
  end

  def go!
    begin
      @opts[:block].call(@opts)
    rescue => e
      puts "Server stopped due to error (PID:#{Process.pid})"
    end
  end

  def loop!
    begin
      loop do
        @opts[:block].call(@opts)
      end unless @opts[:block].nil?
    rescue => e
      puts "Server stopped due to error (PID:#{Process.pid})"
    end
  end
end
