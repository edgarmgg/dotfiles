# Aviso al terminar un comando largo:  sleep 10; alert
function alert --description 'Notificación con el resultado del último comando'
    set -l last $status
    set -l icon error
    test $last -eq 0; and set icon terminal
    notify-send --urgency=low -i $icon (history --max=1)
end
