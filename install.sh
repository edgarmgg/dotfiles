#!/usr/bin/env bash
# Deja Ubuntu/GNOME con mi configuración.
#   ./install.sh                 pregunta qué perfil instalar
#   ./install.sh --basic         perfil básico (sin temas)
#   ./install.sh --full          perfil completo (con temas y GNOME)
#   ./install.sh stow dconf      solo esos pasos
#   ./install.sh export          guarda los ajustes actuales de GNOME en theme/dconf/
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO"

# ---------------------------- Configuración ----------------------------
BASE_PKGS=(bash git vim tmux ssh vscode)        # home/
THEME_PKGS=(ptyxis starship fastfetch)     # theme/home/
BASIC_STEPS=(apt fastfetch stow vimplug vscode)
FULL_STEPS=(apt fastfetch starship font stow stow_theme vimplug dconf vscode)

FONT_ZIP="JetBrainsMono"                   # nombre en Nerd Fonts
FONT_MATCH="JetBrainsMonoNL Nerd"          # cómo la ve fc-list

# theme/dconf/<nombre>.dconf  ->  ruta de dconf
declare -A DCONF=(
  [ptyxis]=/org/gnome/Ptyxis/
  [interface]=/org/gnome/desktop/interface/
  [dock]=/org/gnome/shell/extensions/dash-to-dock/
  [keybindings]=/org/gnome/settings-daemon/plugins/media-keys/
)

# ------------------------------ Utilidades -----------------------------
log()  { printf '\n\033[1;35m==> %s\033[0m\n' "$*"; }
info() { printf '    %s\n' "$*"; }
warn() { printf '\033[1;33m    ! %s\033[0m\n' "$*"; }
die()  { printf '\033[1;31mError: %s\033[0m\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }
steps_available() { compgen -A function | sed -n 's/^step_//p' | tr '\n' ' '; }

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
step_apt() {
  sudo apt-get update
  grep -Ev '^\s*(#|$)' packages/apt.txt | xargs -r sudo apt-get install -y
}

step_fastfetch() {
  if have fastfetch; then info "ya instalado"; return; fi
  sudo apt-get install -y fastfetch || {
    sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch
    sudo apt-get update && sudo apt-get install -y fastfetch
  }
}

step_starship() {
  if have starship; then info "ya instalado"; return; fi
  sudo apt-get install -y starship || curl -sS https://starship.rs/install.sh | sh -s -- -y
}

step_font() {
  if fc-list | grep -qi "$FONT_MATCH"; then info "fuente ya instalada"; return; fi
  local dir="$HOME/.local/share/fonts/JetBrainsMonoNerd" tmp
  tmp="$(mktemp --suffix=.zip)"
  mkdir -p "$dir"
  curl -fL -o "$tmp" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${FONT_ZIP}.zip"
  unzip -oq "$tmp" -d "$dir"
  rm -f "$tmp"
  fc-cache -f
}

step_stow() {
  stow_pkgs home "${BASE_PKGS[@]}"
  if [[ -f home/ssh/.ssh/config ]]; then
    chmod 700 "$HOME/.ssh"
    chmod 600 home/ssh/.ssh/config
  fi
}

step_stow_theme() {
  stow_pkgs theme/home "${THEME_PKGS[@]}"
}

step_dconf() {
  local name f
  for name in "${!DCONF[@]}"; do
    f="theme/dconf/$name.dconf"
    [[ -f $f ]] || { warn "falta $f, me lo salto"; continue; }
    sed "s|/home/edgar|$HOME|g" "$f" | dconf load "${DCONF[$name]}"
    info "cargado: $name"
  done
}

step_vimplug() {
  local plug="$HOME/.vim/autoload/plug.vim"
  if [[ ! -f $plug ]]; then
    curl -fLo "$plug" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  fi
  vim -es -u "$HOME/.vimrc" -i NONE -c PlugInstall -c qa || true
  info "vim-plug y plugins listos"
}

step_vscode() {
  have code || sudo snap install code --classic
  [[ -f packages/vscode.txt ]] || return 0
  local installed ext; installed="$(code --list-extensions)"
  while read -r ext; do
    [[ -z $ext ]] && continue
    grep -qix "$ext" <<< "$installed" || code --install-extension "$ext"
  done < packages/vscode.txt
}

# Solo bajo demanda: guarda en el repo lo que tienes ahora
step_export() {
  local name
  mkdir -p theme/dconf
  for name in "${!DCONF[@]}"; do
    dconf dump "${DCONF[$name]}" > "theme/dconf/$name.dconf"
    info "exportado: theme/dconf/$name.dconf"
  done
  if have code; then
    code --list-extensions > packages/vscode.txt
    info "exportado: packages/vscode.txt"
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

choose_profile() {
  printf '\n  1) Básica    paquetes, bash, git, vim, tmux, ssh y VS Code\n' >&2
  printf '  2) Completa  la básica + Starship, Nerd Font, paleta, fastfetch\n' >&2
  printf '               y ajustes de GNOME\n\n' >&2
  local ans
  read -rp "Elige perfil [1/2]: " ans
  case $ans in
    1) PROFILE=basic ;;
    2) PROFILE=full ;;
    *) die "opción no válida" ;;
  esac
}

DONE_MSG="Listo. Cierra sesión y vuelve a entrar si algo no se aplica."
case "${1:-}" in
  -h|--help) sed -n '2,8p' "$0"; exit 0 ;;
  --basic)   run "${BASIC_STEPS[@]}"; log "$DONE_MSG" ;;
  --full)    run "${FULL_STEPS[@]}";  log "$DONE_MSG" ;;
  "")
    [[ -t 0 ]] || die "no hay terminal interactiva: usa --basic o --full"
    choose_profile
    if [[ $PROFILE == basic ]]; then run "${BASIC_STEPS[@]}"; else run "${FULL_STEPS[@]}"; fi
    log "$DONE_MSG"
    ;;
  *)         run "$@" ;;
esac
