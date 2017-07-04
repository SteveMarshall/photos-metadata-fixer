import XCTest
@testable import PhotosMetadataFixerFramework

class FlickrAPITests: XCTestCase {
    var mockSession: MockURLSession!
    var api: FlickrAPI!

    override func setUp() {
        super.setUp()

        mockSession = MockURLSession()
        api = FlickrAPI(
            withAPIKey: "dummy-api-key",
            withURLSession: mockSession
        )
    }

    func assert<T: Equatable>(
        _ actual: [T]?, contains expected: T,
        file: StaticString = #file, line: UInt = #line
    ) {
        XCTAssertTrue(
            actual?.contains(expected) ?? false,
            "\(expected) not found in " + String(describing: actual),
            file: file, line: line
        )
    }

    func queryItems(for url: URL?) -> [URLQueryItem]? {
        // Pass the querystring through URLComponents so we don't
        // have to manually parse it
        var components = URLComponents()
        components.query = url?.query
        return components.queryItems
    }

    func testCall_PassesAPIKeyParameter() {
        let expectedItem = URLQueryItem(
            name: "api_key",
            value: "dummy-api-key"
        )

        _ = api.call(method: "dummy-method")

        let actualQueryItems = queryItems(for: mockSession.lastURL)
        assert(actualQueryItems, contains: expectedItem)
    }

    func testCall_RequestsJSONWithoutCallback() {
        let expectedItems = [
            "format": "json",
            "nojsoncallback": "1"
        ]

        _ = api.call(method: "dummy-method")

        let actualQueryItems = queryItems(for: mockSession.lastURL)
        for (name, value) in expectedItems {
            let expectedItem = URLQueryItem(
                name: name,
                value: value
            )
            assert(actualQueryItems, contains: expectedItem)
        }
    }

    func testCall_RequestsCorrectMethod() {
        let expectedItem = URLQueryItem(
            name: "method",
            value: "dummy-method"
        )

        _ = api.call(method: "dummy-method")

        let actualQueryItems = queryItems(for: mockSession.lastURL)
        assert(actualQueryItems, contains: expectedItem)
    }

    func testCall_PassesParameters() {
        let expectedItems = [
            "first-parameter": "first-value",
            "second-parameter": "second-value"
        ]

        _ = api.call(method: "dummy-method", parameters: expectedItems)

        let actualQueryItems = queryItems(for: mockSession.lastURL)
        for (name, value) in expectedItems {
            let expectedItem = URLQueryItem(
                name: name,
                value: value
            )
            assert(actualQueryItems, contains: expectedItem)
        }
    }

    func testCall_ReturnsJSON() {
        mockSession.nextData = "{\"stat\": \"ok\"}".data(using: .utf8)

        guard let actual = api.call(
            method: "dummy-method"
        ) as? [String: String] else {
            XCTFail("Expected response to be of type [String: String]")
            return
        }
        XCTAssertEqual(["stat": "ok"], actual)
    }

    func testPhotoSearch_RequestsCorrectMethod() {
        let expectedItem = URLQueryItem(
            name: "method",
            value: "flickr.photos.search"
        )

        _ = api.searchForPhotos()

        let actualQueryItems = queryItems(for: mockSession.lastURL)
        assert(actualQueryItems, contains: expectedItem)
    }

    func testPhotoSearch_PassesUserIDParameter() {
        let expectedItem = URLQueryItem(
            name: "user_id",
            value: "test_user"
        )

        _ = api.searchForPhotos(fromUser: expectedItem.value)

        let actualQueryItems = queryItems(for: mockSession.lastURL)
        assert(actualQueryItems, contains: expectedItem)
    }

    func testPhotoSearch_PassesTakenAfterParameter() {
        let expectedDate = Date(timeIntervalSince1970: 0)
        let expectedItem = URLQueryItem(
            name: "min_taken_date",
            value: "0"
        )

        _ = api.searchForPhotos(takenAfter: expectedDate)

        let actualQueryItems = queryItems(for: mockSession.lastURL)
        assert(actualQueryItems, contains: expectedItem)
    }

    func testPhotoSearch_PassesTakenBeforeParameter() {
        let expectedDate = Date(timeIntervalSince1970: 0)
        let expectedItem = URLQueryItem(
            name: "max_taken_date",
            value: "0"
        )

        _ = api.searchForPhotos(takenBefore: expectedDate)

        let actualQueryItems = queryItems(for: mockSession.lastURL)
        assert(actualQueryItems, contains: expectedItem)
    }

    func testPhotoSearch_GivenFlickrSearchResultsReturnsPhotos() {
        mockSession.nextData = (
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
