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

    public func call(method: String, parameters: [String: String] = [:])
    -> [String: Any]? {
        guard var urlComponents = URLComponents(
            string: rootURL
        ) else {
            return nil
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
            return nil
        }

        var result: [String: Any]? = nil
        let semaphore = DispatchSemaphore( value: 0 )
        urlSession.dataTask(
            with: url,
            completionHandler: { data, _, _ -> Void in
            if let data = data,
                let json = try? JSONSerialization.jsonObject(
                    with: data, options: []
                ) as? [String: Any] {
                result = json
            }
            semaphore.signal()
        }).resume()
        semaphore.wait()

        return result
    }

    public func searchForPhotos(
        fromUser user: String? = nil,
        takenAfter: Date? = nil,
        takenBefore: Date? = nil
    ) -> [FlickrPhoto] {
        var parameters: [String: String] = [:]
        if let user = user {
            parameters["user_id"] = user
        }
        if let takenAfter = takenAfter {
            parameters["min_taken_date"] = String(Int(
                takenAfter.timeIntervalSince1970
            ))
        }
        if let takenBefore = takenBefore {
            parameters["max_taken_date"] = String(Int(
                takenBefore.timeIntervalSince1970
            ))
        }
        let results = call(
            method: "flickr.photos.search", parameters: parameters
        )

        guard let photosWrapper = results?["photos"] as? [String: Any],
           let photos = photosWrapper["photo"] as? [[String: Any]] else {
               return []
        }

        return photos.flatMap({ photo in
            return FlickrPhoto(json: photo)
        })
    }

    public func getInfo(forPhoto photoID: String) -> FlickrPhoto? {
        let results = call(
            method: "flickr.photos.getInfo", parameters: [
                "photo_id": photoID
        ])
        guard let photoInfo = results?["photo"] as? [String: Any] else {
            return nil
        }
        return FlickrPhoto(json: photoInfo)
    }
}
