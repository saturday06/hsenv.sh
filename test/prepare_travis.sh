#!/bin/sh

cd `dirname $0`
case `../libexec/config.guess | awk -F- '{print $3}'` in
  linux)
    sudo apt-get update -qq
    sudo apt-get install -qq ash bash dash ksh mksh posh zsh
    ;;
  darwin*)
    brew update
    brew install dash ksh mksh xz
    ;;
esac
