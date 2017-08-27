# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

exec /bin/bash -c 'tmux -2 attach || tmux -2 new'
# Everything after the exec will never get executed. Ever. No chance.
