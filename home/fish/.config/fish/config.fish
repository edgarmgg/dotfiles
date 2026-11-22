# Funciones y completados privados (móvil, Pi, router, tele): viven en carpetas ignoradas por git, fuera del repo público
set -l fish_local $HOME/.config/fish
contains $fish_local/functions-local $fish_function_path; or set -a fish_function_path $fish_local/functions-local
contains $fish_local/completions-local $fish_complete_path; or set -a fish_complete_path $fish_local/completions-local

# Solo para shells interactivas (los scripts no cargan esto)
if status is-interactive
    # Sin mensaje de bienvenida
    set -g fish_greeting

    # Alias que se mantienen: solo añaden color y no merece la pena verlos expandidos
    alias ls 'ls --color=auto'
    alias grep 'grep --color=auto'
    alias tmatrix 'command tmatrix --mode=dense -C cyan -c default --fade -s 10 -f 0.3,1 -l 6,35 -G 5,20 -g 0,25'

    # Abreviaturas: se expanden a la vista al pulsar espacio o Enter,
    # así ves y puedes editar el comando real (equivalen a ~/.bashrc y ~/.bash_aliases)
    abbr -a ll 'ls -alF'
    abbr -a la 'ls -A'
    abbr -a l 'ls -CF'
    abbr -a update 'sudo pacman -Syu'
    abbr -a autoremove 'sudo pacman -Rns (pacman -Qdtq)'
    abbr -a g++ 'g++ -std=c++17 -Wall -Wextra -Wpedantic -Wshadow -Wconversion'
    abbr -a .. 'cd ..'
    abbr -a ... 'cd ../..'
    abbr -a killw 'tmux killw'
    abbr -a neww 'tmux neww'
    abbr -a killp 'tmux killp'

    # Abreviaturas privadas (servidores, usuarios); este fichero no se sube al repo
    test -f ~/.config/fish/local.fish; and source ~/.config/fish/local.fish

    # Prompt: lee ~/.config/starship.toml, el mismo que usa bash
    if command -q starship
        starship init fish | source
    end

    # zoxide: `cd dir` salta al directorio más usado que coincida (aprende con cada cd); `cdi` es la versión interactiva (fzf)
    if command -q zoxide
        zoxide init fish --cmd cd | source
    end
end

# ~/.local/bin (markitdown, etc.) en el PATH; fish_add_path no duplica entradas
fish_add_path $HOME/.local/bin
fish_add_path $HOME/bin
# bun (el instalador solo lo añade a .bashrc)
fish_add_path $HOME/.bun/bin

# done.fish: un comando terminado con SIGTERM (143), p. ej. `claude` cerrado desde cs, no es un fallo:
# se avisa como "Cerrado" y con urgencia normal. El resto se avisa como siempre.
set -g __done_notification_command 'set -l urgency normal; if test $exit_status -eq 143; set title "Cerrado después de $humanized_duration"; else if test $exit_status -ne 0; set urgency critical; end; notify-send --hint=int:transient:1 --urgency=$urgency --icon=utilities-terminal --app-name=fish --expire-time=$__done_notification_duration "$title" "$message"'

# Editor por defecto (Yazi, git, etc. lo leen de aquí; sin esto caen a vim).
set -gx EDITOR nvim
set -gx VISUAL nvim
