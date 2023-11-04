#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

main() {

    # Cacarico Color Pallette
    icon="💜"
    icon_toggled="🩷"
    gray='#7A7276DB'
    pink='#D100AEDB'

      # set length
      tmux set-option -g status-left-length 100
      tmux set-option -g status-right-length 100


      tmux set-option -g status-left " #{?client_prefix,${icon_toggled},${icon}} "
      tmux set-option -g status-style "bg=default"
}

main
