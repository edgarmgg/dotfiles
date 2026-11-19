import QtQuick
import qs.Common
import qs.Services
import qs.DCommon.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    property var popoutService: null

    readonly property real ramGb: DgopService.usedMemoryMB / 1024
    // La temperatura que se muestra es la más alta entre CPU y GPU.
    readonly property real temp: Math.max(DgopService.cpuTemperature || 0, DgopService.widgetGpu(0, null)?.temperature || 0)

    // Mismo clic que las píldoras de CPU y RAM: abre la lista de procesos.
    // El popup de procesos es un LazyLoader inactivo hasta que alguien lo activa
    // (los widgets de DMS lo hacen solos); si no, toggleProcessList no hace nada.
    property var pendingClick: null

    pillClickAction: (x, y, width, section, screen) => {
        DgopService.setSortBy("cpu")
        const args = [x, y, width, section, screen]
        if (PopoutService.processListPopout) {
            PopoutService.toggleProcessList(...args)
            return
        }
        pendingClick = args
        if (PopoutService.processListPopoutLoader)
            PopoutService.processListPopoutLoader.active = true
    }

    Timer {
        interval: 50
        repeat: true
        running: root.pendingClick !== null
        onTriggered: {
            if (!PopoutService.processListPopout)
                return
            const args = root.pendingClick
            root.pendingClick = null
            PopoutService.toggleProcessList(...args)
        }
    }

    Ref {
        service: DgopService
        modules: ["cpu", "memory", "gpu"]
        active: true
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingS

            DIcon {
                anchors.verticalCenter: parent.verticalCenter
                name: "memory_alt"
                size: root.iconSize
                color: Theme.widgetIconColor
            }

            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: root.ramGb ? root.ramGb.toFixed(1) + " GB" : "-- GB"
                font.pixelSize: root.textSize
                color: Theme.widgetTextColor
            }

            DIcon {
                anchors.verticalCenter: parent.verticalCenter
                name: "thermostat"
                size: root.iconSize
                color: Theme.widgetIconColor
            }

            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: root.temp ? Math.round(root.temp) + "°" : "--°"
                font.pixelSize: root.textSize
                color: Theme.widgetTextColor
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: Theme.spacingXXS

            StyledText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.ramGb ? root.ramGb.toFixed(1) : "--"
                font.pixelSize: root.textSize
                color: Theme.widgetTextColor
            }

            StyledText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.temp ? Math.round(root.temp).toString() : "--"
                font.pixelSize: root.textSize
                color: Theme.widgetTextColor
            }
        }
    }
}
