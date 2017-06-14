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
if let photos: PhotosApplication = SBApplication(
    bundleIdentifier: "com.apple.Photos"
), let selection = photos.selection {
    for item in selection {
        // Brute force into daylight savings time if needs be
        // (This won't catch cases where times/zones are wrong)
        guard let itemDate = item.date,
              let offsetDate = Calendar.current.date(
                byAdding: .second,
                value: Int(timeZone.daylightSavingTimeOffset(for: itemDate)),
                to: itemDate
              ) else {
            continue
        }

        let candidates = api.call(method: "flickr.photos.search", parameters: [
            "user_id": flickrUserID,
            "min_taken_date": String(Int(offsetDate.timeIntervalSince1970)),
            "max_taken_date": String(Int(offsetDate.timeIntervalSince1970))
        ])["photos"]["photo"]

        let matches = candidates.arrayValue.filter { photo in
            item.name == photo["title"].string
        }

        let itemName: String
        if let name = item.name, !name.isEmpty {
            itemName = name
        } else {
            itemName = "unnamed photo"
        }

        guard matches.count == 1 else {
            print(
                "⛔️ ",
                matches.isEmpty ? "No" : matches.count,
                "matches on flickr for \(itemName)",
                "taken on \(itemDate) (\(candidates.count) candidates)"
            )
            continue
        }

        print(
            "✅  Matched \(itemName) taken on \(itemDate)",
            "(\(candidates.count) candidates)"
        )
    }
}
