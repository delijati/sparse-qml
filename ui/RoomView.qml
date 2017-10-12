import QtQuick 2.4
import Ubuntu.Components 1.3

BasePage {
    id: roomView
    title: main.activeRoom.name
    visible: false

    property var model: ListModel {}

    ChatRoom {
        id: chatroom
        anchors.bottom: textRect.top
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: {
            bottom: 20
        }
        model: room_view.model
    }

    Rectangle {
        id: textRect
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        TextField {
            id: textEntry
            focus: true
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: 10

            placeholderText: qsTr("Say something...")

            onAccepted: {
               console.log("Sending: " + text)
               py.call("backend.mgr.send_text",  [text], function() {
                  textEntry.text = ''
               })
            }

            Component.onCompleted: {
                textRect.height = height + (anchors.margins * 2);
            }
        }
    }
}
