#!/bin/sh
# Cierra la ventana que creó la terminal cuyo tty es $1 (se llama desde el
# hook client-detached de ~/.tmux.conf). Una terminal = una pestaña de tmux.
[ -n "$1" ] || exit 0
tmux list-windows -a -F '#{window_id} #{@owner}' | while read -r id owner; do
  [ "$owner" = "$1" ] && tmux kill-window -t "$id"
done
exit 0
