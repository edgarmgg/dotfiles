# Solo para shells interactivas (los scripts no cargan esto)
if status is-interactive
    # Sin mensaje de bienvenida
    set -g fish_greeting

    # Alias que se mantienen: solo añaden color y no merece la pena verlos expandidos
    alias ls 'ls --color=auto'
    alias grep 'grep --color=auto'

    # Abreviaturas: se expanden a la vista al pulsar espacio o Enter,
    # así ves y puedes editar el comando real (equivalen a ~/.bashrc y ~/.bash_aliases)
    abbr -a ll 'ls -alF'
    abbr -a la 'ls -A'
    abbr -a l 'ls -CF'
    abbr -a update 'sudo apt update && sudo apt upgrade'
    abbr -a autoremove 'sudo apt autoremove'
    abbr -a vpnstatus 'forticlient vpn status'
    abbr -a vpnoff 'forticlient vpn disconnect'
    abbr -a g++ 'g++ -std=c++17 -Wall -Wextra -Wpedantic -Wshadow -Wconversion'
    abbr -a fullcharge 'sudo tlp fullcharge'
    abbr -a .. 'cd ..'
    abbr -a ... 'cd ../..'

    # Abreviaturas privadas (servidores, usuarios); este fichero no se sube al repo
    test -f ~/.config/fish/local.fish; and source ~/.config/fish/local.fish

    # Prompt: lee ~/.config/starship.toml, el mismo que usa bash
    if command -q starship
        starship init fish | source
    end
end

# ~/.local/bin (markitdown, etc.) en el PATH; fish_add_path no duplica entradas
fish_add_path $HOME/.local/bin
fish_add_path $HOME/bin
