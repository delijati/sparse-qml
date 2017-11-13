import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import io.thp.pyotherside 1.4
import "ui"


MainView {
    id: main
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
    property var activeRoom: null
    property var userId: null

    RoomList {
        id: room_list
    }

    RoomView {
        id: room_view
    }

    LoginDialog {
        id: login_dialog

        property var current: null
    }

    Loading {
        id: loading
    }

    function loadRooms() {
        py.call("backend.mgr.get_rooms",  [], function(rooms) {
            room_list.model.clear()
            for (var i=0; i < rooms.length; i++) {
                console.log("Name: " + rooms[i].room_id)
                room_list.model.append(rooms[i]);
            }
            pageStack.pop(loading)
            pageStack.push(room_list)
            console.log("Logged In in gui")
        })
    }

    function login_end(data) {
        // XXX should we rather send signals?        
        pageStack.pop(loading)
        PopupUtils.close(login_dialog.current)
        main.userId = data.user_id
        loadRooms()
    }

    function load_with_token(exists) {
        // this is called when app starts!
        // XXX should we rather send signals?
        if (!exists) {
            login_dialog.current = PopupUtils.open(login_dialog);
        }
        else {
            pageStack.push(loading)
            py.call("backend.mgr.login_with_token",  [], function(data) {
                main.userId = data.user_id
                loadRooms()
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

    function insertionSortByKey(model, key) {
        var length = model.count;

        for(var i = 1; i < length; i++) {
            var temp = model.get(i).event;
            for(var j = i - 1; j >= 0 && model.get(j).event[key] > temp[key]; j--) {
                model.move(j, j+1, 1);
            }
        }
        return model;
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
                room_view.model.append(entry);
                // TODO we sort now on every new message event :/
                insertionSortByKey(room_view.model, "origin_server_ts")
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
