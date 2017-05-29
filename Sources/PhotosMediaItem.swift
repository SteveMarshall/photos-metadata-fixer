import ScriptingBridge

@objc protocol PhotosMediaItem {
    @objc optional var name: String {get}
}
extension SBObject: PhotosMediaItem {}
