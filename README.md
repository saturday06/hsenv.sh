hsenv.sh [![Build Status](https://travis-ci.org/saturday06/hsenv.sh.png?branch=master)](https://travis-ci.org/saturday06/hsenv.sh)
=============

The clone of [tmhedberg/hsenv](https://github.com/tmhedberg/hsenv) written in shellscript.

## Installation

1. Check out hsenv.sh into `~/.hsenv`.

    ~~~ sh
    $ git clone https://github.com/saturday06/hsenv.sh.git ~/.hsenv
    ~~~

2. Add `~/.hsenv/bin` to your `$PATH` for access to the `hsenv`
   command-line utility.

    ~~~ sh
    $ export PATH="$HOME/.hsenv/bin:$PATH"
    ~~~

## Still unimplemented features

- cabal's cache sharing
- sanity check
- error handling to be comparable to the origin
