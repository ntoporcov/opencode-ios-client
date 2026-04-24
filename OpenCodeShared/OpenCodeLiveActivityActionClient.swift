import Foundation

private struct OpenCodeLiveActivityPermissionReplyRequest: Encodable {
    let reply: String
    let message: String?
}

private struct OpenCodeLiveActivityQuestionReplyRequest: Encodable {
    let answers: [[String]]
}

struct OpenCodeLiveActivityActionClient {
    let baseURL: String
    let username: String
    let password: String
    var session: URLSession = .shared

    func replyToPermission(requestID: String, reply: String, directory: String?, workspaceID: String?) async throws {
        try await sendNoContent(
            path: "/permission/\(requestID)/reply",
            body: OpenCodeLiveActivityPermissionReplyRequest(reply: reply, message: nil),
            directory: directory,
            workspaceID: workspaceID
        )
    }

    func replyToQuestion(requestID: String, answers: [[String]], directory: String?, workspaceID: String?) async throws {
        try await sendNoContent(
            path: "/question/\(requestID)/reply",
            body: OpenCodeLiveActivityQuestionReplyRequest(answers: answers),
            directory: directory,
            workspaceID: workspaceID
        )
    }

    private func sendNoContent<Body: Encodable>(path: String, body: Body, directory: String?, workspaceID: String?) async throws {
        guard let url = requestURL(path: path, directory: directory, workspaceID: workspaceID) else {
            throw OpenCodeLiveActivityActionError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(basicAuthHeader(), forHTTPHeaderField: "Authorization")

        if let directory, !directory.isEmpty {
            request.setValue(directory, forHTTPHeaderField: "x-opencode-directory")
        }

        request.httpBody = try JSONEncoder().encode(body)

        let (_, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, 200 ..< 300 ~= http.statusCode else {
            throw OpenCodeLiveActivityActionError.requestFailed
        }
    }

    private func requestURL(path: String, directory: String?, workspaceID: String?) -> URL? {
        guard var components = URLComponents(string: baseURL.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            return nil
        }

        components.path = components.path.appending(path)

        var queryItems: [URLQueryItem] = []
        if let directory, !directory.isEmpty {
            queryItems.append(URLQueryItem(name: "directory", value: directory))
        }
        if let workspaceID, !workspaceID.isEmpty {
            queryItems.append(URLQueryItem(name: "workspace", value: workspaceID))
        }
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        return components.url
    }

    private func basicAuthHeader() -> String {
        let credentials = "\(username):\(password)"
        let encoded = Data(credentials.utf8).base64EncodedString()
        return "Basic \(encoded)"
    }
}

enum OpenCodeLiveActivityActionError: Error {
    case invalidURL
    case requestFailed
}
