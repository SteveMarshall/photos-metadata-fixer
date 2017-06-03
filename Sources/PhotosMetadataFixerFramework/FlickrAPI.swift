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

    func call(method: String) {
        let url = URL(string: "\(rootUrl)?"
                            + "api_key=\(apiKey)&method=\(method)"
        )!
        _ = urlSession.dataTask(
            with: url,
            completionHandler: { _, _, _ -> Void in
        })
    }
}
