import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.XmlListModel 2.0
import Ubuntu.Components.ListItems 1.3 as ListItem


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
            delegate: ListItem.Standard {

                progression: true
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
                    }
                }
                onClicked: {
                    console.log("Room: " + room_list.model.get(index).name + " clicked")
                }
            }

        }
    }
}


