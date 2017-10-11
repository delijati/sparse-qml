import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import io.thp.pyotherside 1.4
import "ui"


MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView" 

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "sparseqml.delijati"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    //automaticOrientation: true

    // Removes the old toolbar and enables new features of the new header.
    //useDeprecatedToolbar: false

    width: units.gu(50)
    height: units.gu(75)

    property real spacing: units.gu(1)
    property real margins: units.gu(2)
    property real buttonWidth: units.gu(9)
    property var path: []
    property var activeRoomId: null

    RoomList {
        id: room_list
    }

    ChatRoom {
        id: chatroom
    }

    LoginDialog {
        id: login_dialog

        property var current: null
    }

    Loading {
        id: loading
    }

    function login_end(data) {
        // XXX should we rather send signals?        
        pageStack.pop(loading)
        PopupUtils.close(login_dialog.current)
        py.call("backend.mgr.get_rooms",  [], function(rooms) {
            // login
            console.log(rooms)
            room_list.model.clear()
            for (var i=0; i < rooms.length; i++) {
                console.log("Name: " + rooms[i].room_id)
                room_list.model.append(rooms[i]);
            }
            pageStack.push(room_list)
            console.log("Logged In in gui")
        })
    }

    function load_with_token(exists) {
        // this is called when app starts!
        // XXX should we rather send signals?
        if (!exists) {
            login_dialog.current = PopupUtils.open(login_dialog);
        }
        else {
            pageStack.push(loading)
            py.call("backend.mgr.login_with_token",  [], function(rooms) {
                console.log(rooms)
                room_list.model.clear()
                for (var i=0; i < rooms.length; i++) {
                    console.log("Name: " + rooms[i].name)
                    room_list.model.append(rooms[i]);
                }
                pageStack.pop(loading)
                pageStack.push(room_list)
            })
        }
    }

    PageStack {
        id: pageStack
        anchors.fill: parent

        Component.onCompleted: {
            py.call("backend.file_exists", [], load_with_token)
        }
    }

    Python {
        id: py
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('.'));
            addImportPath(Qt.resolvedUrl('./lib/py'));

            importModule('backend', function(){
                console.log("python loaded");
            });
            setHandler('r.room.message', function (entry) {
                // console.log('New entries from ' + entry.sender + ' with ' + entry.content.body);
                chatroom.model.append(entry);
            });
        }
        onError: {
            console.log('Error: ' + traceback);
            var dialog = PopupUtils.open(errorDialog);
            dialog.traceback = traceback;
        }
    }

    Component {
         id: errorDialog
         Dialog {
             id: dialog
             title: i18n.tr("Error")

             property string traceback: ""

             text: i18n.tr("An error has occured: %1").arg(traceback)

             property string id_

             Button {
                 id: cancelButton
                 text: i18n.tr("Close")
                 onClicked: PopupUtils.close(dialog)
             }
         }
    }
}
