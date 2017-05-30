import ScriptingBridge

@objc public protocol PhotosApplication {
    @objc optional var selection: [PhotosMediaItem] {get}
    @objc optional var mediaItems: [PhotosMediaItem] {get}
}
extension SBApplication : PhotosApplication {}
