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
