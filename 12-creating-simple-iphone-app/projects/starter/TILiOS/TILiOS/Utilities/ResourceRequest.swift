
import Foundation

// 1
struct ResourceRequest<ResourceType>
  where ResourceType: Codable {
  // 2
  let baseURL = "http://localhost:8080/api/"
  let resourceURL: URL

  // 3
  init(resourcePath: String) {
    guard let resourceURL = URL(string: baseURL) else {
      fatalError("Failed to convert baseURL to a URL")
    }
    self.resourceURL =
      resourceURL.appendingPathComponent(resourcePath)
  }

  // 1
  func getAll(
    completion: @escaping
      (Result<[ResourceType], ResourceRequestError>) -> Void
  ) {
    // 2
    let dataTask = URLSession.shared
      .dataTask(with: resourceURL) { data, _, _ in
        // 3
        guard let jsonData = data else {
          completion(.failure(.noData))
            return
        }
        do {
          // 4
          let resources = try JSONDecoder()
            .decode(
              [ResourceType].self,
              from: jsonData)
          // 5
          completion(.success(resources))
        } catch {
          // 6
          completion(.failure(.decodingError))
        }
      }
      // 7
      dataTask.resume()
  }

  // 1
  func save<CreateType>(
    _ saveData: CreateType,
    completion: @escaping
      (Result<ResourceType, ResourceRequestError>) -> Void
  ) where CreateType: Codable {
    do {
      // 2
      var urlRequest = URLRequest(url: resourceURL)
      // 3
      urlRequest.httpMethod = "POST"
      // 4
      urlRequest.addValue(
        "application/json",
        forHTTPHeaderField: "Content-Type")
      // 5
      urlRequest.httpBody =
        try JSONEncoder().encode(saveData)
      // 6
      let dataTask = URLSession.shared
        .dataTask(with: urlRequest) { data, response, _ in
          // 7
          guard
            let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200,
            let jsonData = data
            else {
              completion(.failure(.noData))
              return
          }

          do {
            // 8
            let resource = try JSONDecoder()
              .decode(ResourceType.self, from: jsonData)
            completion(.success(resource))
          } catch {
            // 9
            completion(.failure(.decodingError))
          }
        }
      // 10
      dataTask.resume()
    // 11
    } catch {
      completion(.failure(.encodingError))
    }
  }

}
