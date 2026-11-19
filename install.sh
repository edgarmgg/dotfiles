#!/usr/bin/env bash
# Deja Arch + Hyprland con mi configuración.
#   ./install.sh                 paquetes, enlaces, plugins y DMS
#   ./install.sh stow dms        solo esos pasos
#   ./install.sh grub            GRUB (pide sudo; hay que hacerlo a propósito)
#   ./install.sh export          guarda en el repo las listas de paquetes y los ajustes de DMS
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO"

# ---------------------------- Configuración ----------------------------
# Un paquete de stow por herramienta (home/<paquete>)
STOW_PKGS=(bash git vim nvim tmux fish ssh cava fastfetch yazi hypr kitty fuzzel btop mpv starship)
DEFAULT_STEPS=(pacman aur stow dms tpm fisher vimplug)

# DMS reescribe sus ficheros y su carpeta tiene ACL para el greeter: se copia, no se enlaza
DMS_SRC="home/dms/.config/dms"
DMS_DST="$HOME/.config/dms"

GRUB_ETC=/etc/grub.d
GRUB_THEME_DST=/boot/grub/themes/edgar

# ------------------------------ Utilidades -----------------------------
log()  { printf '\n\033[1;35m==> %s\033[0m\n' "$*"; }
info() { printf '    %s\n' "$*"; }
warn() { printf '\033[1;33m    ! %s\033[0m\n' "$*"; }
die()  { printf '\033[1;31mError: %s\033[0m\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }
steps_available() { compgen -A function | sed -n 's/^step_//p' | tr '\n' ' '; }
pkg_list() { grep -Ev '^\s*(#|$)' "$1"; }

# stow_pkgs <carpeta> <paquete>...  (mueve a .bak lo que estorbe)
stow_pkgs() {
  local dir=$1; shift
  local pkgs=() pkg file target
  for pkg in "$@"; do
    [[ -d $dir/$pkg ]] || { warn "no existe $dir/$pkg, me lo salto"; continue; }
    pkgs+=("$pkg")
    while IFS= read -r -d '' file; do
      target="$HOME/${file#"$dir/$pkg"/}"
      if [[ -e $target && ! -L $target ]]; then
        mv "$target" "$target.bak.$(date +%Y%m%d-%H%M%S)"
        info "copia de seguridad: $target.bak.*"
      fi
    done < <(find "$dir/$pkg" -type f -print0)
  done
  (( ${#pkgs[@]} )) || return 0
  stow --no-folding -d "$dir" -t "$HOME" "${pkgs[@]}"
  info "enlaces creados: ${pkgs[*]}"
}

# -------------------------------- Pasos --------------------------------
step_pacman() {
  pkg_list packages/pacman.txt | sudo pacman -S --needed -
}

step_aur() {
  if ! have yay; then
    local tmp
    tmp="$(mktemp -d)"
    git clone https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
    (cd "$tmp/yay-bin" && makepkg -si --noconfirm)
  fi
  # los paquetes -debug los genera yay solo, no se instalan aparte
  pkg_list packages/aur.txt | grep -v -- '-debug$' | yay -S --needed -
}

step_stow() {
  stow_pkgs home "${STOW_PKGS[@]}"
  if [[ -d $HOME/.ssh ]]; then chmod 700 "$HOME/.ssh"; fi
  info "mpv: uosc y thumbfast no están en el repo; se instalan aparte (ver README)"
}

step_dms() {
  [[ -d $DMS_SRC ]] || { warn "falta $DMS_SRC, me lo salto"; return; }
  mkdir -p "$DMS_DST"
  if [[ -f $DMS_DST/settings.json ]] && ! cmp -s "$DMS_SRC/settings.json" "$DMS_DST/settings.json"; then
    cp "$DMS_DST/settings.json" "$DMS_DST/settings.json.bak.$(date +%Y%m%d-%H%M%S)"
    info "copia de seguridad de settings.json"
  fi
  cp -r "$DMS_SRC"/. "$DMS_DST"/
  info "DMS copiado a $DMS_DST"
}

step_tpm() {
  local tpm="$HOME/.tmux/plugins/tpm"
  if [[ -d $tpm ]]; then info "tpm ya instalado"; return; fi
  git clone https://github.com/tmux-plugins/tpm "$tpm"
  "$tpm/bin/install_plugins" || warn "no pude instalar los plugins de tmux"
}

step_fisher() {
  have fish || { warn "fish no está instalado, me lo salto"; return; }
  fish -c 'if not functions -q fisher
      curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
      fisher install jorgebucaran/fisher
  end
  fisher update' || warn "fisher falló"
}

step_vimplug() {
  local plug="$HOME/.vim/autoload/plug.vim"
  if [[ ! -f $plug ]]; then
    curl -fLo "$plug" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  fi
  vim -es -u "$HOME/.vimrc" -i NONE -c PlugInstall -c qa || warn "PlugInstall devolvió error"
  info "vim-plug y plugins listos"
}

# Solo bajo demanda (pide sudo). No regenera grub.cfg: eso lo haces tú.
step_grub() {
  [[ -f grub/local.conf ]] || die "falta grub/local.conf con EFI_UUID=<uuid de la EFI de Windows y Ubuntu> (blkid)"
  # shellcheck source=/dev/null
  source grub/local.conf
  [[ -n ${EFI_UUID:-} ]] || die "EFI_UUID vacío en grub/local.conf"

  [[ -f /etc/default/grub.bak ]] || sudo cp /etc/default/grub /etc/default/grub.bak
  sudo install -m 644 grub/default-grub /etc/default/grub

  sudo install -m 755 grub/entries/15_uki "$GRUB_ETC/15_uki"
  sed "s/@EFI_UUID@/$EFI_UUID/" grub/entries/40_custom.in | sudo tee "$GRUB_ETC/40_custom" >/dev/null
  sudo chmod 755 "$GRUB_ETC/40_custom"
  # Arch arranca por UKI (15_uki): 10_linux y 31_efi_bootnext sin permiso de ejecución es intencionado
  sudo chmod -x "$GRUB_ETC/10_linux" "$GRUB_ETC/31_efi_bootnext" 2>/dev/null || true

  if [[ -d grub/theme ]]; then
    sudo mkdir -p "$GRUB_THEME_DST"
    sudo cp -r grub/theme/. "$GRUB_THEME_DST"/
  else
    warn "falta grub/theme (copia de $GRUB_THEME_DST); sin ella GRUB_THEME apunta a nada"
  fi
  info "Hecho. Falta: sudo grub-mkconfig -o /boot/grub/grub.cfg"
}

# Solo bajo demanda: guarda en el repo lo que tienes ahora
step_export() {
  pacman -Qqen > packages/pacman.txt
  pacman -Qqem > packages/aur.txt
  info "exportadas las listas de paquetes"
  if [[ -d $DMS_DST ]]; then
    mkdir -p "$DMS_SRC/plugins"
    cp "$DMS_DST/settings.json" "$DMS_DST/plugin_settings.json" "$DMS_SRC"/
    cp -r "$DMS_DST/plugins/." "$DMS_SRC/plugins"/
    info "exportado DMS"
  fi
}

# ------------------------------ Ejecución ------------------------------
run() {
  local s
  for s in "$@"; do
    declare -F "step_$s" >/dev/null || die "paso desconocido: $s (pasos: $(steps_available))"
    log "$s"
    "step_$s"
  done
}

case "${1:-}" in
  -h|--help) sed -n '2,6p' "$0"; exit 0 ;;
  "")        run "${DEFAULT_STEPS[@]}"; log "Listo. Cierra sesión y vuelve a entrar si algo no se aplica." ;;
  *)         run "$@" ;;
esac
