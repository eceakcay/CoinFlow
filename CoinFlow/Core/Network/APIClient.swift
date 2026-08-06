//
//  APIClient.swift
//  CoinFlow
//
//  Created by Ece Akcay on 30.06.2026.
//

import Foundation

final class APIClient {

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        guard var components = URLComponents(string: endpoint.baseURL + endpoint.path) else {
            throw NetworkError.invalidURL
        }

        components.queryItems = endpoint.queryItems

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        print("Request URL:")
        print(url.absoluteString)

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body

        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            print("Status Code:", httpResponse.statusCode)

            guard 200...299 ~= httpResponse.statusCode else {
                if let responseText = String(data: data, encoding: .utf8) {
                    print("Error response:")
                    print(responseText)
                }
                
                if httpResponse.statusCode == 429 {
                    throw NetworkError.rateLimit
                }

                throw NetworkError.statusCode(httpResponse.statusCode)
            }

            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Decoding failed. Raw response:")
                    print(jsonString)
                }

                print("Decoding error:")
                print(error)

                throw NetworkError.decodingError
            }

        } catch let urlError as URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost, .timedOut:
                throw NetworkError.noInternet //Sonra bunu kendi hata tipimize çeviriyoruz:
            default:
                throw NetworkError.unknown(urlError)
            }
        }
        catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.unknown(error)
        }
    }
}
