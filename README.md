# Damonite

Copyright (C) 2004-2018 Jürgen "eTM" Mangler <juergen.mangler@gmail.com>

Daemonite is freely distributable according to the terms of the GNU Lesser General
Public License 3.0 (see the file 'COPYING').

This code is distributed without any warranty. See the file 'COPYING' for
details.

## Introduction

Deamonite is just syntactic sugar around Process.daemon and argparse, which are
part of standard ruby. And it gives you a simple loop. And it only works on
*nix because it runs 'ps ax' (that rhymes). I know, thats clumsy and I'm a lazy
git. Please contribute a better solution if you have to.

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
your CPU. Or not - listen to network connections. #loop! finally starts the
contents of #run sequentially.

In order to override options, or provide your own options at start:

```ruby
Daemonite.new(opts)
```

Also be aware that a json configuration file $PROGRAM_NAME.sub /\.rb$/, '.conf'
is automatically read, if it exists.

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
