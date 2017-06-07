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

if let photos: PhotosApplication = SBApplication(
    bundleIdentifier: "com.apple.Photos"
), let selection = photos.selection {
    for item in selection {
        print(item.name ?? "[No name]")
        guard let itemDate = item.date else {
            continue
        }
        let result = api.call(method: "flickr.photos.search", parameters: [
            "user_id": flickrUserID,
            "min_taken_date": String(Int(itemDate.timeIntervalSince1970)),
            "max_taken_date": String(Int(itemDate.timeIntervalSince1970))
        ])
        print(result)
    }
}
