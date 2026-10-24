# dotfiles

Personal config, fish, vim, tmux, git and a custom terminal theme.

## Installation

    git clone https://github.com/edgarmgg/dotfiles.git ~/dotfiles
    cd ~/dotfiles && ./install.sh

The script asks for a profile; to skip the prompt use `./install.sh --basic` or `./install.sh --full`. It is idempotent, and any existing file in the way is saved as `.bak` instead of deleted.

| Profile | Includes |
|---|---|
| **Basic** | apt packages, bash, fish, git, vim, tmux and ssh |
| **Full** | Basic, plus Starship, Nerd Font, Ptyxis palette and GNOME settings |

## Structure

| Path | Contents |
|---|---|
| `home/` | One [GNU Stow](https://www.gnu.org/software/stow/) package per tool |
| `theme/` | Starship, Ptyxis palette and GNOME settings (`dconf`) |
| `packages/` | apt package list |
| `install.sh` | Step-by-step installer |

## Notes

- Private data stays out of the repo: `~/.bash_aliases.local` (bash), `~/.config/fish/local.fish` (fish) and `~/.ssh/config.local` (ssh).
- `dotsync` exports the current GNOME settings and asks before committing and pushing. The repo path comes from `$DOTFILES`.

## License

[MIT](LICENSE)
