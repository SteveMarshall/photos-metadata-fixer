import Foundation

public struct FlickrPhoto {
    public let id: String
    public let title: String
    public let location: (latitude: Double, longitude: Double)?
    public let tags: [String]?
    public let dateTaken: Date?
    static let dateFormatter: DateFormatter = {
        $0.locale = Locale(identifier: "en_US_POSIX")
        $0.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return $0
    }(DateFormatter())

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

        let dateTakenElement: String?
        if let dateElement = json["dates"] as? [String: Any] {
            dateTakenElement = dateElement["taken"] as? String
        } else {
            dateTakenElement = json["datetaken"] as? String
        }

        if let dateTakenElement = dateTakenElement,
           let dateTaken = FlickrPhoto.dateFormatter.date(
               from: dateTakenElement
        ) {
            self.dateTaken = dateTaken
        } else {
            self.dateTaken = nil
        }

        if let tags = (json["tags"] as? [String: [[String: Any]]])?["tag"] {
            self.tags = tags.flatMap { $0["raw"] as? String }
        } else {
            self.tags = nil
        }
    }
}
