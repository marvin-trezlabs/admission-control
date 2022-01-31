const express = require('express')
const fs = require('fs')
const https = require('https')

// The certificates folder
const certsFolder = process.env.CERTS_FOLDER || './certs'
// The desired port or use default 8443
const port = process.env.PORT || 8443

const app = express()

//Options with the certificate
const options = {
    ca: fs.readFileSync(`${certsFolder}/ca.crt`),
    key: fs.readFileSync(`${certsFolder}/tls.key`),
    cert: fs.readFileSync(`${certsFolder}/tls.crt`),
}

//Main endpoint
app.get('/', (req, res) => {
    res.send('Hello World!')
})

const server = https.createServer(options, app)

server.listen(port, () => {
    console.log(`Server running on port ${port}/`)
})
