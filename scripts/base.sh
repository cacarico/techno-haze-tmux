#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

main(

    # Cacarico Color Pallette
    icon="💜"
    gray='#7A7276DB'
    pink='#D100AEDB'

tmux set-option -g status-left "#[fg=${grey}]#{?client_prefix,#[bg=${pink}],} ${icon} #[bg=${grey}]#{?client_prefix,#[fg=${pink}]}"

)
