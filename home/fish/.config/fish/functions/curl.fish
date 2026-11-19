# curl normal; "curl monitor" muestra las barras de progreso de los curl en marcha
function curl --description 'curl; "curl monitor" = barras de progreso de las descargas en marcha'
    if test "$argv[1]" = monitor
        command curl-monitor $argv[2..-1]
    else if contains -- "$argv[1]" -h --help; and test (count $argv) -eq 1
        command curl $argv
        echo
        echo 'Extra de esta función:'
        echo '  curl monitor   barras de progreso de las descargas curl en marcha (-h para su ayuda)'
    else
        command curl $argv
    end
end
