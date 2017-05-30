import ScriptingBridge

@objc public protocol PhotosMediaItem {
    @objc optional var name: String {get}
}
extension SBObject: PhotosMediaItem {}
