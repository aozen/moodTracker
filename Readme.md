# MoodTracker

MoodTracker is a simple project that allows Apple Watch users to share their mood through emojis in real-time. It consists of:

1. **Backend**: A Go server with REST API and WebSocket support.
2. **Frontend**: A watchOS app built with SwiftUI to interact with the backend.

## Features

- **Real-time Updates**: Emojis are broadcasted to all connected devices using WebSocket.
- **REST API**: Provides endpoints for retrieving and updating the current emoji.
- **Simple UI**: An intuitive watchOS interface to select and display moods.

---

## Backend (Go)

The backend handles requests from the watchOS app and broadcasts mood updates using WebSocket.

### Endpoints

#### REST API

- **GET `/api/mood`**
    - Fetches the latest emoji.
    - **Response**:
        ```json
        {
            "emoji": "😀"
        }
        ```
    - **Error**: Responds with `404 Not Found` if no emoji is set.

- **POST `/api/mood`**
    - Updates the current emoji.
    - **Request Body**:
        ```json
        {
            "emoji": "😎"
        }
        ```
    - **Response**:
        ```json
        {
            "message": "Emoji updated successfully"
        }
        ```

#### WebSocket

- **WS `/ws`**
    - Connect to receive real-time updates.
    - **Broadcast Message**:
    ```json
    {
        "emoji": "🤔"
    }
    ```

### How to Run

1. Clone the backend repository:
    ```bash
    git clone <repository-url>
    cd <repository-folder>
    ```

1. Install dependencies:
    ```bash
    go mod tidy
    ```

1. Run the server:
    ```bash
    go run main.go
    ```

1.	The server will be available at http://localhost:3000.

---

## watchOS App (Swift)

The watchOS app provides an interface to send and receive mood updates.

Key Features
- **Emoji Selector**: Choose from a set of predefined emojis to share your mood.
- **Live Updates**: Displays the latest mood received from the backend in real-time.
- **Error Handling**: Displays an error message if unable to connect to the backend.

## How to Use

1.	Update the backend URL in ContentView.swift:

    ```bash
    let backendWebSocketURL = "wss://your-backend-url/ws" // WebSocket URL
    ```

    Similarly, update the sendMoodToBackend URL for REST API calls.

1. Deploy the app to your Apple Watch via Xcode.

1. Open the app, select an emoji, and watch it update on connected devices in real-time.

---

## Complete Workflow

1.	Start the Backend: Ensure the Go server is running.
2.	Run the watchOS App: Deploy the app to an Apple Watch.
3.	Share Your Mood:
    - Select an emoji in the app to send it to the backend.
    - Other devices (connected via WebSocket) receive the update instantly.

---

- The backend must be deployed and accessible from the watchOS app (update URLs accordingly).
- Consider adding authentication and HTTPS for production.

## License

This project is open-source. Feel free to use, modify, and improve.

```bash
This README covers both components of the project and provides clear instructions for running and using them. Let me know if you'd like any adjustments! 😊
```