import Foundation

public class FlickrAPI {
    let rootUrl = "https://api.flickr.com/services/rest/"
    let apiKey: String
    let urlSession: URLSessionProtocol

    public init(
        withAPIKey apiKey: String,
        withURLSession urlSession: URLSessionProtocol
            = URLSession.shared
    ) {
        self.apiKey = apiKey
        self.urlSession = urlSession
    }

    func call(method: String, parameters: [String: String] = [:]) {
        guard var urlComponents = URLComponents(
            string: rootUrl
        ) else {
            return
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "method", value: method)
        ]
        urlComponents.queryItems?.append(contentsOf:
            parameters.map({ name, value in
                URLQueryItem(name: name, value: value)
            })
        )

        guard let url = urlComponents.url else {
            return
        }
        _ = urlSession.dataTask(
            with: url,
            completionHandler: { _, _, _ -> Void in
        })
    }
}
