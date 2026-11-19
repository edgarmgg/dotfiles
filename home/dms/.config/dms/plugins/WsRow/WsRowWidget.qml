import QtQuick
import Quickshell.Hyprland
import qs.Common
import qs.DCommon.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    // Cuadrícula 3x3: escritorios 1-3 fila 1, 4-6 fila 2, 7-9 fila 3.
    readonly property int workspaceId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1
    readonly property int row: Math.floor((workspaceId - 1) / 3) + 1
    readonly property int col: (workspaceId - 1) % 3 + 1

    // Número de fila (1-3) y tres píldoras; la de la columna actual se ilumina.
    component Pills: Repeater {
        model: 3

        Rectangle {
            required property int index
            readonly property bool active: index + 1 === root.col
            width: active ? 24 : 12
            height: 12
            radius: height / 2
            color: active ? Theme.primary : Theme.withAlpha(Theme.surfaceText, 0.25)

            Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            Behavior on color { ColorAnimation { duration: 180 } }
        }
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingXS

            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: "~" + root.row
                font.family: "JetBrainsMono Nerd Font Mono"
                font.bold: true
                font.pixelSize: root.textSize
                color: Theme.widgetTextColor
            }

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.spacingXS
                Pills {}
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: Theme.spacingXS

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.spacingXS
                Pills {}
            }

            StyledText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.row
                font.pixelSize: root.textSize
                color: Theme.widgetTextColor
            }
        }
    }
}
