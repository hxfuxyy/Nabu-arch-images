import QtQuick
import QtQuick.Controls
import QtTest
import "../src/quickshell/lock"
Item {
    width: 1000; height: 340
    QtObject {
        id: target
        property string text: ""
        property string submitted: ""
        function insertText(t) { text += t }
        function clear() { text = "" }
        function accepted(t) { submitted = t }
    }
    TouchKeyboard { id: keyboard; anchors.fill: parent; target: target }
    TestCase {
        name: "TouchLockKeyboard"
        when: windowShown
        function buttons(item, label) {
            let found=[];
            if (item instanceof Button && item.text === label) found.push(item);
            for (let child of item.children) found=found.concat(buttons(child,label));
            return found;
        }
        function press(label) {
            wait(50);
            waitForPolish(keyboard);
            let matches=buttons(keyboard,label);
            compare(matches.length,1);
            mouseClick(matches[0]);
        }
        function test_touch_unlock() {
            for (let key of "123456") press(key);
            compare(target.text,"123456");
            press("Unlock"); compare(target.submitted,"123456");
            press("Clear"); compare(target.text,"");
            press("Shift"); press("A"); compare(target.text,"A");
            press("#+="); press("@"); compare(target.text,"A@");
            press("Space"); compare(target.text,"A@ ");
        }
    }
}
