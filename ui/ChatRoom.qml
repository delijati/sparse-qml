import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.XmlListModel 2.0
import QtGraphicalEffects 1.0
import Ubuntu.Components.ListItems 1.3 as ListItem
import "components"


BasePage {
    id: chatroom
    title: i18n.tr('ChatRoom')
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
            model: chatroom.model

            delegate: ChatBubble {
                id: chatBubble
                width: parent.width
            }
        }
    }
}
