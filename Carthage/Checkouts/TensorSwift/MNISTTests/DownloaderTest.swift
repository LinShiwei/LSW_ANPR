import XCTest

class Downloader: XCTestCase {
    func testDownloadTestData() {
        let testData = downloadTestData()
        
        XCTAssertEqual(testData.images.length, 7840016)
        XCTAssertEqual(testData.images.sha1, "65e11ec1fd220343092a5070b58418b5c2644e26")
    }
}
