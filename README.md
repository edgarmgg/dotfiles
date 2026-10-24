# dotfiles

Personal configuration for Ubuntu 26.04: bash, fish, vim, tmux, git and a custom terminal theme. It installs with a single script and is idempotent.

## Installation

On a fresh machine:

    git clone https://github.com/edgarmgg/dotfiles.git ~/dotfiles
    cd ~/dotfiles && ./install.sh

The script asks which profile to install. To skip the prompt:

    ./install.sh --basic
    ./install.sh --full

It is safe to run it multiple times.

## Profiles

| Profile | Includes |
|---|---|
| **Basic** | apt packages, bash, fish (with fisher), git, vim (with vim-plug and plugins), tmux (with TPM), ssh and VS Code |
| **Full** | Everything in Basic, plus Starship, Nerd Font, Ptyxis palette, fastfetch and GNOME settings |

## Structure

| Path | Contents |
|---|---|
| `home/` | Base configuration, one Stow package per tool |
| `theme/` | Starship, fastfetch, Ptyxis palette and GNOME settings (`dconf`) |
| `packages/` | Lists of apt packages and VS Code extensions |
| `install.sh` | Modular step-by-step installer |

## How it works

`install.sh` installs the packages, Starship and the Nerd Font, and links the files with [GNU Stow](https://www.gnu.org/software/stow/). It then loads the GNOME settings with `dconf load`. If an existing file is in the way, it saves it as `.bak` instead of deleting it.

## Theme

- **Font:** JetBrainsMono Nerd Font, 12 pt
- **Terminal:** Ptyxis, 102x26 window
- **Palette:** custom (`theme-edgar`), with a purple highlight color

## Notes

- The Vim templates (`.cc`, `.h` and Makefile) are in `home/vim/.vim/templates/`.
- Private data is not pushed to the repo: aliases go in `~/.bash_aliases.local` (bash) and `~/.config/fish/local.fish` (fish), and SSH hosts in `~/.ssh/config.local`.
- `dotsync` exports the current GNOME settings and asks for confirmation before committing and pushing. The repo path is given by the `$DOTFILES` variable.

## License

[MIT](LICENSE)
