# dotfiles

Personal config for Arch Linux with Hyprland and DankMaterialShell: fish, kitty, Hyprland, DMS, vim, Neovim (LazyVim), tmux, yazi, mpv and GRUB.

## Installation

    git clone https://github.com/edgarmgg/dotfiles.git ~/work/repos/config/dotfiles
    cd ~/work/repos/config/dotfiles && ./install.sh

The script is idempotent, and any existing file in the way is saved as `.bak.<date>` instead of deleted. To run only some steps: `./install.sh stow dms`.

| Step | What it does |
|---|---|
| `pacman` | Installs `packages/pacman.txt` |
| `aur` | Installs yay if missing, then `packages/aur.txt` |
| `stow` | Links every package in `home/` into `$HOME` |
| `dms` | Copies the DMS settings and plugins |
| `tpm`, `fisher`, `vimplug` | tmux, fish and vim plugins |
| `grub` | Opt-in, needs sudo: installs the GRUB config (see below) |
| `export` | Saves the current package lists and DMS settings into the repo |

## Structure

| Path | Contents |
|---|---|
| `home/` | One [GNU Stow](https://www.gnu.org/software/stow/) package per tool |
| `packages/` | `pacman.txt` (official repos) and `aur.txt` (AUR) |
| `grub/` | `/etc/default/grub`, `/etc/grub.d` entries (`grub/entries/`) and the boot menu theme |
| `install.sh` | Step-by-step installer |

## Notes

- Hyprland is configured in Lua (`home/hypr/.config/hypr/hyprland.lua`). The files in `hypr/dms/` are written by DMS and may be replaced by it.
- DMS keeps its own settings and its folder has an ACL for the greeter, so `home/dms` is copied (`dms` and `export` steps), not linked.
- mpv: `uosc` and `thumbfast` are third-party and not in the repo; install them separately.
- GRUB: Arch boots through a UKI (`15_uki`), and Windows is chainloaded from `40_custom`. Put the UUID of its EFI partition in `grub/local.conf` (`EFI_UUID=...`, ignored by git). `./install.sh grub` copies everything but does not regenerate the menu: run `sudo grub-mkconfig -o /boot/grub/grub.cfg` afterwards.
- Private data stays out of the repo: `~/.bash_aliases.local` (bash), `~/.config/fish/local.fish` (fish), `~/.ssh/config.local` (ssh), `~/.vim/email.local` (vim) and `~/.config/fish/functions-local/` with its completions (phone, Raspberry Pi, router and TV helpers).
- `dotsync` exports the package lists and DMS settings, then asks before committing and pushing. The repo path comes from `$DOTFILES`.

## License

[MIT](LICENSE)
