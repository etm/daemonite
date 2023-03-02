# Daemonite

Copyright (C) 2004-2018 Jürgen "eTM" Mangler <juergen.mangler@gmail.com>

Daemonite is freely distributable according to the terms of the GNU Lesser General
Public License 3.0 (see the file 'COPYING').

This code is distributed without any warranty. See the file 'COPYING' for
details.

## Introduction

Deamonite is just syntactic sugar around Process.daemon and argparse, which are
part of ruby. And it gives you a simple loop. And it only works on
*nix, because it runs 'ps ax' (that rhymes). I know, thats clumsy and I'm a lazy
git. Please contribute a better solution if you have to.

## Why

After I reused similar code in about 20 projects I had make it into a gem.
Sorry. Probably much better code out there does the same, but I am too lazy to
search for it. Sorry.

## Usage

Its fairly simple for now:

```ruby
Daemonite.new do |opts|
  opts['bla']

  run do |opts|
    p opts
    sleep 1
  end
end.loop!
```

Everything inside the #new block is executed once. Everything inside the #run
block is executed periodically. So make sure to include sleep to not bog down
your CPU. Or not - i.e. listen to network connections. #loop! finally invokes the
contents of #run continuously.

In order to override or provide your own options:

```ruby
Daemonite.new(opts)
```

Also be aware that a json configuration file $PROGRAM_NAME.sub /\.rb$/, '.conf'
is automatically read, if it exists.

## Usage - Sinatra

Give PID file + daemon start, stop, restart, info functionality to sinatra. Stack overflow overflows with questions about it :-)

```ruby
require 'sinatra/base'
require 'daemonite'
                                                                                                                               
Daemonite.new do |opts|
  on startup do
    opts[:sin] = Sinatra.new do
      set :port, 9327
      Encoding.default_external = "UTF-8"

      get '/' do
        'Hello world!'
      end
    end
  end
  
  run do
    opts[:sin].run!
  end
end.go!
```

## Usage - Alternative

```ruby
daemon = Daemonite.new(opts)
daemon.run do |opts|
  p opts
  sleep 1
end
daemon.loop!
```

## TODO

1. An example how to integrate with EventMachine (replace the #loop!).
