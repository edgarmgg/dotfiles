# Exporta paquetes y ajustes de DMS, enseña los cambios de los dos repos y los sube (pide confirmación en cada uno)
function dotsync --description 'Exporta y sube los dotfiles (público y privado)'
    if contains -- "$argv[1]" -h --help
        echo 'uso: dotsync [mensaje de commit]'
        echo '  Exporta las listas de paquetes y los ajustes de DMS al repo público.'
        echo '  Después, para cada repo (público y privado) enseña los cambios y, si confirmas, hace commit y push.'
        echo '  Variables DOTFILES y DOTFILES_PRIVATE: rutas alternativas de los repos.'
        return 0
    end
    set -l public $HOME/work/repos/config/dotfiles
    set -q DOTFILES; and set public $DOTFILES
    set -l private $HOME/work/repos/config/dotfiles-private
    set -q DOTFILES_PRIVATE; and set private $DOTFILES_PRIVATE
    set -l msg "Actualizar dotfiles"
    set -q argv[1]; and set msg $argv[1]

    test -d $public; or begin
        echo "No existe $public" >&2
        return 1
    end
    pushd $public
    ./install.sh export
    popd

    for repo in $public $private
        test -d $repo; or begin
            echo "No existe $repo, me lo salto" >&2
            continue
        end
        pushd $repo
        echo
        echo "== "(basename $repo)
        if test -z "$(git status --porcelain)"
            echo "Sin cambios que subir"
        else
            git status --short
            read -l -P "¿Commit y push de "(basename $repo)"? [s/N] " ans
            if string match -qir '^[sy]' -- $ans
                git add -A; and git commit -m $msg; and git push
            else
                echo "Cancelado (no se ha añadido nada al stage)"
            end
        end
        popd
    end
end
