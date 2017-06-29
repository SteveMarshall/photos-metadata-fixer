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

    func testInit_InitialisesPhotoWithLocation() {
        let location = [
            "longitude": 1.1,
            "latitude": 1.2
        ]
        let json: [String: Any] = [
            "id": "a1",
            "title": "photo",
            "location": location
        ]
        let photo = FlickrPhoto(json: json)

        XCTAssertEqual(photo?.id, json["id"] as? String)
        XCTAssertEqual(photo?.title, json["title"] as? String)
        XCTAssertEqual(photo?.location?.latitude, location["latitude"])
        XCTAssertEqual(photo?.location?.longitude, location["longitude"])
    }
}