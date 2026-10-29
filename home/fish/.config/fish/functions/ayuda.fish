# Lista mis funciones de fish con su descripción:  ayuda
function ayuda --description 'Lista mis funciones de fish con una línea de explicación'
    set -l dir (status dirname)
    set -l names
    for file in $dir/*.fish
        set -l name (path basename --no-extension $file)
        # Se omiten las privadas (_), las de plugins y las que no quiero ver aquí.
        string match -q '_*' $name; and continue
        contains $name fisher alert onepace; and continue
        set -a names $name
    end

    set -l width (math (printf '%s\n' $names | string length | sort -n | tail -1) + 2)
    for name in $names
        set -l desc (functions -Dv $name)[5]
        test "$desc" = n/a; and set desc '(sin descripción)'
        printf '%s%s%s  %s\n' (set_color cyan) (string pad -r -w $width $name) (set_color normal) $desc
    end
end
