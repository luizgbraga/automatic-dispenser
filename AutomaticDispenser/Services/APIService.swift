import Foundation
import Combine

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
}

class APIService {
    static let shared = APIService()
    private let baseURL = "http://192.168.4.1" // Default AP mode URL
    
    private init() {}
    
    // MARK: - Device Info
    func getDeviceInfo() async throws -> DeviceInfo {
        guard let url = URL(string: "\(baseURL)/info") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(DeviceInfo.self, from: data)
    }
    
    func configureWiFi(ssid: String, password: String, timezoneOffset: Int) async throws {
        guard let url = URL(string: "\(baseURL)/configure_wifi") else {
            throw APIError.invalidURL
        }
        
        let config = WiFiConfig(ssid: ssid, password: password, timezone_offset: timezoneOffset)
        let jsonData = try JSONEncoder().encode(config)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
    }
    
    func setPillSchedule(schedule: [PillScheduleItem]) async throws {
        guard let url = URL(string: "\(baseURL)/configure_schedule") else {
            throw APIError.invalidURL
        }
        
        let config = ScheduleConfig(schedule: schedule)
        let jsonData = try JSONEncoder().encode(config)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
    }
    
    func getCurrentSchedule() async throws -> [PillScheduleItem] {
        guard let url = URL(string: "\(baseURL)/schedule") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(ScheduleResponse.self, from: data)
        return response.schedule
    }
    
    func dispensePills(count: Int) async throws {
        guard let url = URL(string: "\(baseURL)/dispense") else {
            throw APIError.invalidURL
        }
        
        let config = DispenseConfig(pills: count)
        let jsonData = try JSONEncoder().encode(config)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
    }
}

struct DeviceInfo: Codable {
    let name: String
    let ipAddress: String
    let firmwareVersion: String
}

struct WiFiConfig: Codable {
    let ssid: String
    let password: String
    let timezone_offset: Int
}

struct PillScheduleItem: Codable {
    let hour: Int
    let minute: Int
    let pills: Int
    var active: Bool = true
}

struct ScheduleConfig: Codable {
    let schedule: [PillScheduleItem]
}

struct ScheduleResponse: Codable {
    let schedule: [PillScheduleItem]
}

struct DispenseConfig: Codable {
    let pills: Int
} 
