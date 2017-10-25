function sendJson(url, jsonText, username, password, callback) {
    var json = JSON.stringify(jsonText)
    var http = new XMLHttpRequest()

    http.open("POST", url, true);
    http.setRequestHeader("Content-type", "application/json");
    http.setRequestHeader('Authorization','Basic ' + Qt.btoa(username + ":" + password));

    http.onreadystatechange = function() {
        if (http.readyState == XMLHttpRequest.DONE) {
            if (http.status == 200) {
                if (callback)
                    callback(JSON.parse(http.responseText))
            } else {
                console.log("error: " + http.status)
            }
        }
    }

    http.send(json);
}

function getJson(url, callback) {
    var http = new XMLHttpRequest()

    http.open("GET", url, true);
    http.setRequestHeader("Content-type", "application/json");

    http.onreadystatechange = function() {
        if (http.readyState == XMLHttpRequest.DONE) {
            if (http.status == 200) {
                var json = JSON.parse(http.responseText)
                callback(json)
            } else {
                console.log("error: " + http.status)
            }
        }
    }

    http.send();
}
