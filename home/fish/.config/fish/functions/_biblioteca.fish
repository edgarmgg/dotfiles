# Lee ~/.config/biblioteca.conf (o $BIBLIOTECA_CONF, para pruebas) y escribe una línea por carpeta de la biblioteca:
#   tipo<TAB>ruta absoluta      (tipo: pelis, series o serie)
function _biblioteca
    set -l conf ~/.config/biblioteca.conf
    set -q BIBLIOTECA_CONF; and set conf $BIBLIOTECA_CONF
    if not test -r $conf
        echo "No encuentro $conf" >&2
        return 1
    end
    set -l root
    set -l entries
    for line in (string trim < $conf)
        test -n "$line"; or continue
        string match -q '#*' -- $line; and continue
        # m[2] = tipo, m[3] = ruta (puede llevar espacios)
        set -l m (string match -r '^(\S+)\s+(.+)$' -- $line); or continue
        if test $m[2] = raiz
            set root $m[3]
        else
            set -a entries $m[2]\t$m[3]
        end
    end
    if test -z "$root"; or not test -d $root
        echo "No encuentro la biblioteca $root (¿está montado Storage?)" >&2
        return 1
    end
    for entry in $entries
        set -l f (string split -m1 \t -- $entry)
        string match -q '/*' -- $f[2]; or set f[2] $root/$f[2]
        printf '%s\t%s\n' $f[1] $f[2]
    end
end
