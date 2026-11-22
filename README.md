# dotfiles

My personal config, nothing fancy.

## What's inside

Hyprland, kitty, fish, vim... config, plus my package lists and a script to install it all.

## Install

Needs Arch Linux (the installer uses `pacman` and `yay`).

    git clone https://github.com/edgarmgg/dotfiles.git ~/work/repos/config/dotfiles
    cd ~/work/repos/config/dotfiles && ./install.sh

It is safe to run again, and any file in the way is saved as `.bak.<date>`. To run only some steps: `./install.sh stow dms`.

## Notes

- Each folder in `home/` is a [GNU Stow](https://www.gnu.org/software/stow/) package. `home/dms` is copied instead, because DMS manages its own files.

## License

[MIT](LICENSE)
