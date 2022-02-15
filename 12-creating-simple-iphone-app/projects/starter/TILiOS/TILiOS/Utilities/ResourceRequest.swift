
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

}
