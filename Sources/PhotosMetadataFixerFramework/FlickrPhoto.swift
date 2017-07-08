public struct FlickrPhoto {
    public let id: String
    public let title: String
    public let location: (latitude: Double, longitude: Double)?
    public let tags: [String]?

    init?(json: [String: Any]) {
        guard let id = json["id"] as? String,
            let title = (
               (json["title"] as? [String: String])?["_content"]
            ??  json["title"] as? String
            )
        else {
            return nil
        }

        self.id = id
        self.title = title

        if let location = json["location"] as? [String: Any],
           let latitudeString = location["latitude"] as? String,
           let latitude = Double(latitudeString),
           let longitudeString = location["longitude"] as? String,
           let longitude = Double(longitudeString) {
            self.location = (latitude, longitude)
        } else {
            self.location = nil
        }

        if let tags = (json["tags"] as? [String: [[String: Any]]])?["tag"] {
            self.tags = tags.flatMap { $0["raw"] as? String }
        } else {
            self.tags = nil
        }
    }
}
