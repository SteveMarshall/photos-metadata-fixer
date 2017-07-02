import CoreLocation
import MapKit
import PhotosMetadataFixerFramework
import ScriptingBridge

var standardError = FileHandle.standardError
guard let flickrAPIKey = ProcessInfo.processInfo.environment[
    "FLICKR_API_KEY"
] else {
    print(
        "⚠️  No FLICKR_API_KEY environment variable.",
        "Without that, we can't access the flickr API.",
        "\n- To get an API key, visit",
        "https://www.flickr.com/services/apps/create/apply/,",
        "apply for a non-commercial key, complete the form, and copy the key.",
        "\n - To use the key with the app, prepend",
        "FLICKR_API_KEY=<your key here> to the command you just executed.\n",
        to: &standardError
    )
    exit(-1)
}

guard ProcessInfo.processInfo.arguments.count == 2 else {
    print(
        "⚠️  No flickr username passed.",
        "Without that, we can't find your photos.",
        "\nTo use the key with the app, append your username",
        "to the command you just executed.\n",
        to: &standardError
    )
    exit(-1)
}
let flickrUserID = ProcessInfo.processInfo.arguments[1]

let api = FlickrAPI(withAPIKey: flickrAPIKey)

func getCLLocation(for point: [Double]) -> CLLocation {
    return CLLocation(
        latitude: point[0], longitude: point[1]
    )
}

func setLocation(for photo: PhotosMediaItem, from flickrPhoto: [String: Any]) {
    if let locationJSON = flickrPhoto["location"] as? [String: Any],
        let latitudeString = locationJSON["latitude"] as? String,
        let flickrLatitude = Double(latitudeString),
        let longitudeString = locationJSON["longitude"] as? String,
        let flickrLongitude = Double(longitudeString) {
        let flickrLocation = [
            flickrLatitude,
            flickrLongitude
        ]
        let newLocation = flickrLocation
        if let photoLocation = photo.location, !photoLocation.isEmpty {
            let distance = getCLLocation(for: flickrLocation).distance(
                from: getCLLocation(for: photoLocation)
            )
            let distanceFormatter = MKDistanceFormatter()
            distanceFormatter.units = .metric
            print("flickr location is",
                  distanceFormatter.string(fromDistance: distance),
                  "from Photos location.",
                  "Update to use flickr's location?"
            )
            // TODO: Actually decide if we should change the location
        }
        print("- 📌  Setting location to \(newLocation)")
    } else {
        if let photoLocation = photo.location, !photoLocation.isEmpty {
            print("-   No location on flickr, but photo has location")
        } else if let tagWrapper = flickrPhoto["tags"] as? [String: Any],
             let tags = tagWrapper["tag"] as? [[String: Any]] {
            print("- ⛔️  No location on flickr")
            print(tags.flatMap { tag in
                tag["raw"]
            })
        }
    }
}

let timeZone = Calendar.current.timeZone
if let photosApp: PhotosApplication = SBApplication(
    bundleIdentifier: "com.apple.Photos"
), let selection = photosApp.selection {
    for photo in selection {
        // Brute force into daylight savings time if needs be
        // (This won't catch cases where times/zones are wrong)
        guard let photoDate = photo.date,
              let offsetDate = Calendar.current.date(
                byAdding: .second,
                value: Int(timeZone.daylightSavingTimeOffset(for: photoDate)),
                to: photoDate
              ) else {
            continue
        }

        let candidates = api.searchForPhotos(
            fromUser: flickrUserID,
            takenAfter: offsetDate,
            takenBefore: offsetDate
        )

        let matches = candidates.filter { candidate in
            photo.name == candidate.title
        }

        let photoName: String
        if let name = photo.name, !name.isEmpty {
            photoName = "\"\(name)\""
        } else {
            photoName = "unnamed photo"
        }

        guard matches.count == 1 else {
            print(
                "⛔️ ",
                matches.isEmpty ? "No" : matches.count,
                "matches on flickr for \(photoName)",
                "taken on \(photoDate) (\(candidates.count) candidates)",
                to: &standardError
            )
            continue
        }

        print(
            "✅  Matched \(photoName) taken on \(photoDate)",
            "(\(candidates.count) candidates)"
        )
        let flickrPhotoSummary = matches[0]

        guard let flickrPhoto = api.call(
            method: "flickr.photos.getInfo",
            parameters: [
                "photo_id": flickrPhotoSummary.id
        ])?["photo"] as? [String: Any] else {
            continue
        }

        setLocation(for: photo, from: flickrPhoto)
    }
}
