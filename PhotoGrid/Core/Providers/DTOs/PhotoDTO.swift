import Foundation

struct PhotoDTO: Codable {
    let id: String
    let author: String
    let width: Int
    let height: Int
    let url: String
    let downloadUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id, author, width, height, url
        case downloadUrl = "download_url"
    }
    
    var mapped: Photo {
        .init(
            id: id,
            author: author,
            width: width,
            height: height,
            url: url,
            downloadUrl: downloadUrl
        )
    }
}
