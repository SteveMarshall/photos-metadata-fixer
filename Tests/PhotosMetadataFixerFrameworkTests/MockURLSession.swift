import Foundation
import PhotosMetadataFixerFramework

class MockURLSession: URLSessionProtocol {
    var nextDataTask = MockURLSessionDataTask()
    var nextData: Data?
    var nextResponse: URLResponse?
    var nextError: Error?
    var lastURL: URL?

    func dataTask(
        with url: URL,
        completionHandler: @escaping DataTaskResult
    ) -> URLSessionDataTaskProtocol {
        lastURL = url
        completionHandler(nextData, nextResponse, nextError)
        return nextDataTask
    }
}
