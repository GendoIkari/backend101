import QtQuick 2.7
import QtQuick.Window 2.2
import "httphelp.js" as Http

Window {
    visible: true
    width: 640
    height: 480
    title: "Gendo's Chat"

    property var chatMessages: []

    function receiveMessages() {
        Http.getJson("http://private-393e7-backend101.apiary-mock.com/v1/messages", function(json) {
            chatMessages = json.messages
        })
    }

    function sendMessage() {
        Http.sendJson("http://private-393e7-backend101.apiary-mock.com/v1/messages", {
            sender: "gendo",
            content: message.text,
        }, function(json) {
            console.log(json)
        })
    }

    Column {
        spacing: 5

        Repeater {
            model: chatMessages
            delegate: Row {
                spacing: 10
                Text {
                    text: modelData.sender
                }
                Text {
                    text: modelData.content
                }
            }
        }
    }

    Rectangle {
        width: 410
        height: 25
        border { width: 1; color: "black" }
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 10

        TextInput {
            id: message
            anchors.fill: parent

            onAccepted: {
                sendMessage()
            }
        }
    }

    Rectangle {
        width: 200
        height: 25
        color: "red"
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 10

        Text {
            text: "Send Message"
            anchors.centerIn: parent
        }

        MouseArea {
            anchors.fill: parent

            onClicked: {
                sendMessage()
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            receiveMessages()
        }
    }
}
