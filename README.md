# Techno Haze Tmux

A minimalistic setup for tmux focused on productivity in a clutter-free layout.

## Overview

The Techno Haze Tmux offers a clean and minimalist interface tailored for enhanced productivity. With a focus on simplicity and efficiency, this theme provides a clutter-free layout to help you stay focused on your tasks.

## Key Features

- **Window Management**: Easily create new sessions and switch between windows.
- **Pane Navigation**: Effortlessly move and resize panes for optimal organization.
- **Ready to Use**: It comes packed with keybidings to let you start using tmux in productive way from the day 0

## Installation
To install the Techno Haze Tmux, you can use [TPM](https://github.com/tmux-plugins/tpm) or clone the repo localy.

### Installing with Tmux Plugin Manager


Update your `~/.tmux.conf` file to use the plugin:

```
set -g @plugin 'cacarico/techno-haze-tmux'
```

Install plugins using `prefix + I` (NOTE: prefix by default is ctrl + b)

### Installing Manually

```
git clone https://github.com/cacarico/techno-haze-tmux.git ~/.config/tmux/plugins/techno-haze-tmux
```

And add the following line to your  `~/.tmux.conf` file:

```
run-shell "~/.config/tmux/plugins/techno-haze-tmux/techno-haze.tmux"
```

Install plugins using `prefix + I` (NOTE: prefix by default is ctrl + b)

## Usage

Once installed, you can start using the Techno Haze Tmux immediately. Here are some key bindings to get you started:

- **Alt + a**: Prefix key for tmux commands.

### Keybidings

| Key Combination | Functionality                 |
|-----------------|-------------------------------|
| Prefix + a      | Zoom the current panel        |
| Prefix + r      | Reloads the tmux configuration.
| Prefix + -      | Splits plane horizontally
| Prefix + \      | Splits plane vertically
| A-Tab      | Switch to window to the right
| A-S-Tab    | Switch to window to the left                               |
| A-C-s      | Swap window x with window y                                |
| A-C-h      | Swap pane with the pane to the left                        |
| A-C-k      | Swap pane with the pane above                              |
| A-C-j      | Swap pane with the pane below                              |
| A-C-l      | Swap pane with the pane to the right                       |
| A-h        | Select pane to the left                                    |
| A-j        | Select pane downward                                       |
| A-k        | Select pane upward                                         |
| A-l        | Select pane to the right                                   |
| A-H        | Resize pane to the left by 4 columns                       |
| A-J        | Resize pane downward by 2 rows                             |
| A-K        | Resize pane upward by 2 rows                               |
| A-L        | Resize pane to the right by 4 columns                      |
| A-0 to M-9 | Switch to windows 1 to 10, with M-0 switching to window 10 |

For more details on usage and customization options, refer to the theme documentation or the comments within the `techno-haze.tmux` file.

## Contributions

Contributions to the Techno Haze Tmux are welcome! Feel free to submit pull requests, report issues, or suggest improvements via the project's GitHub repository.

## License

This project is licensed under the [MIT License](LICENSE), allowing for both personal and commercial use with attribution. See the LICENSE file for details.

Enjoy your clutter-free tmux experience with the Techno Haze Tmux Theme!
