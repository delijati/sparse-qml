import QtQuick 2.4
import Ubuntu.Components 1.3


Rectangle {
    id: loading
    width: parent.width
    anchors.centerIn: parent
    visible: false

    Column {
        width: parent.width / 2
        anchors.centerIn: parent
        spacing: 18

        Item {
            width: parent.width
            height: 1
        }

        Label {
            font.pixelSize: units.gu(4)
            text: qsTr("Sparse QML")
            color: "#888"
        }

        Item {
            width: 256
            height: 256
            anchors.horizontalCenter: parent.horizontalCenter
            Image {
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                antialiasing: true
                source: "../images/sparse-qml.png"
            }
        }

        ActivityIndicator {
            z:2
            visible: true
            running: true
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
