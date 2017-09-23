import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3


Component {
    Dialog {
        id: dialog
        title: i18n.tr("Login")
        text: i18n.tr("Login settings:")

        property real value: 0.0
        property bool progress_visible: false

        Label {
            width: parent.width
            text: i18n.tr("Matrix login settings")
        }

        TextField {
            id: url
            text: "https://matrix.org"
            width: parent.width
        }

        TextField {
            id: username
            text: "@USERNAME:matrix.org"
            width: parent.width
        }

        TextField {
            id: password
            echoMode: TextInput.Password
            text: ""
            width: parent.width
        }

        Row {
            anchors.margins: units.gu(1)
            spacing: units.gu(1)
            width: parent.width

            Button {
                text: i18n.tr("Login")
                color: UbuntuColors.orange
                onClicked: {
                    console.log(url.text);                    
                    py.call("backend.mgr.login", [url.text, username.text, password.text], login_end);
                }
            }


        }
    }
}
