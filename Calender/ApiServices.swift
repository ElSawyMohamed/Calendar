//
//  ApiServices.swift
//  Calender
//
//  Created by mac on 22/01/1446 AH.
//

import Foundation
enum APIError: Error {
    case invalidURL
    case requestFailed(Error)
    case responseError
    case dataError
    case decodingError(Error)
}

class APIService {
    static let shared = APIService()
    
    private init() {}
    
    func fetchData<T: Codable>(url: String, type: T.Type, parameters: Codable? = nil, method: String = "GET", completion: @escaping (Result<T, APIError>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.setValue("Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1bmlxdWVfbmFtZSI6WyI0MDA1NSIsIjAxMTI5Nzk1OTIxIl0sIkFjY291bnRTZXR1cElkIjoiMjIzOTkiLCJDb21wYW55SWQiOiIyMTIyNiIsInJvbGUiOiJGdWxsQWNjZXNzIiwibmJmIjoxNzIxODMxNjk1LCJleHAiOjE3MjI0MzY0OTUsImlhdCI6MTcyMTgzMTY5NX0.cpYP0_zplugUuvy7N4O98IsOgpdCEny-wkj2HcWbpoE", forHTTPHeaderField: "authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "content-type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "accept")
       
        if let parameters = parameters {
            do {
                let jsonData = try JSONEncoder().encode(parameters)
                urlRequest.httpBody = jsonData
            } catch {
                print("Failed to encode JSON: \(error)")
            }
        }
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                completion(.failure(.requestFailed(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                completion(.failure(.responseError))
                return
            }
            
            guard let data = data else {
                completion(.failure(.dataError))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch let decodingError {
                completion(.failure(.decodingError(decodingError)))
            }
        }
        
        task.resume()
    }
}
