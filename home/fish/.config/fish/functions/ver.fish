# ver: busca en la biblioteca (pelis y series, con los arcos de One Pace) y lo abre en mpv.
#   ver her            peli: la reproduce
#   ver <serie>        serie: sigue por donde ibas
#   ver <serie> t2     temporada 2 de la serie (también s2, T02...)
#   ver                menú interactivo (fzf): flechas o escribir para filtrar, Enter reproduce
#   -i/--inicio        empieza desde el primer episodio aunque ya lo hayas visto
#   -s/--serie NOMBRE  busca solo entre las temporadas de esa serie
# Qué carpeta es qué se define en ~/.config/biblioteca.conf.
function ver --description 'Busca en la biblioteca (pelis y series) y lo reproduce en mpv'
    argparse h/help i/inicio 's/serie=' -- $argv; or return 1
    if set -q _flag_help
        echo 'uso: ver [-i] [búsqueda...] [tN]'
        echo '  ver                menú: Pelis o Series (flechas o escribir para filtrar, ".." vuelve atrás)'
        echo '  ver her            peli: la reproduce'
        echo '  ver <serie>        serie: sigue por donde ibas'
        echo '  ver <serie> t2     temporada 2 de la serie (también s2, T02...)'
        echo '  -i, --inicio       empieza desde el primer episodio aunque ya lo hayas visto'
        echo '  -s, --serie NOMBRE busca solo entre las temporadas de esa serie'
        echo '  -h, --help         muestra esta ayuda'
        return 0
    end
    set -l all (_ver_items); or return 1
    set -l items $all
    set -l inicio (set -q _flag_inicio; and echo 1; or echo 0)

    # Con --serie solo valen las temporadas de esa serie
    if set -q _flag_serie
        set -l want (_ver_norm $_flag_serie)
        set items
        for item in $all
            set -l f (string split \t -- $item)
            test $f[1] = temporada; and test (_ver_norm $f[3]) = "$want"; and set -a items $item
        end
        if not set -q items[1]
            echo "No encuentro la serie $_flag_serie en la biblioteca"
            return 1
        end
    end

    # 'tN' o 'sN' al final: temporada N de la serie buscada
    set -l season_num
    if test (count $argv) -gt 1; and string match -qir '^[ts]\d+$' -- $argv[-1]
        set season_num (string match -r '\d+' -- $argv[-1] | string replace -r '^0+(?=\d)' '')
        set -e argv[-1]
        set items (string match -- 'serie*' $items)
    end

    # Sin búsqueda ni --serie: navegación por menús (Pelis/Series, con ".." para volver)
    if not set -q argv[1]; and not set -q _flag_serie
        _ver_browse $inicio $all
        return
    end

    set -l matches
    if set -q argv[1]
        set matches (_ver_match $items -- $argv)
    else
        set matches $items
    end

    if not set -q matches[1]
        echo "Nada coincide con: $argv"
        return 1
    end
    set -l choice $matches[1]
    set -l from_menu 0
    if test (count $matches) -gt 1
        set choice (_ver_menu $matches); or return 1
        set from_menu 1
    end

    set -l f (string split \t -- $choice)
    switch $f[1]
        case peli
            echo "▶ $f[4]"
            mpv --fs -- $f[2]
        case temporada
            _ver_play_season $inicio $f[2] "$f[3] › $f[4]"
        case serie
            set -l seasons
            for item in $all
                set -l s (string split \t -- $item)
                test $s[1] = temporada; or continue
                test $s[2] = $f[2]; or test (path dirname -- $s[2]) = $f[2]; and set -a seasons $item
            end
            if test -n "$season_num"
                _ver_play_number $inicio $season_num $seasons
            else if test $from_menu -eq 1; and test (count $seasons) -gt 1
                # Elegida en el menú: deja elegir temporada o seguir por donde iba
                _ver_pick_season $inicio $seasons
                test $status -le 2
            else
                _ver_play_show $inicio $seasons
            end
    end
end

# Normaliza para comparar: sin [etiquetas], en minúsculas y solo letras y números.
function _ver_norm
    string replace -ra '\[[^\]]*\]' '' -- $argv | string lower | string replace -ra '[^a-z0-9]' ''
end

# Imprime los elementos que encajan con la búsqueda, de más a menos exacto; se queda
# con el primer nivel que dé algún resultado:
#   1) el título es la búsqueda (sin contar el año): 'her' -> Her (2013), no There Will Be Blood
#   2) el título empieza por la búsqueda: 'dress' -> Dressrosa
#   3) todas las palabras aparecen en el nombre ('one piece egghead')
#   4) las letras aparecen en orden (admite letras que falten)
# Una temporada solo encaja en 3 y 4 si su propio nombre encaja, para que 'one piece'
# no saque todos los arcos.
function _ver_match
    set -l split (contains -i -- -- $argv)
    set -l items $argv[1..(math $split - 1)]
    set -l words (_ver_norm $argv[(math $split + 1)..-1] | string match -v '')
    set -l query (string join '' -- $words)
    test -n "$query"; or return
    set -l letters (string join '.*' (string split '' -- $query))
    for tier in exact prefix words letters
        set -l found
        for item in $items
            set -l f (string split \t -- $item)
            # Serie sin temporadas: su única "temporada" es la propia serie, no la repitas
            if test $f[1] = temporada; and contains -- serie\t$f[2]\t$f[3]\t$f[3] $items
                continue
            end
            set -l name (_ver_norm $f[4])
            set -l title (_ver_norm (string replace -r '\s*\(\d{4}\)$' '' -- $f[4]))
            set -l full $name
            test $f[1] = temporada; and set full (_ver_norm "$f[3] $f[4]")
            switch $tier
                case exact
                    test "$query" = "$title"; or test "$query" = "$name"; and set -a found $item
                case prefix
                    string match -q -- "$query*" $title; and set -a found $item
                case words
                    set -l ok 1
                    for w in $words
                        string match -q -- "*$w*" $full; or set ok 0
                    end
                    if test $f[1] = temporada
                        set -l own 0
                        for w in $words
                            string match -q -- "*$w*" $name; and set own 1
                        end
                        test $own -eq 1; or set ok 0
                    end
                    test $ok -eq 1; and set -a found $item
                case letters
                    string match -qr -- $letters $name; and set -a found $item
            end
        end
        if set -q found[1]
            printf '%s\n' $found
            return
        end
    end
end

# Menú numerado; imprime el elemento elegido.
function _ver_menu
    set -l back 0
    if test "$argv[1]" = --back
        set back 1
        set -e argv[1]
    end
    set -l lines
    test $back -eq 1; and set lines "0\t.."
    for i in (seq (count $argv))
        set -l f (string split \t -- $argv[$i])
        switch $f[1]
            case peli
                set -a lines "$i\tPeli · $f[4]"
            case serie
                set -a lines "$i\tSerie · $f[4]"
            case temporada
                set -a lines "$i\t$f[3] › "(path basename -- $f[2])
        end
    end
    set -l pick (printf '%b\n' $lines | fzf --delimiter='\t' --with-nth=2 --prompt='ver › ' --height=~50% --reverse --no-sort); or return 1
    set -l n (string split -f1 \t -- $pick)
    test $n -eq 0; and return 2  # ".." (volver)
    echo $argv[$n]
end

# Menús encadenados: Pelis/Series -> lista (con ".." arriba) -> temporada si la serie tiene varias.
# Devuelve 0 al reproducir algo y 1 si se cancela con Esc.
function _ver_browse --argument-names inicio
    set -l all $argv[2..-1]
    while true
        set -l kind (printf 'Pelis\nSeries\n' | fzf --prompt='ver › ' --height=~30% --reverse); or return 1
        set -l want peli
        test "$kind" = Series; and set want serie
        set -l list (string match -- "$want*" $all)
        while true
            set -l choice (_ver_menu --back $list)
            set -l st $status
            test $st -eq 2; and break
            test $st -ne 0; and return 1
            set -l f (string split \t -- $choice)
            if test $f[1] = peli
                echo "▶ $f[4]"
                mpv --fs -- $f[2]
                return
            end
            set -l seasons
            for item in $all
                set -l s (string split \t -- $item)
                test $s[1] = temporada; or continue
                test $s[2] = $f[2]; or test (path dirname -- $s[2]) = $f[2]; and set -a seasons $item
            end
            if test (count $seasons) -le 1
                _ver_play_show $inicio $seasons
                return
            end
            _ver_pick_season $inicio $seasons
            test $status -eq 2; and continue  # ".." -> vuelve a la lista de series
            return 0
        end
    end
end

# Menú de temporadas de una serie: ".." (devuelve 2), seguir por donde ibas o una temporada.
function _ver_pick_season --argument-names inicio
    set -l seasons $argv[2..-1]
    set -l lines "0\t.." "c\t▶ Continuar por donde ibas"
    for i in (seq (count $seasons))
        set -a lines "$i\t"(path basename -- (string split \t -- $seasons[$i])[2])
    end
    set -l pick (printf '%b\n' $lines | fzf --delimiter='\t' --with-nth=2 --prompt='temporada › ' --height=~50% --reverse --no-sort); or return 1
    set -l n (string split -f1 \t -- $pick)
    switch $n
        case 0
            return 2
        case c
            _ver_play_show $inicio $seasons
        case '*'
            set -l s (string split \t -- $seasons[$n])
            _ver_play_season $inicio $s[2] "$s[3] › $s[4]"
    end
end

# Reproduce una temporada o arco desde su primer episodio sin ver (o el 1 con inicio=1).
function _ver_play_season --argument-names inicio dir label
    set -l episodes (_ver_videos $dir)
    set -l watched (cat ~/.local/state/mpv/watched.txt 2>/dev/null)
    set -l start 1
    if test $inicio -eq 0
        set start 0
        for i in (seq (count $episodes))
            if not contains -- $episodes[$i] $watched
                set start $i
                break
            end
        end
        if test $start -eq 0
            echo "Terminado: empiezo desde el principio"
            set start 1
        end
    end
    _ver_mpv $start $label $episodes
end

# Temporada número N: la que se llame 'Temporada N', 'Season N', 'S0N'... o si no, la N.ª
function _ver_play_number --argument-names inicio num
    set -l seasons $argv[3..-1]
    set -l pick
    set -l numbered 0
    for item in $seasons
        set -l f (string split \t -- $item)
        string match -qir '\b(temporada|season|t|s)\s*\d+\b' -- $f[4]; and set numbered 1
        if string match -qir "\b(temporada|season|t|s)\s*0*$num\b" -- $f[4]
            set pick $item
            break
        end
    end
    # Si las carpetas no llevan número de temporada (arcos), cuenta por posición
    test -z "$pick"; and test $numbered -eq 0; and set -q seasons[$num]; and set pick $seasons[$num]
    if test -z "$pick"
        echo "La serie no tiene temporada $num"
        return 1
    end
    set -l f (string split \t -- $pick)
    _ver_play_season $inicio $f[2] "$f[3] › $f[4]"
end

# Serie entera: sigue por el episodio siguiente al último que terminaste (el más
# reciente de watched.txt) saltando los ya vistos; sin historial, el primero sin ver.
function _ver_play_show --argument-names inicio
    set -l seasons $argv[2..-1]
    # Todos los episodios seguidos, y de qué temporada es cada uno
    set -l episodes
    set -l owner
    for i in (seq (count $seasons))
        for ep in (_ver_videos (string split \t -- $seasons[$i])[2])
            set -a episodes $ep
            set -a owner $i
        end
    end
    set -q episodes[1]; or return 1
    set -l watched (cat ~/.local/state/mpv/watched.txt 2>/dev/null)

    set -l target 1
    if test $inicio -eq 0
        set -l last 0
        for line in $watched[-1..1]
            set -l pos (contains -i -- $line $episodes); and set last $pos; and break
        end
        set target 0
        for i in (seq (math $last + 1) (count $episodes))
            if not contains -- $episodes[$i] $watched
                set target $i
                break
            end
        end
        if test $target -eq 0 -a $last -gt 0
            # Lo siguiente está todo visto: el primero sin ver de antes
            for i in (seq $last)
                if not contains -- $episodes[$i] $watched
                    set target $i
                    break
                end
            end
        end
        if test $target -eq 0
            echo "Serie terminada: empiezo desde el principio"
            set target 1
        end
    end

    set -l s $owner[$target]
    set -l f (string split \t -- $seasons[$s])
    set -l in_season (_ver_videos $f[2])
    _ver_mpv (contains -i -- $episodes[$target] $in_season) "$f[3] › $f[4]" $in_season
end

# Lanza mpv con la temporada como lista, empezando en el episodio start (desde 1).
function _ver_mpv --argument-names start label
    set -l episodes $argv[3..-1]
    set label (string replace -r '^(.+) › \1$' '$1' -- $label)  # serie sin temporadas
    echo "▶ $label (episodio $start de "(count $episodes)")"
    mpv --fs --playlist-start=(math $start - 1) -- $episodes
end

complete -c ver -f -s i -l inicio -d 'Empezar desde el primer episodio'
complete -c ver -f -a '(_ver_items 2>/dev/null | string split -f4 \t | sort -u)'
