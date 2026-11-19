# Aviso al terminar un comando largo:  sleep 10; _alert
function _alert --description 'Notificación con el resultado del último comando'
    set -l last $status
    if contains -- "$argv[1]" -h --help
        echo 'uso: <comando>; _alert'
        echo '  Lanza una notificación con el último comando y un icono según si acabó bien o mal.'
        echo '  Ejemplo: sleep 10; _alert'
        return 0
    end
    set -l icon error
    test $last -eq 0; and set icon terminal
    notify-send --urgency=low -i $icon (history --max=1)
end
