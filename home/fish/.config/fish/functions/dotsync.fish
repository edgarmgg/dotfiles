# Exporta paquetes y ajustes de DMS, enseña los cambios y los sube (pide confirmación)
function dotsync --description 'Exporta y sube los dotfiles'
    if contains -- "$argv[1]" -h --help
        echo 'uso: dotsync [mensaje de commit]'
        echo '  Exporta las listas de paquetes y los ajustes de DMS al repo de dotfiles, enseña los cambios y, si confirmas, hace commit y push.'
        echo '  Variable DOTFILES: ruta alternativa del repo.'
        return 0
    end
    set -l repo $HOME/work/repos/config/dotfiles
    set -q DOTFILES; and set repo $DOTFILES
    test -d $repo; or begin
        echo "No existe $repo" >&2
        return 1
    end
    pushd $repo
    ./install.sh export
    if test -z "$(git status --porcelain)"
        echo "Sin cambios que subir"
        popd
        return 0
    end
    git status --short
    read -l -P "¿Commit y push? [s/N] " ans
    if string match -qir '^[sy]' -- $ans
        set -l msg "Actualizar dotfiles"
        set -q argv[1]; and set msg $argv[1]
        git add -A; and git commit -m $msg; and git push
    else
        echo "Cancelado (no se ha añadido nada al stage)"
    end
    popd
end
