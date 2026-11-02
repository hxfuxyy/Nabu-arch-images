import QtQuick
import Quickshell
import "../../../"
Item {
    id: root
    property var module: null
    property var widget: module
    property real targetLength: 48
    property bool isFaceVisible: true
    implicitWidth: 48
    implicitHeight: module ? module.thickness : 48
    Rectangle {
        anchors.centerIn: parent
        width: 44; height: 44; radius: 12
        color: area.pressed ? ThemeBackend.accent : ThemeBackend.surface0
        Text { anchors.centerIn: parent; text: "↻"; font.pixelSize: 27; color: ThemeBackend.text }
    }
    MouseArea { id: area; anchors.fill: parent; onClicked: Quickshell.execDetached(["nabu-rotate"]) }
}
