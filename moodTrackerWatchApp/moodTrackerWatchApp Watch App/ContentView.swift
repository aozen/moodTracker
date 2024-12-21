//
//  ContentView.swift
//  moodTrackerWatchApp Watch App
//
//  Created by Ali Özen on 14.12.2024.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedEmoji: String = "🙂"
    @State private var receivedEmoji: String = ""
    @State private var showError: Bool = false

    let emojis = ["🙂", "😢", "😡", "😂", "😍", "🤔"]
    //let backendWebSocketURL = "ws://localhost:3000/ws" // WebSocket URL
    //let backendWebSocketURL = "ws://136.244.82.243:3000/ws" // WebSocket URL
    let backendWebSocketURL = "wss://mood.aliozendev.com/ws" // WebSocket URL


    var body: some View {
        VStack {
            if !receivedEmoji.isEmpty {
                Text("Received mood:")
                    .font(.headline)
                Text(receivedEmoji)
                    .font(.largeTitle)
                    .padding()
            }

            Text("Choose your mood")
                .font(.headline)
                .padding()

            ScrollView(.horizontal) {
                HStack(spacing: 15) {
                    ForEach(emojis, id: \.self) { emoji in
                        Button(action: {
                            selectedEmoji = emoji
                            sendMoodToBackend(emoji: emoji)
                        }) {
                            Text(emoji)
                                .font(.largeTitle)
                                .padding()
                                .background(Circle().fill(Color.blue.opacity(0.2)))
                        }
                    }
                }
            }
            .padding()

            if showError {
                Text("Error connecting to server.")
                    .foregroundColor(.red)
                    .font(.footnote)
            }
        }
        .onAppear {
            connectToWebSocket()
        }
    }

    func sendMoodToBackend(emoji: String) {
        //guard let url = URL(string: "http://localhost:3000/api/mood") else { return }
        //guard let url = URL(string: "http://136.244.82.243:3000/api/mood") else { return }
        guard let url = URL(string: "https://mood.aliozendev.com/api/mood") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload = ["emoji": emoji]
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload, options: [])

        URLSession.shared.dataTask(with: request).resume()
    }

    func connectToWebSocket() {
        guard let url = URL(string: backendWebSocketURL) else {
            showError = true
            return
        }

        let task = URLSession.shared.webSocketTask(with: url)

        task.resume()
        listenToWebSocket(task: task)
    }

    func listenToWebSocket(task: URLSessionWebSocketTask) {
        task.receive { result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    if let data = text.data(using: .utf8),
                       let json = try? JSONSerialization.jsonObject(with: data, options: []),
                       let dict = json as? [String: String],
                       let emoji = dict["emoji"] {
                        DispatchQueue.main.async {
                            receivedEmoji = emoji
                        }
                    }
                default:
                    print("Non-string message received.")
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    showError = true
                }
                print("WebSocket error: \(error)")
            }

            listenToWebSocket(task: task)
        }
    }
}

#Preview {
    ContentView()
}
