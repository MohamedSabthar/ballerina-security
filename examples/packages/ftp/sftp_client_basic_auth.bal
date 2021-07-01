import ballerina/ftp;
import ballerina/io;

ftp:Client securedEP = new({
    protocol: ftp:SFTP,
    host: "127.0.0.1",
    port: 2222,
    auth: {
        basicAuth: {
            username: "foo",
            password: "pass"
        }
    }
});

public function main() returns error? {
    ftp:FileInfo[] response = check securedEP->list("/upload");
    foreach ftp:FileInfo info in response {
        io:println(info.path);
    }
}