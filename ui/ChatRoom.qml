import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.XmlListModel 2.0
import QtGraphicalEffects 1.0
import Ubuntu.Components.ListItems 1.3 as ListItem


BasePage {
    id: chatroom
    title: i18n.tr('ChatRoom')
    visible: false

    property var model: ListModel {}

    function getBody(event) {
        return event.sender + " -> "  + event.content.body 
        // if (event.content.hasOwnProperty("formatted_body")) {
        //     return event.content.formatted_body
        // } else {
        //     return event.sender + " -> "  + event.content.body 
        // }
    }

    Column {
        anchors {
            fill: parent
            margins: units.gu(2)
        }

        ListView {
            clip: true
            anchors.fill: parent
            model: chatroom.model
            delegate: ListItem.Standard {

                Row {
                    id: rowItem
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: units.gu(1)
                    anchors.rightMargin: units.gu(1)
                    spacing: units.gu(2)

                    Image {
                        id: avatarImg
                        source: event.avatar_url
                        visible: true
                        sourceSize.width: 24
                        sourceSize.height: 24
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: getBody(event)
                    }
                }
            }
        }
    }
}
