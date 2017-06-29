public struct FlickrPhoto {
    let id: String
    let title: String
    let location: (latitude: Double, longitude: Double)?

    init?(json: [String: Any]) {
        guard let id = json["id"] as? String,
            let title = json["title"] as? String
        else {
            return nil
        }

        self.id = id
        self.title = title

        if let location = json["location"] as? [String: Any],
           let latitude = location["latitude"] as? Double,
           let longitude = location["longitude"] as? Double {
            self.location = (latitude, longitude)
        } else {
            self.location = nil
        }
    }
}
