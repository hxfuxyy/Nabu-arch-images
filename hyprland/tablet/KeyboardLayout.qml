pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
Singleton {
    id: root
    property string layout: "UA"
    property bool ready: false
    property int subscribers: 0
    function subscribe() { subscribers++; poll.running = true; }
    function unsubscribe() { subscribers = Math.max(0, subscribers - 1); }
    function switchNext() { changer.running = true; }
    Process {
        id: changer
        command: ["nabu-layout", "next"]
        onExited: poll.running = true
    }
    Process {
        id: poll
        command: ["nabu-layout", "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                let value = this.text.trim();
                if (["UA", "RU", "US"].indexOf(value) >= 0) { root.layout = value; root.ready = true; }
            }
        }
    }
    Timer { interval: 750; running: root.subscribers > 0; repeat: true; onTriggered: poll.running = true }
}
