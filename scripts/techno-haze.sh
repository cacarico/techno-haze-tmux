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

bind_shell() {
    key="$1"
    command="$2"

    tmux bind-key -n "$key" run-shell "$command"
}

bind_key() {
    key="$1"
    command="$2"

    tmux bind-key -n "$key" "$command"
}

bind_vim() {
    key="$1"
    command="$2"
    command2="$3"

    is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
        | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"

    tmux bind-key -n "$key" if-shell "$is_vim" "$command" "$command2"
}

setup_keys() {

    # Reload configuration
    tmux bind r source-file ~/.config/tmux/tmux.conf \; display '~/.tmux.conf reloaded'

    # Bind Ctrl + Alt + s to swap panes
    tmux bind-key -n C-M-s command-prompt -p "Swap window:","With Window:" "swap-window -s '%1' -t '%2'"

    # Opens project Folder
    tmux bind-key -n 'M-o' send-keys "exec $CURRENT_DIR/project.sh" Enter


    # Integration between Nvim and Tmux to change panes naturally
    # pane resizing
    bind_vim 'M-h' 'send-keys M-h' 'select-pane -L'
    bind_vim 'M-j' 'send-keys M-j' 'select-pane -D'
    bind_vim 'M-k' 'send-keys M-k' 'select-pane -U'
    bind_vim 'M-l' 'send-keys M-l' 'select-pane -R'
    bind_vim 'M-H' 'send-keys M-H' 'resize-pane -L 4'
    bind_vim 'M-J' 'send-keys M-J' 'resize-pane -D 2'
    bind_vim 'M-K' 'send-keys M-K' 'resize-pane -U 2'
    bind_vim 'M-L' 'send-keys M-L' 'resize-pane -R 4'
    bind_vim 'M-C-h' 'send-keys M-C-h' 'run-shell "tmux select-pane -L \\; swap-pane -d -s #D"'
    bind_vim 'M-C-k' 'send-keys M-C-k' 'run-shell "tmux select-pane -U \\; swap-pane -d -s #D"'
    bind_vim 'M-C-j' 'send-keys M-C-j' 'run-shell "tmux select-pane -D \\; swap-pane -d -s #D"'
    bind_vim 'M-C-l' 'send-keys M-C-l' 'run-shell "tmux select-pane -R \\; swap-pane -d -s #D"'

    # Swap window x with windows y
    bind-key -n C-M-s command-prompt -p "Swap window:","With Window:" "swap-window -s '%1' -t '%2'"

    # Select window from 1 to 10
    for i in $(seq 0 9); do
        tmux bind-key -n "M-$i" select-window -t "$i"
        if [ "$i" == 0 ]; then
            bind_key 'M-0' 'select-window -t 10'
        fi
    done

    # split current window vertically
    tmux bind '-' 'split-window -v'
    tmux bind '\' 'split-window -h'
    tmux bind -n 'M-Tab' 'next-window' # select previous window
    tmux bind -n 'M-BTab' 'previous-window'     # select next window

    # Zoom Window
    tmux unbind z
    tmux bind 'a' 'resize-pane -Z'
}

setup_config() {
    # Set Prefix to alt
    tmux set-option -g prefix M-a
    tmux bind-key M-a send-prefix

    # Enable mouse integration
    tmux set -g mouse on

    # Enable 255 color terminal
    tmux set -g default-terminal "screen-256color"

    # Sets history-limit to 5000 lines
    tmux set -g history-limit 5000

    # set vim mode
    tmux set-window-option -g mode-keys vi

    ## -- display -------------------------------------------------------------------

    tmux set -g base-index 1           # Start index in 1
    tmux set -g renumber-windows on    # Renumber windows
    tmux set -g display-panes-time 801 # Slightly longer pane indicators display time
    tmux set -g display-time 1000      # Slightly longer status messages display time
    tmux set -g status-interval 10     # Redraw status every 10 seconds
    tmux setw -g pane-base-index 1     # Make pane numbering consistent with windows
    tmux setw -g automatic-rename off  #



    # Fix image preview (https://yazi-rs.github.io/docs/image-preview#tmux-users)
    tmux set -g allow-passthrough on
    tmux set -ga update-environment TERM
    tmux set -ga update-environment TERM_PROGRAM
}

main() {
    setup_config
    setup_keys

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
