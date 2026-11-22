# dotfiles

My personal dotfiles.

## What's inside

kitty, hyprland, fish, vim... plus my package lists and a script to install it all.

## Install

Needs Arch Linux (the installer uses `pacman` and `yay`).

    git clone https://github.com/edgarmgg/dotfiles.git ~/work/repos/config/dotfiles
    cd ~/work/repos/config/dotfiles && ./install.sh

It is safe to run again, and any file in the way is saved as `.bak.<date>`.

## Notes

- Each folder in `home/` is a [GNU Stow](https://www.gnu.org/software/stow/) package.

## License

[MIT](LICENSE)
