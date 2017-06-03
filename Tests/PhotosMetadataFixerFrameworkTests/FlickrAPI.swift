import XCTest
@testable import PhotosMetadataFixerFramework

class FlickrAPITest: XCTestCase {
    func queryItems(for url: URL?) -> [URLQueryItem]? {
        // Pass the querystring through URLComponents so we don't
        // have to manually parse it
        var components = URLComponents()
        components.query = url?.query
        return components.queryItems
    }

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

        api.call(method: "dummy-method")

        let actualQueryItems = queryItems(for: mock.lastURL)
        XCTAssertTrue(
            actualQueryItems?.contains(expectedItem) ?? false,
            "\(expectedItem) not found in "
          + String(describing: actualQueryItems)
        )
    }

    func testCall_RequestsCorrectMethod() {
        let mock = MockURLSession()
        let api = FlickrAPI(
            withAPIKey: "dummy-api-key",
            withURLSession: mock
        )
        let expectedItem = URLQueryItem(
            name: "method",
            value: "dummy-method"
        )

        api.call(method: "dummy-method")

        let actualQueryItems = queryItems(for: mock.lastURL)
        XCTAssertTrue(
            actualQueryItems?.contains(expectedItem) ?? false,
            "\(expectedItem) not found in "
          + String(describing: actualQueryItems)
        )
    }

    func testCall_PassesParameters() {
        let mock = MockURLSession()
        let api = FlickrAPI(
            withAPIKey: "dummy-api-key",
            withURLSession: mock
        )
        let expectedItems = [
            "first-parameter": "first-value",
            "second-parameter": "second-value"
        ]

        api.call(method: "dummy-method", parameters: expectedItems)

        let actualQueryItems = queryItems(for: mock.lastURL)
        for (name, value) in expectedItems {
            let expectedItem = URLQueryItem(
                name: name,
                value: value
            )
            XCTAssertTrue(
                actualQueryItems?.contains(expectedItem) ?? false,
                "\(expectedItem) not found in "
              + String(describing: actualQueryItems)
            )
        }
    }
}
