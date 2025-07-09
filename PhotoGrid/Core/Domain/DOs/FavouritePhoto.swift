import Foundation
import SwiftData

@Model
final class FavouritePhoto {
    var photoId: String
    
    init(photoId: String) {
        self.photoId = photoId
    }
} 