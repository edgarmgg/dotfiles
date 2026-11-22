#!/usr/bin/env bash
# Deja Arch + Hyprland con mi configuración.
#   ./install.sh                 paquetes, enlaces, plugins y DMS
#   ./install.sh stow dms        solo esos pasos
#   ./install.sh export          guarda en el repo las listas de paquetes y los ajustes de DMS
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO"

# ---------------------------- Configuración ----------------------------
# Un paquete de stow por herramienta (home/<paquete>)
STOW_PKGS=(bash git vim nvim tmux fish ssh cava fastfetch yazi hypr kitty fuzzel btop starship)
DEFAULT_STEPS=(pacman aur stow dms tpm fisher vimplug)

# DMS reescribe sus ficheros y su carpeta tiene ACL para el greeter: se copia, no se enlaza
DMS_SRC="home/dms/.config/dms"
DMS_DST="$HOME/.config/dms"

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

# Solo bajo demanda: guarda en el repo lo que tienes ahora
step_export() {
  pacman -Qqen > packages/pacman.txt
  pacman -Qqem > packages/aur.txt
  info "exportadas las listas de paquetes"
  if [[ -d $DMS_DST ]]; then
    mkdir -p "$DMS_SRC/plugins"
    cp "$DMS_DST/settings.json" "$DMS_DST/plugin_settings.json" "$DMS_SRC"/
    local p
    for p in "$DMS_SRC"/plugins/*/; do   # solo los plugins que ya están en el repo
      p=$(basename "$p")
      [[ -d $DMS_DST/plugins/$p ]] && cp -rL "$DMS_DST/plugins/$p/." "$DMS_SRC/plugins/$p"/
    done
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
