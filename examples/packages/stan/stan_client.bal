import ballerina/io;
import ballerinax/stan;

stan:Client securedEP = check new("nats://localhost:4222",
    auth = {
        username: "alice",
        password: "alice@123"
        //token: "s3cr3t"
    },
    secureSocket = {
        cert: {
            path: "./resources/keystore/truststore.p12",
            password: "ballerina"
        },
        key: {
            path: "./resources/keystore/keystore.p12",
            password: "ballerina"
        },
        protocol: {
            name: stan:TLS
        }
    }
);

public function main() returns error? {
    string message = "Hello, World!";
    string nuid = check securedEP->publishMessage({
        content: message.toBytes(),
        subject: "demo.security"
    });
    io:println("Publish message successful. NUID: " + nuid);
    check securedEP.close();
}