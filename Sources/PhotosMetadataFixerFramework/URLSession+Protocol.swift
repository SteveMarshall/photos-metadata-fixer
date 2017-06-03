import Foundation

public typealias DataTaskResult = (Data?, URLResponse?, Error?) -> Void

public protocol URLSessionProtocol {
    func dataTask(
        with url: URL,
        completionHandler: @escaping DataTaskResult
    ) -> URLSessionDataTaskProtocol
}
extension URLSession: URLSessionProtocol {
    public func dataTask(
        with url: URL,
        completionHandler: @escaping DataTaskResult
    ) -> URLSessionDataTaskProtocol {
        return (
            dataTask(with: url, completionHandler: completionHandler)
                as URLSessionDataTask
        ) as URLSessionDataTaskProtocol
    }
}
