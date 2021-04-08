# Scenario 1

![scenario-1](./scenario-1.png)

### Description

Simple inventory management system, with 2 secured microservices, and a secured API gateway, which connects to an LDAP user store and trusts OAuth2 authorization server. User `Jane`, the admin, connects to `Admin Microservice` through the REST API of API gateway using HTTPS for management purposes. User `Alice`, a customer, connects to `Inventory Microservice` through the REST API of API gateway using HTTPS for purchasing items. All the APIs are authenticated with different types of authentication mechanisms such as basic auth, JWT auth, OAuth2 etc. and secured with TLS as well.

### Resources

- User Jane (admin) & Alice (customer)
- API Gateway
- Admin and Inventory Microservices
- OAuth 2.0 Authorization Server (STS) [Reference: [WSO2 IS STS](https://hub.docker.com/r/ldclakmal/wso2is-sts)]
- LDAP User Store [Reference: [How to Start OpenLDAP Server with User Data](https://ldclakmal.me/ballerina-security/guides/how-to-start-open-ldap-server.html)]

### Steps

#### Jane (admin)

1. User `Jane` calls basic-auth secured `/admin` **REST API** using username and password.
2. _Ballerina API Gateway_ validates the user against LDAP user store for the scope `Admin`.
3. _Ballerina API Gateway_ issues a self-signed JWT signed by Gateway's private key. The `scp` claim should  have the `Admin` scope. Calls the JWT secured **REST API** of _Ballerina Admin Microservice_ using that JWT.
4. _Ballerina Admin Microservice_ validate the received JWT's signature with Gateway's public key. The value of the `scp` claim should be authorized by the API. The microservice trusts the API Gateway as an issuer (`iss`).

> If successful, `Jane` should get a success responses from `Admin Microservice`. If not, a 401 or 403 response.

#### Alice (customer)

1. User `Alice` gets an access-token with scope `customer` via OAuth2 client credentials grant type or OAuth2 password grant type from _OAuth 2.0 Authorization Server (STS)_.
2. `Alice` calls OAuth2 secured `/order` **REST API** of the _Ballerina API Gateway_ using the received OAuth2 access-token.
3. _Ballerina API Gateway_ introspects the received access-token against the _OAuth 2.0 Authorization Server (STS)_ and validate the `scope` for `customer`.
4. _Ballerina API Gateway_ issues a self-signed JWT signed by Gateway's private key. The `scp` claim should have the `scope` received from the introspection response, which is `customer`. Calls the JWT secured **REST API** of _Ballerina Inventory Microservice_ using that JWT.
5. _Ballerina Inventory Microservice_ validates the received JWT's signature with Gateway's public key. The value of the `scp` claim should be authorized by the API. The microservice trusts the API Gateway as an issuer (`iss`).

> If successful, `Alice` should get a success responses from `Inventory Microservice`. If not, a 401 or 403 response.