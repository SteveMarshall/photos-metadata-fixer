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

func setLocation(for photo: PhotosMediaItem, from flickrPhoto: FlickrPhoto?) {
    if let flickrLocation = flickrPhoto?.location {
        var newLocation = [
            flickrLocation.latitude,
            flickrLocation.longitude
        ]
        if let photoLocation = photo.location, !photoLocation.isEmpty {
            let distance = getCLLocation(for: newLocation).distance(
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
        } else if let tags = flickrPhoto?.tags {
            print("- ⛔️  No location on flickr")
            print(tags)
        }
    }
}

struct Results {
    var notMatched: Int = 0
    var matched: Int = 0
    var overMatched: Int = 0
}

var results = Results()

let allTimeZones = TimeZone.knownTimeZoneIdentifiers.flatMap(
    TimeZone.init(identifier:)
)
if let photosApp: PhotosApplication = SBApplication(
    bundleIdentifier: "com.apple.Photos"
), let selection = photosApp.selection {
    for photo in selection {
        guard let photoDate = photo.date else {
            continue
        }

        // Find the photo in the correct timezone by brute force
        let uniqueTimeZoneOffsets = Set(allTimeZones.map({
            $0.secondsFromGMT(for: photoDate)
        }))
        let candidates = api.searchForPhotos(
            fromUser: flickrUserID,
            takenAfter: photoDate + TimeInterval(uniqueTimeZoneOffsets.min()!),
            takenBefore: photoDate + TimeInterval(uniqueTimeZoneOffsets.max()!),
            extraParameters: ["extras": "date_taken", "per_page": "500"]
        )

        let matches = candidates.filter { candidate in
            let timeMatches = uniqueTimeZoneOffsets.map({ offsetPhotoDate in
                candidate.dateTaken == photoDate + TimeInterval(offsetPhotoDate)
            })
            return (photo.name == candidate.title)
                && timeMatches.contains(true)
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
                "matches on flickr for \(photoName) (\(photo.id ?? ""))",
                "taken on \(photoDate) (\(candidates.count) candidates)",
                to: &standardError
            )
            if matches.isEmpty {
                results.notMatched += 1
            } else {
                results.overMatched +=  1
            }
            continue
        }

        print(
            "✅  Matched \(photoName) taken on \(photoDate)",
            "(\(candidates.count) candidates)"
        )
        results.matched += 1
        let flickrPhoto = api.getInfo(forPhoto: matches[0].id)

        setLocation(for: photo, from: flickrPhoto)
    }
}

print(results)
