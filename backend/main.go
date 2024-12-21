package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"sync"

	"github.com/gorilla/mux"
	"github.com/gorilla/websocket"
)

type Mood struct {
	Emoji string `json:"emoji"`
}

var currentEmoji string
var clients = make(map[*websocket.Conn]bool)
var mutex = &sync.Mutex{}
var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

func main() {
	router := mux.NewRouter()

	// API endpoints
	router.HandleFunc("/api/mood", handlePostMood).Methods("POST")
	router.HandleFunc("/api/mood", handleGetMood).Methods("GET")

	// WebSocket endpoint
	router.HandleFunc("/ws", handleWebSocket)

	// Start the server
	port := "3000"
	fmt.Printf("MoodTracker backend is running at http://localhost:%s\n", port)
	http.ListenAndServe(":"+port, router)
}

func handlePostMood(w http.ResponseWriter, r *http.Request) {
	var mood Mood
	err := json.NewDecoder(r.Body).Decode(&mood)
	if err != nil || mood.Emoji == "" {
		fmt.Println("err", err)
		http.Error(w, "Invalid request payload", http.StatusBadRequest)
		return
	}
    fmt.Println("POST", mood)
	mutex.Lock()
	currentEmoji = mood.Emoji
	mutex.Unlock()

	notifyClients(mood.Emoji)

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"message": "Emoji updated successfully"})
}

func handleGetMood(w http.ResponseWriter, r *http.Request) {
	mutex.Lock()
	defer mutex.Unlock()

	if currentEmoji == "" {
		http.Error(w, "No emoji set yet", http.StatusNotFound)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(Mood{Emoji: currentEmoji})
}

func handleWebSocket(w http.ResponseWriter, r *http.Request) {
    conn, err := upgrader.Upgrade(w, r, nil)
    if err != nil {
        http.Error(w, "Could not open WebSocket connection", http.StatusBadRequest)
        return
    }

    mutex.Lock()
    clients[conn] = true
    mutex.Unlock()

    fmt.Println("New WebSocket connection established")

    // Clean up on close
    defer func() {
        mutex.Lock()
        delete(clients, conn)
        mutex.Unlock()
        conn.Close()
        fmt.Println("WebSocket disconnected")
    }()

    for {
        _, message, err := conn.ReadMessage()
        if err != nil {
            fmt.Println("Error reading message:", err)
            break
        }

        fmt.Printf("Received message: %s\n", message)
    }
}

func notifyClients(emoji string) {
	message := map[string]string{"emoji": emoji}
	data, _ := json.Marshal(message)

	mutex.Lock()
	defer mutex.Unlock()

	for conn := range clients {
		err := conn.WriteMessage(websocket.TextMessage, data)
		if err != nil {
			conn.Close()
			delete(clients, conn)
		}
	}
}