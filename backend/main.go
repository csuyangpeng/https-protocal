package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"path/filepath"
)

const (
	addr     = ":8443"
	certFile = "../certs/server.crt"
	keyFile  = "../certs/server.key"
)

func main() {
	if err := checkCerts(); err != nil {
		log.Fatal(err)
	}

	mux := http.NewServeMux()
	mux.HandleFunc("/api/hello", cors(helloHandler))
	mux.HandleFunc("/api/health", cors(healthHandler))

	log.Printf("HTTPS server listening on all interfaces at https://0.0.0.0%s", addr)
	if err := http.ListenAndServeTLS(addr, certFile, keyFile, mux); err != nil {
		log.Fatal(err)
	}
}

func checkCerts() error {
	for _, f := range []string{certFile, keyFile} {
		if _, err := os.Stat(f); os.IsNotExist(err) {
			abs, _ := filepath.Abs(f)
			return &certMissingError{path: abs}
		}
	}
	return nil
}

type certMissingError struct {
	path string
}

func (e *certMissingError) Error() string {
	return "certificate not found: " + e.path + " — run ./scripts/gen-cert.sh first"
}

func cors(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "https://localhost:5173")
		w.Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type")

		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusNoContent)
			return
		}

		next(w, r)
	}
}

func helloHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{
		"message": "Hello from Go HTTPS!",
	})
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{
		"status": "ok",
	})
}
