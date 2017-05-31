import Foundation

public typealias DataTaskResult = (Data?, URLResponse?, Error?) -> Void

public protocol URLSessionProtocol {
    func dataTask(
        with url: URL,
        completionHandler: @escaping DataTaskResult
    ) -> URLSessionDataTask
}
extension URLSession: URLSessionProtocol {}
