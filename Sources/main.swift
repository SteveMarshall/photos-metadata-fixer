import ScriptingBridge

if let photos: PhotosApplication = SBApplication(
    bundleIdentifier: "com.apple.Photos"
) {
    for item in photos.selection! {
        print(item.name!.isEmpty ? "[No name]" : item.name!)
    }
}
