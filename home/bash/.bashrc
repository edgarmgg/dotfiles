# ~/.bashrc: se ejecuta en shells interactivas que no son de login.

case $- in
  *i*) ;;
  *) return ;;
esac

# ---------- Historial ----------
HISTCONTROL=ignoreboth:erasedups
HISTSIZE=100000
HISTFILESIZE=200000
HISTTIMEFORMAT='%F %T '
shopt -s histappend
PROMPT_COMMAND='history -a'${PROMPT_COMMAND:+; $PROMPT_COMMAND}

# ---------- Opciones de shell ----------
shopt -s checkwinsize globstar cdspell autocd
stty -ixon 2>/dev/null   # deja libre Ctrl-S (el <C-s> de vim congelaba la terminal)

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# ---------- Prompt ----------
# Starship si está instalado; si no, un prompt sencillo con color
if command -v starship >/dev/null; then
  eval "$(starship init bash)"
else
  PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
fi

# ---------- Colores ----------
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
fi

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Aviso al terminar un comando largo:  sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# ---------- Alias y ajustes locales ----------
[ -f ~/.bash_aliases ] && . ~/.bash_aliases
[ -f ~/.bash_aliases.local ] && . ~/.bash_aliases.local   # privado, no va al repo

# ---------- Autocompletado ----------
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# ---------- Funciones ----------
# Exporta ajustes de GNOME/VS Code, enseña los cambios y los sube (pide confirmación)
dotsync() {
  local repo="${DOTFILES:-$HOME/dev/dotfiles}"
  ( cd "$repo" || { echo "No existe $repo" >&2; exit 1; }
    ./install.sh export
    git add -A
    if git diff --cached --quiet; then
      echo "Sin cambios que subir"
      exit 0
    fi
    git status --short
    read -rp "¿Commit y push? [s/N] " ans
    [[ $ans == [sSyY]* ]] || { echo "Cancelado (los cambios siguen en stage)"; exit 0; }
    git commit -m "${1:-Actualizar dotfiles}" && git push )
}

# Evita el aviso "Not loading module atk-bridge" de GTK (el módulo lo añade el sistema en /etc/environment.d)
GTK_MODULES=${GTK_MODULES//atk-bridge/}
GTK_MODULES=${GTK_MODULES//::/:}
GTK_MODULES=${GTK_MODULES#:}
GTK_MODULES=${GTK_MODULES%:}
export GTK_MODULES

# ---------- Abrir tmux al iniciar una terminal ----------
# Solo en terminales interactivas, fuera de tmux y fuera de Claude Code.
# Sin "exec": si tmux falla (p. ej. error en ~/.tmux.conf) te quedas en bash.
# Cada terminal es una pestaña de la sesión "main": crea su propia ventana y se
# engancha con una sesión agrupada (comparte ventanas, pero elige la suya).
# La ventana se marca con @owner = tty de la terminal; al cerrarla, el hook
# client-detached de ~/.tmux.conf mata esa ventana (~/.config/tmux/close-owned.sh).
# Al cerrar la última terminal, main queda sin ventanas y tmux termina.
if command -v tmux >/dev/null && [ -z "$TMUX" ] && [ -z "$CLAUDECODE" ] && [ -t 0 ]; then
  if tmux has-session -t main 2>/dev/null; then
    _tmux_win=$(tmux new-window -d -P -F '#{window_id}' -t main: -c "$PWD")
  else
    _tmux_win=$(tmux new-session -d -P -F '#{window_id}' -s main)
  fi
  if [ -n "$_tmux_win" ]; then
    tmux set-option -w -t "$_tmux_win" @owner "$(tty)"
    tmux new-session -t main -s "t$$" \; select-window -t "$_tmux_win" \; set destroy-unattached on && exit
  fi
  unset _tmux_win
fi
