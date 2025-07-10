import Foundation
import UIKit

final class ImageCacher {
    private let cache = NSCache<NSString, UIImage>()
    
    init() {
        cache.countLimit = 100
    }
    
    func getImage(for url: URL) -> UIImage? {
        return cache.object(forKey: url.absoluteString as NSString)
    }
    
    func setImage(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url.absoluteString as NSString)
    }
} 
