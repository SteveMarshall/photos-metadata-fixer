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

if let photos: PhotosApplication = SBApplication(
    bundleIdentifier: "com.apple.Photos"
) {
    for item in photos.selection! {
        print(item.name!.isEmpty ? "[No name]" : item.name!)
    }
}
