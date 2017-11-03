import QtQuick 2.4
import Ubuntu.Components 1.3


BasePage {
    id: room_list
    title: i18n.tr('RoomList')
    visible: false

    property var model: ListModel {}

    Column {
        anchors {
            fill: parent
            margins: units.gu(2)
        }

        ListView {
            clip: true
            anchors.fill: parent
            model: room_list.model
            delegate: ListItem {
                Row {
                    id: rowItem
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: units.gu(1)
                    anchors.rightMargin: units.gu(1)
                    spacing: units.gu(2)

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        text: name
                        font.bold: has_unread_messages
                    }
                }
                onClicked: {
                    var room = room_list.model.get(index)
                    console.log("Room: " + room.name + " clicked")
                    room_view.model.clear()
                    py.call("backend.mgr.enter_room",  [room.room_id], function() {
                        console.log("Entered room: " + room.name + " clicked")
                        main.activeRoom = room
                        room.has_unread_messages = false
                        pageStack.push(room_view)
                    }) 
                }
            }
        }
    }
}
