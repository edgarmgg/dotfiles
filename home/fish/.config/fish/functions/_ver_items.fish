# Imprime todo lo que hay en la biblioteca, un elemento por línea:
#   tipo<TAB>ruta<TAB>serie<TAB>nombre
#   peli       ruta = el vídeo,   serie vacía
#   serie      ruta = su carpeta, serie = nombre = nombre de la serie
#   temporada  ruta = su carpeta, serie = nombre de la serie, nombre = temporada o arco
# El orden es el de biblioteca.conf y, dentro de cada carpeta, el orden natural
# de fish (Zou 2 antes que Zou 10; [490-516] antes que [1058-1125]).
function _ver_items
    set -l config (_biblioteca); or return 1
    # Las carpetas de pelis no cuentan como temporadas de una serie (One Piece/Movies)
    set -l movie_dirs
    for line in $config
        set -l f (string split -m1 \t -- $line)
        test $f[1] = pelis; and set -a movie_dirs $f[2]
    end
    for line in $config
        set -l f (string split -m1 \t -- $line)
        set -l dir $f[2]
        test -d $dir; or continue
        switch $f[1]
            case pelis
                for video in (_ver_videos $dir)
                    printf 'peli\t%s\t\t%s\n' $video (_ver_clean (path change-extension '' -- $video))
                end
                for sub in $dir/*/
                    set sub (string trim -r -c / -- $sub)
                    contains -- $sub $movie_dirs; and continue
                    set -l videos (_ver_videos $sub)
                    set -q videos[1]; or continue
                    printf 'peli\t%s\t\t%s\n' (_ver_biggest $videos) (_ver_clean $sub)
                end
            case series
                for sub in $dir/*/
                    set sub (string trim -r -c / -- $sub)
                    contains -- $sub $movie_dirs; or _ver_show $sub $movie_dirs
                end
            case serie
                _ver_show $dir $movie_dirs
        end
    end
end

# Una serie y sus temporadas. Si tiene episodios sueltos (serie sin temporadas),
# la propia carpeta de la serie es su única "temporada".
function _ver_show --argument-names dir
    set -l movie_dirs $argv[2..-1]
    set -l name (_ver_clean $dir)
    set -l seasons
    set -l loose (_ver_videos $dir)
    set -q loose[1]; and set -a seasons temporada\t$dir\t$name\t$name
    for sub in $dir/*/
        set sub (string trim -r -c / -- $sub)
        contains -- $sub $movie_dirs; and continue
        set -l videos (_ver_videos $sub)
        set -q videos[1]; or continue
        set -a seasons temporada\t$sub\t$name\t(_ver_clean $sub)
    end
    set -q seasons[1]; or return
    printf '%s\n' serie\t$dir\t$name\t$name $seasons
end

# Vídeos de una carpeta (sin entrar en subcarpetas) en orden natural.
function _ver_videos --argument-names dir
    set -l files $dir/*.mkv $dir/*.mp4
    set -q files[1]; and path sort -- $files
end

# El vídeo más grande de la lista (en la carpeta de una peli, la peli y no un extra).
function _ver_biggest
    if test (count $argv) -eq 1
        echo $argv[1]
        return
    end
    stat -c '%s %n' -- $argv | sort -nr | head -n1 | string replace -r '^\d+ ' ''
end

# Nombre para mostrar: sin las etiquetas [..] ni espacios repetidos.
# '[1058-1125] Egghead [Es Sub][1080p]' -> 'Egghead'
function _ver_clean --argument-names name
    path basename -- $name | string replace -ra '\[[^\]]*\]' '' | string replace -ra '\s+' ' ' | string trim
end
