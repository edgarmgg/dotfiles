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

    # Scripts de ~/.local/bin (no son funciones de fish): nombre y descripción a mano.
    # Al crear un script nuevo con -h, añádelo aquí.
    set -l scripts \
        'calendario:Calendario de Edgar: sincroniza con el móvil y se edita por CLI' \
        'copia:Copia de seguridad de mis archivos a Storage con rsync' \
        'cs:Gestor de sesiones de Claude en la terminal' \
        'newex:Crea el esqueleto .h / .cc / _main.cc de un ejercicio y su Makefile' \
        'salud:Informe de salud del portátil' \
        'sysinfo:Información del sistema en texto plano' \
        'tele-refresco:Ajusta el refresco de la tele al de un vídeo' \
        'win:Control de ventanas y escritorios de GNOME'
    for entry in $scripts
        set -a names (string split -m1 : $entry)[1]
    end

    set -l width (math (printf '%s\n' $names | string length | sort -n | tail -1) + 2)
    for name in $names
        set -l desc (functions -Dv $name)[5]
        for entry in $scripts
            set -l parts (string split -m1 : $entry)
            test $parts[1] = $name; and set desc $parts[2]
        end
        test "$desc" = n/a; and set desc '(sin descripción)'
        printf '%s%s%s  %s\n' (set_color cyan) (string pad -r -w $width $name) (set_color normal) $desc
    end
end
