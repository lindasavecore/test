package main

import (
	"fmt"
	"net/http"
	"os"
)

func handler(w http.ResponseWriter, r *http.Request) {
	response := os.Getenv("RESPONSE")
	if len(response) == 0 {
		response = "RESPONSE"
	}

	fmt.Fprintln(w, response)
	fmt.Println("Responding.")
}

func listen(port string) {
	fmt.Printf("Listening on (port %s)\n", port)
	err := http.ListenAndServe(":"+port, nil)
	if err != nil {
		panic("ListenAndServe: " + err.Error())
	}
}

func main() {
	http.HandleFunc("/", handler)
	port := os.Getenv("PORT1")
	if len(port) == 0 {
		port = "8080"
	}
	go listen(port)

	port = os.Getenv("PORT2")
	if len(port) == 0 {
		port = "8888"
	}
	go listen(port)

	select {}
}

