#!/usr/bin/env bash

echo "[+] Starting DB stack..."
docker run -p 5984:5984 -d --rm --name couch couchdb:2
sleep 4
http PUT http://localhost:5984/users
cat db.json | http POST http://localhost:5984/users/_bulk_docs
echo "[+] Done starting DB stack"