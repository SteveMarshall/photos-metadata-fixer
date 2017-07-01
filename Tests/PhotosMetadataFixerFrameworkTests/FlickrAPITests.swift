import XCTest
@testable import PhotosMetadataFixerFramework

class FlickrAPITests: XCTestCase {
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

        _ = api.call(method: "dummy-method")

        let actualQueryItems = queryItems(for: mock.lastURL)
        XCTAssertTrue(
            actualQueryItems?.contains(expectedItem) ?? false,
            "\(expectedItem) not found in "
          + String(describing: actualQueryItems)
        )
    }

    func testCall_RequestsJSONWithoutCallback() {
        let mock = MockURLSession()
        let api = FlickrAPI(
            withAPIKey: "dummy-api-key",
            withURLSession: mock
        )
        let expectedItems = [
            "format": "json",
            "nojsoncallback": "1"
        ]

        _ = api.call(method: "dummy-method")

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

        _ = api.call(method: "dummy-method")

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

        _ = api.call(method: "dummy-method", parameters: expectedItems)

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

    func testCall_ReturnsJSON() {
        let mock = MockURLSession()
        let api = FlickrAPI(
            withAPIKey: "dummy-api-key",
            withURLSession: mock
        )
        mock.nextData = "{\"stat\": \"ok\"}".data(using: .utf8)

        guard let actual = api.call(
            method: "dummy-method"
        ) as? [String: String] else {
            XCTFail("Expected response to be of type [String: String]")
            return
        }
        XCTAssertEqual(["stat": "ok"], actual)
    }

    func testPhotoSearch_RequestsCorrectMethod() {
        let mock = MockURLSession()
        let api = FlickrAPI(
            withAPIKey: "dummy-api-key",
            withURLSession: mock
        )
        let expectedItem = URLQueryItem(
            name: "method",
            value: "flickr.photos.search"
        )

        _ = api.searchForPhotos()

        let actualQueryItems = queryItems(for: mock.lastURL)
        XCTAssertTrue(
            actualQueryItems?.contains(expectedItem) ?? false,
            "\(expectedItem) not found in "
          + String(describing: actualQueryItems)
        )
    }

    func testPhotoSearch_PassesUserIDParameter() {
        let mock = MockURLSession()
        let api = FlickrAPI(
            withAPIKey: "dummy-api-key",
            withURLSession: mock
        )
        let expectedItem = URLQueryItem(
            name: "user_id",
            value: "test_user"
        )

        _ = api.searchForPhotos(fromUser: expectedItem.value)

        let actualQueryItems = queryItems(for: mock.lastURL)
        XCTAssertTrue(
            actualQueryItems?.contains(expectedItem) ?? false,
            "\(expectedItem) not found in "
          + String(describing: actualQueryItems)
        )
    }

    func testPhotoSearch_PassesTakenAfterParameter() {
        let mock = MockURLSession()
        let api = FlickrAPI(
            withAPIKey: "dummy-api-key",
            withURLSession: mock
        )
        let expectedDate = Date(timeIntervalSince1970: 0)
        let expectedItem = URLQueryItem(
            name: "min_taken_date",
            value: "0"
        )

        _ = api.searchForPhotos(takenAfter: expectedDate)

        let actualQueryItems = queryItems(for: mock.lastURL)
        XCTAssertTrue(
            actualQueryItems?.contains(expectedItem) ?? false,
            "\(expectedItem) not found in "
          + String(describing: actualQueryItems)
        )
    }

    func testPhotoSearch_PassesTakenBeforeParameter() {
        let mock = MockURLSession()
        let api = FlickrAPI(
            withAPIKey: "dummy-api-key",
            withURLSession: mock
        )
        let expectedDate = Date(timeIntervalSince1970: 0)
        let expectedItem = URLQueryItem(
            name: "max_taken_date",
            value: "0"
        )

        _ = api.searchForPhotos(takenBefore: expectedDate)

        let actualQueryItems = queryItems(for: mock.lastURL)
        XCTAssertTrue(
            actualQueryItems?.contains(expectedItem) ?? false,
            "\(expectedItem) not found in "
          + String(describing: actualQueryItems)
        )
    }

    func testPhotoSearch_GivenFlickrSearchResultsReturnsPhotos() {
        let mock = MockURLSession()
        let api = FlickrAPI(
            withAPIKey: "dummy-api-key",
            withURLSession: mock
        )

        mock.nextData = (
            "{" +
                "\"photos\": {" +
                    "\"photo\": [{" +
                        "\"id\": \"1\"," +
                        "\"title\": \"A Photo\"" +
                    "}]" +
                "}" +
            "}"
        ).data(using: .utf8)

        let actual = api.searchForPhotos()

        guard 1 == actual.count else {
            XCTAssertEqual(1, actual.count)
            return
        }
        XCTAssertEqual("1", actual[0].id)
        XCTAssertEqual("A Photo", actual[0].title)
    }
}
