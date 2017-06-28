import ScriptingBridge

@objc public protocol PhotosMediaItem {
    @objc optional var name: String {get}
    @objc optional var date: Date {get}
    @objc optional var location: [Double] {get}
}
extension SBObject: PhotosMediaItem {}
