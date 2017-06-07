import ScriptingBridge

@objc public protocol PhotosMediaItem {
    @objc optional var name: String {get}
    @objc optional var date: Date {get}
}
extension SBObject: PhotosMediaItem {}
