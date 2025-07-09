import Foundation

struct Photo: Identifiable, Hashable {
    let id: String
    let author: String
    let width: Int
    let height: Int
    let url: String
    let downloadUrl: String
    
    var thumbnailURL: URL? {
        let targetWidth: CGFloat = 300
        let scale = targetWidth / CGFloat(width)
        let targetHeight = CGFloat(height) * scale
        return URL(string: "https://picsum.photos/id/\(id)/\(Int(targetWidth))/\(Int(targetHeight))")
    }
}

