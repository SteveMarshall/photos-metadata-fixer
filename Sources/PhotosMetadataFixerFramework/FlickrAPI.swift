import Foundation
import SwiftyJSON

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

    public func call(method: String, parameters: [String: String] = [:])
    -> JSON {
        guard var urlComponents = URLComponents(
            string: rootURL
        ) else {
            return JSON.null
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
            return JSON.null
        }

        var json: JSON = JSON.null
        let semaphore = DispatchSemaphore( value: 0 )
        let task = urlSession.dataTask(
            with: url,
            completionHandler: { data, _, _ -> Void in
            if let data = data {
                json = JSON(data: data)
            }
            semaphore.signal()
        })
        task.resume()
        semaphore.wait()

        return json
    }
}
