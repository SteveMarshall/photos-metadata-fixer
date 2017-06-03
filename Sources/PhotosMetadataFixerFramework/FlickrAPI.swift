import Foundation

public class FlickrAPI {
    let rootURL = "https://api.flickr.com/services/rest/"
    let urlSession: URLSessionProtocol
    let coreQueryItems: [URLQueryItem]

    public init(
        withAPIKey apiKey: String,
        withURLSession urlSession: URLSessionProtocol
            = URLSession.shared
    ) {
        coreQueryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "nojsoncallback", value: "1")
        ]
        self.urlSession = urlSession
    }

    func call(method: String, parameters: [String: String] = [:]) {
        guard var urlComponents = URLComponents(
            string: rootURL
        ) else {
            return
        }

        urlComponents.queryItems = coreQueryItems
        urlComponents.queryItems?.append(
            URLQueryItem(name: "method", value: method)
        )
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
