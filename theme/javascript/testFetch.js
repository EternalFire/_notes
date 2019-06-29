function test1() {

    const myRequest = new Request("")

    fetch(myRequest)
    .then(response => {
        if (response.status === 200) {
            return response.json();
        } else {
            throw new Error('Something went wrong on api server!');
        }
    })
    .then(response => {
        console.debug(response);
        // ...
    }).catch(error => {
        console.error(error);
    });
}

/////////////////////////////////////////////////////////////////////
function test2() {

    // fetch(myRequest).then(response => console.log(response))
    var myRequest = new Request("https://api.jikan.moe/v3/season/2019/spring")
    fetch(myRequest).then(response => (response.json())).then(response => console.log(response))

    fetch(myRequest).then(response => (console.log(response.status, response.statusText)))
}


function test3() {
    /*
        ETag: "588e0914b48360b22ad2ef5eeed1f943"

        Header:
            If-None-Match: ETag_Value
    */
    var initHeader = {
        method: "GET",
        headers: {
            // "If-None-Match": "588e0914b48360b22ad2ef5eeed1f943",
        },
        mode: "cors",
        cache: "default",
    }
    var myRequest = new Request("https://api.jikan.moe/v3/season/2019/spring", initHeader)
    fetch(myRequest).then(response => (console.log(response.status, response.statusText)))
}

test3()