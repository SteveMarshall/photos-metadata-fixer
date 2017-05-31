import Foundation
import PhotosMetadataFixerFramework

class MockURLSession: URLSessionProtocol {
    private (set) var lastURL: URL?

    func dataTask(
        with url: URL,
        completionHandler: @escaping DataTaskResult
    ) -> URLSessionDataTask {
        lastURL = url
        return URLSessionDataTask()
    }
}
