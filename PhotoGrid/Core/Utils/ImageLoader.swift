import Foundation
import UIKit

@MainActor
final class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false
    
    private let cache: ImageCacher
    private var currentTask: Task<Void, Never>?
    
    init(cache: ImageCacher = ImageCacher()) {
        self.cache = cache
    }
    
    func loadImage(from url: URL?) async {
        currentTask?.cancel()
        
        guard let url = url else { return }
        
        currentTask = Task {
            isLoading = true
            
            if let cachedImage = cache.getImage(for: url) {
                if !Task.isCancelled {
                    image = cachedImage
                    isLoading = false
                }
                return
            }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                if !Task.isCancelled {
                    if let downloadedImage = UIImage(data: data) {
                        image = downloadedImage
                        cache.setImage(downloadedImage, for: url)
                    }
                    isLoading = false
                }
            } catch {
                if !Task.isCancelled {
                    print("Failed to load image: \(error)")
                    isLoading = false
                }
            }
        }
        
        await currentTask?.value
    }
    
    deinit {
        currentTask?.cancel()
    }
} 
