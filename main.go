package main

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
)

type CheckURL struct {
	Name string `json:"name"`
	URL  string `json:"url"`
}

type Response struct {
	Name    string `json:"name"`
	Content string `json:"content"`
}

func main() {
	http.HandleFunc("/check", requestHandler)

	fmt.Println("[+] Starting server on port 8080")
	err := http.ListenAndServe(":8080", nil)

	if err != nil {
		log.Fatal("[-] ", err.Error())
	}

}

func requestHandler(w http.ResponseWriter, r *http.Request) {

	var c CheckURL

	err := json.NewDecoder(r.Body).Decode(&c)

	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	resp, err := http.Get(c.URL)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	defer resp.Body.Close()

	base64Content := base64.StdEncoding.EncodeToString(body)
	res1 := &Response{
		Name:    c.Name,
		Content: base64Content,
	}
	resJson, _ := json.Marshal(res1)
	w.WriteHeader(http.StatusOK)
	w.Write(resJson)

}
