import Foundation

enum OpenCodeInsecureConnectionKind: Sendable {
    case localNetwork
    case nonLocal
}

struct OpenCodeServerConfig: Equatable, Codable, Sendable {
    var name: String = ""
    var iconName: String = ""
    var baseURL: String = "http://127.0.0.1:4096"
    var username: String = "opencode"
    var password: String = ""

    var sanitizedBaseURL: URL? {
        URL(string: baseURL.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    var trimmedBaseURL: String {
        baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var trimmedUsername: String {
        username.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var trimmedIconName: String {
        iconName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var recentServerID: String {
        "\(trimmedBaseURL.lowercased())|\(trimmedUsername.lowercased())"
    }

    var displayHost: String {
        sanitizedBaseURL?.host() ?? trimmedBaseURL
    }

    var displayName: String {
        trimmedName.isEmpty ? displayHost : trimmedName
    }

    var displayIconName: String {
        trimmedIconName.isEmpty ? "server.rack" : trimmedIconName
    }

    var usesInsecureHTTP: Bool {
        sanitizedBaseURL?.scheme?.lowercased() == "http"
    }

    var insecureConnectionKind: OpenCodeInsecureConnectionKind? {
        guard usesInsecureHTTP else { return nil }
        guard let host = sanitizedBaseURL?.host()?.lowercased(), !host.isEmpty else {
            return .nonLocal
        }

        if host == "localhost" || host.hasSuffix(".local") {
            return .localNetwork
        }

        if let ipv4 = IPv4Address(host), ipv4.isLocalNetworkLike {
            return .localNetwork
        }

        return .nonLocal
    }

    var hasCredentials: Bool {
        !trimmedBaseURL.isEmpty && !trimmedUsername.isEmpty
    }
}

private struct IPv4Address {
    let octets: [UInt8]

    init?(_ string: String) {
        let parts = string.split(separator: ".")
        guard parts.count == 4 else { return nil }

        var parsed: [UInt8] = []
        parsed.reserveCapacity(4)
        for part in parts {
            guard let value = UInt8(part) else { return nil }
            parsed.append(value)
        }
        octets = parsed
    }

    var isLocalNetworkLike: Bool {
        switch (octets[0], octets[1]) {
        case (10, _):
            return true
        case (127, _):
            return true
        case (169, 254):
            return true
        case (172, 16 ... 31):
            return true
        case (192, 168):
            return true
        case (100, 64 ... 127):
            return true
        default:
            return false
        }
    }
}
