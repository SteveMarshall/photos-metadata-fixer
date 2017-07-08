import XCTest
@testable import PhotosMetadataFixerFramework

class FlickrPhotoTests: XCTestCase {
    func testInit_ReturnsNilWithEmptyJSON() {
        let photo = FlickrPhoto(json: [:])
        XCTAssertNil(photo)
    }

    func testInit_InitialisesPartialPhoto() {
        let json = [
            "id": "a1",
            "title": "photo"
        ]
        let photo = FlickrPhoto(json: json)

        XCTAssertEqual(photo?.id, json["id"])
        XCTAssertEqual(photo?.title, json["title"])
    }

    func testInit_InitialisesTitleFromInfoResponse() {
        let expectedTitle = "photo"
        let json: [String: Any] = [
            "id": "a1",
            "title": ["_content": expectedTitle]
        ]
        let photo = FlickrPhoto(json: json)
        XCTAssertEqual(photo?.id, json["id"] as? String)
        XCTAssertEqual(photo?.title, expectedTitle)
    }

    func testInit_InitialisesPhotoWithLocation() {
        let expectedLatitude = 1.1
        let expectedLongitude = 1.2

        let json: [String: Any] = [
            "id": "a1",
            "title": "photo",
            "location": [
                "latitude": String(expectedLatitude),
                "longitude": String(expectedLongitude)
            ]
        ]
        let photo = FlickrPhoto(json: json)

        XCTAssertEqual(photo?.id, json["id"] as? String)
        XCTAssertEqual(photo?.title, json["title"] as? String)
        XCTAssertEqual(photo?.location?.latitude, expectedLatitude)
        XCTAssertEqual(photo?.location?.longitude, expectedLongitude)
    }

    func testInit_InitialisesPhotoWithTags() {
        let expectedTags = [
            "first",
            "second"
        ]
        let json: [String: Any] = [
            "id": "a1",
            "title": "photo",
            "tags": [
                "tag": expectedTags.map {
                    return ["raw": $0]
                }
            ]
        ]
        let photo = FlickrPhoto(json: json)

        XCTAssertEqual(photo?.id, json["id"] as? String)
        XCTAssertEqual(photo?.title, json["title"] as? String)
        for tag in expectedTags {
            XCTAssertTrue(
                photo?.tags?.contains(tag) ?? false,
                "\(tag) not found in " + String(describing: photo?.tags)
            )
        }
    }
}
