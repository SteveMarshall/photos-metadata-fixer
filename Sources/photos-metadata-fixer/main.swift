import CoreLocation
import MapKit
import PhotosMetadataFixerFramework
import ScriptingBridge
import SwiftyJSON

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

func setLocation(for photo: PhotosMediaItem, from flickrPhoto: JSON) {
    if flickrPhoto["location"] != .null {
        let flickrLocation = [
            flickrPhoto["location"]["latitude"].doubleValue,
            flickrPhoto["location"]["longitude"].doubleValue
        ]
        var newLocation: [Double]? = flickrLocation
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
        if let newLocation = newLocation {
            print("- 📌  Setting location to \(newLocation)")
        }
    } else {
        if let photoLocation = photo.location, !photoLocation.isEmpty {
            print("-   No location on flickr, but photo has location")
        } else {
            print("- ⛔️  No location on flickr")
            print(flickrPhoto["tags"]["tag"].map { _, tag in
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

        let candidates = api.call(method: "flickr.photos.search", parameters: [
            "user_id": flickrUserID,
            "min_taken_date": String(Int(offsetDate.timeIntervalSince1970)),
            "max_taken_date": String(Int(offsetDate.timeIntervalSince1970))
        ])["photos"]["photo"]

        let matches = candidates.arrayValue.filter { candidate in
            photo.name == candidate["title"].string
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

        let flickrPhoto = api.call(
            method: "flickr.photos.getInfo",
            parameters: [
                "photo_id": flickrPhotoSummary["id"].stringValue
        ])["photo"]

        setLocation(for: photo, from: flickrPhoto)
    }
}
