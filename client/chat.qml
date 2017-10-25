import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import "httphelp.js" as Http

Window {
    id: root
    visible: true
    width: 640
    height: 480
    title: "Gendo's Chat"

    property string username
    property string password
    property var chatMessages: []

    function receiveMessages() {
        Http.getJson("http://localhost:5000/v1/messages", function(json) {
            chatMessages = json.messages
        })
    }

    function sendMessage(textInput) {
        Http.sendJson("http://localhost:5000/v1/messages", {
            sender: "gendo",
            content: textInput.text,
        }, root.username, root.password, function(json) {
            console.log(json)
        })
        textInput.text = ""
    }

    StackView {
        id: stack
        anchors.fill: parent

        initialItem: loginView
    }

    Component {
        id: loginView

        Item {
            Row {
                spacing: 5
                anchors.centerIn: parent

                TextField {
                    id: textUsername
                }

                TextField {
                    id: textPassword
                }

                Button {
                    text: 'Login'
                    onClicked: {
                        root.username = textUsername.text
                        root.password = textPassword.text

                        Http.sendJson("http://localhost:5000/v1/users", {
                            name: root.username,
                            password: root.password,
                        }, root.username, root.password, function(json) {
                            stack.push(chatView)
                        })
                    }
                }
            }
        }
    }

    Component {
        id: chatView

        Item {
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
                        root.sendMessage(message)
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
                        root.sendMessage(message)
                    }
                }
            }

            Timer {
                interval: 1000
                running: true
                repeat: true

                onTriggered: {
                    root.receiveMessages()
                }
            }
        }
    }
}
