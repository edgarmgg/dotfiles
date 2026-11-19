import QtQuick
import Quickshell.Io
import qs.Common
import qs.DCommon.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    // Nivel de señal en dBm (columna 4 de /proc/net/wireless); null si no hay wifi.
    property var dbm: null
    // Misma conversión lineal que NetworkManager (-20 dBm = 100 %).
    readonly property int percent: dbm === null ? 0 : Math.max(0, Math.min(100, 120 + dbm))
    readonly property string label: dbm === null ? "—" : dbm + " dBm"

    Process {
        id: reader
        command: ["awk", "NR==3{print int($4)}", "/proc/net/wireless"]
        stdout: StdioCollector {
            onStreamFinished: {
                const value = text.trim()
                root.dbm = value === "" ? null : parseInt(value)
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: reader.running = true
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingXS

            DIcon {
                anchors.verticalCenter: parent.verticalCenter
                name: "wifi"
                size: root.iconSize
                color: Theme.widgetIconColor
            }

            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: root.label
                font.pixelSize: root.textSize
                color: Theme.widgetTextColor
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: Theme.spacingXXS

            DIcon {
                anchors.horizontalCenter: parent.horizontalCenter
                name: "wifi"
                size: root.iconSize
                color: Theme.widgetIconColor
            }

            StyledText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.dbm === null ? "—" : root.dbm
                font.pixelSize: root.textSize
                color: Theme.widgetTextColor
            }
        }
    }
}
