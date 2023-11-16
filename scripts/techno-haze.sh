#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

main() {

    # Set configurations
    icon-inactive=$(get_tmux_option "@technohaze" purple-heart)
    icon-active=$(get_tmux_option "@technohaze" pink-heart)


    # Icons
    purple_heart="A"
    pink_heart="🩷"

    # Cacarico Color Pallette
    gray='#7A7276DB'
    pink='#D100AEDB'
    purple='#792EC0'

      # set length
      tmux set-option -g status-left-length 100
      tmux set-option -g status-right-length 100


      tmux set-option -g status-left " #{?client_prefix,${icon_active},${icon_inactive}}"
      tmux set-option -g status-right "banana"
      tmux set-option -g status-style "bg=default"

  }

  main
