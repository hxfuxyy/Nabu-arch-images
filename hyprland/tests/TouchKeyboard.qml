import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
Rectangle {
    id: keyboard
    required property var target
    property bool shifted: false
    property bool symbols: false
    color: "#18202b"
    radius: 16
    implicitHeight: 250
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 5
        Repeater {
            model: keyboard.symbols ? ["1234567890", "!@#$%^&*()", "_+-=[]{};:", "\'\",.<>/?`~\\|№"] : ["1234567890", "qwertyuiop", "asdfghjkl", "zxcvbnm"]
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 3
                required property string modelData
                Repeater {
                    model: modelData.split("")
                    Button {
                        required property string modelData
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        focusPolicy: Qt.NoFocus
                        text: keyboard.shifted ? modelData.toUpperCase() : modelData
                        onClicked: if (keyboard.target) keyboard.target.insertText(text)
                    }
                }
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Button { text: "Shift"; focusPolicy: Qt.NoFocus; onClicked: keyboard.shifted = !keyboard.shifted }
            Button { text: "#+="; focusPolicy: Qt.NoFocus; onClicked: keyboard.symbols = !keyboard.symbols }
            Button { text: "Clear"; focusPolicy: Qt.NoFocus; onClicked: if (keyboard.target) keyboard.target.clear() }
            Button { text: "Space"; focusPolicy: Qt.NoFocus; Layout.fillWidth: true; onClicked: if (keyboard.target) keyboard.target.insertText(" ") }
            Button { text: "Unlock"; focusPolicy: Qt.NoFocus; onClicked: if (keyboard.target) keyboard.target.accepted(keyboard.target.text) }
        }
    }
}
