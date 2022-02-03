const express = require('express')
const fs = require('fs')
const https = require('https')
const bodyParser = require('body-parser')
const fetch = require("cross-fetch");

// The certificates folder
const certsFolder = process.env.CERTS_FOLDER || './certs'
// The desired port or use default 8443
const port = process.env.PORT || 8443

const app = express()
app.use(bodyParser.json());

//Options with the certificate
const options = {
    ca: fs.readFileSync(`${certsFolder}/ca.crt`),
    key: fs.readFileSync(`${certsFolder}/tls.key`),
    cert: fs.readFileSync(`${certsFolder}/tls.crt`),
}

//Main endpoint
app.get('/', (req, res) => {
    res.send('Admission control app for the ActiveMQ cert')
})

app.get('/hc', (req, res) => {
    res.send('ok');
});

app.post('/', (req, res) => {
    if (
        req.body.request === undefined ||
        req.body.request.uid === undefined
    ) {
        console.log('error'); // DEBUGGING
        res.status(400).send();
        return;
    }
    let operation = req.body.request.operation;
    let secret_name = req.body.request.name;
    let target_secret = process.env.TARGET_SECRET || ''

    if (target_secret !== '' && secret_name == target_secret){
        console.log('-------------\n'); // DEBUGGING
        console.log("Certificate is being: " + operation); // DEBUGGING
        //DUMMY POST PETITION
        fetch('https://jsonplaceholder.typicode.com/posts', {
            method: 'POST',
            body: JSON.stringify({
                title: `CERTIFICATE EVENT OCURRED: ${operation}`,
                body: req.body.request.object ? req.body.request.object.metadata : 'Was a delete operation'  ,
                userId: 1,
            }),
            headers: {
                'Content-type': 'application/json; charset=UTF-8',
            },
            })
        .then((response) => response.json())
        .then((json) => console.log(json));
    }

    const { request: { uid } } = req.body;
    res.send({
        apiVersion: 'admission.k8s.io/v1',
        kind: 'AdmissionReview',
        response: {
            uid,
            allowed: true,
        },
    });
});


const server = https.createServer(options, app)

server.listen(port, () => {
    console.log(`Server running on port ${port}/`)
})
