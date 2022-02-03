const express = require('express')
const fs = require('fs')
const https = require('https')
const bodyParser = require('body-parser')

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
    res.send('Hello World!!!')
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
    console.log('-------------\n'); // DEBUGGING
    console.log("Secret is being: " + req.body.request.operation); // DEBUGGING
    console.log(req.body); // DEBUGGING
    console.log('\nMetadata'); // DEBUGGING
    console.log(req.body.request.object.metadata); // DEBUGGING

    console.log('-------------\n'); // DEBUGGING



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
