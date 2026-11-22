# dotfiles

My personal config.

## What's inside

Config for kitty, fish, nvim, hyprland and so on.
Also my package lists and a script to install it all.

```
.
├── home/          one folder per tool, mirrors $HOME
├── packages/      pacman.txt and aur.txt
└── install.sh
```

## Install

    git clone https://github.com/edgarmgg/dotfiles.git ~/work/repos/config/dotfiles
    cd ~/work/repos/config/dotfiles && ./install.sh

It is safe to run again, and any file in the way is saved as `.bak.<date>`.

## Notes

- Needs Arch Linux: the installer uses `pacman` and `yay` to install the packages.
- Each folder in `home/` is a [GNU Stow](https://www.gnu.org/software/stow/) package.

## License

[MIT](LICENSE)
