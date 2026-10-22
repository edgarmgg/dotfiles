# Exporta ajustes de GNOME/VS Code, enseña los cambios y los sube (pide confirmación)
function dotsync --description 'Exporta y sube los dotfiles'
    set -l repo $HOME/dev/dotfiles
    set -q DOTFILES; and set repo $DOTFILES
    test -d $repo; or begin
        echo "No existe $repo" >&2
        return 1
    end
    pushd $repo
    ./install.sh export
    git add -A
    if git diff --cached --quiet
        echo "Sin cambios que subir"
        popd
        return 0
    end
    git status --short
    read -l -P "¿Commit y push? [s/N] " ans
    if string match -qir '^[sy]' -- $ans
        set -l msg "Actualizar dotfiles"
        set -q argv[1]; and set msg $argv[1]
        git commit -m $msg; and git push
    else
        echo "Cancelado (los cambios siguen en stage)"
    end
    popd
end
