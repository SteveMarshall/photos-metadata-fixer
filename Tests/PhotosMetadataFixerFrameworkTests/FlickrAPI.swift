import XCTest
@testable import PhotosMetadataFixerFramework

class FlickrAPITest: XCTestCase {
    func testCall_PassesAPIKeyParameter() {
        let mock = MockURLSession()
        let api = FlickrAPI(
            withAPIKey: "dummy-api-key",
            withURLSession: mock
        )
        let expectedItem = URLQueryItem(
            name: "api_key",
            value: "dummy-api-key"
        )

        api.call()

        // Pass the querystring through URLComponents so we don't
        // have to manually parse it ourselves
        var lastURLComponents = URLComponents()
        lastURLComponents.query = mock.lastURL?.query
        XCTAssertTrue(
            lastURLComponents.queryItems?.contains(expectedItem) ?? false,
            "\(expectedItem) not found in "
          + String(describing: lastURLComponents.queryItems)
        )
    }
}
