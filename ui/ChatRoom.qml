import QtQuick 2.4
import Ubuntu.Components 1.3
import QtGraphicalEffects 1.0
import Ubuntu.Components.ListItems 1.3 as ListItem
import "components"


Rectangle {
    id: chatroom

    property var model: ListModel {}

    ListView {
        id: chatlist
        clip: true
        anchors.fill: parent
        model: chatroom.model

        delegate: ChatBubble {
            id: chatBubble
            width: parent.width
        }

        onAtYBeginningChanged: {
            if(atYBeginning) {
                console.log("Show more older messages ...")
                // console.log("main: " + py)
                // py.call("backend.mgr.get_next_messages", [], function(start) {
                //     console.log(start)
                // });
            }
        }

        Scrollbar {
            align: Qt.AlignTrailing
        }

        // onCountChanged: {
        //     var newIndex = count - 1 // last index
        //     // jump to end
        //     positionViewAtEnd()
        //     currentIndex = newIndex
        // }
    }
}
