import Foundation

struct WeatherSnapshot: Equatable {
    let currentTemperature: Double
    let todayHigh: Double
    let todayLow: Double
}

enum WeatherServiceError: Error, LocalizedError {
    case invalidResponse
    case decoding

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Couldn't reach the weather service."
        case .decoding:
            return "The weather service returned something unexpected."
        }
    }
}

struct WeatherService {
    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherSnapshot {
        var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "current", value: "temperature_2m"),
            URLQueryItem(name: "daily", value: "temperature_2m_max,temperature_2m_min"),
            URLQueryItem(name: "timezone", value: "auto"),
            URLQueryItem(name: "temperature_unit", value: "celsius"),
        ]
        guard let url = components.url else { throw WeatherServiceError.invalidResponse }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw WeatherServiceError.invalidResponse
        }

        let decoded: OpenMeteoResponse
        do {
            decoded = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
        } catch {
            throw WeatherServiceError.decoding
        }

        guard let current = decoded.current?.temperature2m,
              let high = decoded.daily?.temperature2mMax.first,
              let low = decoded.daily?.temperature2mMin.first else {
            throw WeatherServiceError.decoding
        }

        return WeatherSnapshot(currentTemperature: current, todayHigh: high, todayLow: low)
    }
}

private struct OpenMeteoResponse: Decodable {
    struct Current: Decodable {
        let temperature2m: Double
        enum CodingKeys: String, CodingKey {
            case temperature2m = "temperature_2m"
        }
    }
    struct Daily: Decodable {
        let temperature2mMax: [Double]
        let temperature2mMin: [Double]
        enum CodingKeys: String, CodingKey {
            case temperature2mMax = "temperature_2m_max"
            case temperature2mMin = "temperature_2m_min"
        }
    }
    let current: Current?
    let daily: Daily?
}
