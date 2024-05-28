FROM golang:1.17 AS builder

ENV USER=appuser
ENV UID=10001 

RUN adduser \    
    --disabled-password \    
    --gecos "" \    
    --home "/nonexistent" \    
    --shell "/sbin/nologin" \    
    --no-create-home \    
    --uid "${UID}" \    
    "${USER}"

RUN mkdir -p /app

WORKDIR /app

COPY ./main.go /app
COPY ./network.go /app
COPY go.mod /app

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o /go/bin/app

# FROM scratch

# COPY --from=builder /etc/passwd /etc/passwd
# COPY --from=builder /etc/group /etc/group

# COPY --from=builder /go/bin/app /go/bin/app
# USER appuser:appuser

EXPOSE 8080

ENTRYPOINT ["/go/bin/app"]