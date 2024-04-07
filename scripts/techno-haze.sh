#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export LC_ALL=en_US.UTF-8

#TODO Create own function, maybe a utils.sh makes sense.
get_tmux_option() {
  local option=$1
  local default_value=$2
  local option_value=$(tmux show-option -gqv "$option")
  if [ -z "$option_value" ]; then
    echo $default_value
  else
    echo $option_value
  fi
}

main() {

    # Set configurations
    icon_inactive=$(get_tmux_option "@technohaze-icon" purple-heart)
    icon_active=$(get_tmux_option "@technohaze-icon-active" pink-heart)
    plugins=$(get_tmux_option "@technohaze-plugins" "cpu ram")

    # Icons
    purple_heart="💜"
    pink_heart="💗"

    # Cacarico Color Pallette
    gray='#7A7276DB'
    pink='#D100AEDB'
    purple='#792EC0'
    dark_blue='#33658A'
    light_purple='#ff2bff'
    rose='#33658A'
    red='#E06666'


    # Set Colors
    window_color="$purple"
    plugin_color="$red"

    # set length
    tmux set-option -g status-left-length 100
    tmux set-option -g status-right-length 100

    # Reset status right
    tmux set-option -g status-right ''


    script=''
    for plugin in ${plugins}; do
        case $plugin in
            "cpu")
                script+="#($CURRENT_DIR/cpu.sh) "
                ;;
            "ram")
                script+="#($CURRENT_DIR/ram.sh) "
                ;;
            *)
                script="NOT FOUND"
        esac
    done

    tmux set-option -g status-left " #{?client_prefix,${pink_heart},${purple_heart}} "
    tmux set-option -g status-style "bg=default"
    tmux set-option -g status-right "#[fg=${plugin_color}]$script"
    tmux set-option -g message-style "bg=default,fg=${red}"

    tmux set-option -g pane-border-style "bg=default fg=${dark_blue}"
    tmux set-option -g pane-active-border-style "bg=default fg=${dark_blue}"

    tmux set-window-option -g window-status-format "#I.#W${flags}"
    tmux set-window-option -g window-status-current-format "#[fg=${window_color}]#I.#W"


}

main
