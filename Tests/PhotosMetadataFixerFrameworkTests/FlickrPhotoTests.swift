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

    func testInit_SetsLocationFromInfoResponse() {
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

        XCTAssertEqual(photo?.location?.latitude, expectedLatitude)
        XCTAssertEqual(photo?.location?.longitude, expectedLongitude)
    }

    func testInit_SetsLocationFromSearchResponse() {
        let expectedLatitude = 1.1
        let expectedLongitude = 1.2

        let json: [String: Any] = [
            "id": "a1",
            "title": "photo",
            "latitude": String(expectedLatitude),
            "longitude": String(expectedLongitude)
        ]
        let photo = FlickrPhoto(json: json)

        XCTAssertEqual(photo?.location?.latitude, expectedLatitude)
        XCTAssertEqual(photo?.location?.longitude, expectedLongitude)
    }

    func testInit_SetsTags() {
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

        for tag in expectedTags {
            XCTAssertTrue(
                photo?.tags?.contains(tag) ?? false,
                "\(tag) not found in " + String(describing: photo?.tags)
            )
        }
    }

    func testInit_SetsDateTakenFromSearchResponse() {
        let expectedDate = DateComponents(
            calendar: Calendar.current,
            year: 2017, month: 10, day: 4,
            hour: 18, minute: 33
        ).date
        let json: [String: Any] = [
            "id": "a1",
            "title": "photo",
            "datetaken": "2017-10-04 18:33:00"
        ]
        let photo = FlickrPhoto(json: json)

        XCTAssertEqual(photo?.dateTaken, expectedDate)
    }

    func testInit_SetsDateTakenFromInfoResponse() {
        let expectedDate = DateComponents(
            calendar: Calendar.current,
            year: 2017, month: 10, day: 4,
            hour: 18, minute: 33
        ).date
        let json: [String: Any] = [
            "id": "a1",
            "title": "photo",
            "dates": [
                "taken": "2017-10-04 18:33:00"
            ]
        ]
        let photo = FlickrPhoto(json: json)

        XCTAssertEqual(photo?.dateTaken, expectedDate)
    }
}
