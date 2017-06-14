import PhotosMetadataFixerFramework
import ScriptingBridge

guard let flickrAPIKey = ProcessInfo.processInfo.environment[
    "FLICKR_API_KEY"
] else {
    var standardError = FileHandle.standardError
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

let api = FlickrAPI(withAPIKey: flickrAPIKey)
let flickrUserID = "steviebm"

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
    }
}
