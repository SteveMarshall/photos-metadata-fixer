import ScriptingBridge

@objc protocol PhotosApplication {
    @objc optional var selection: [PhotosMediaItem] {get}
    @objc optional var mediaItems: [PhotosMediaItem] {get}
}
extension SBApplication : PhotosApplication {}
