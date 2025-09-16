import Foundation
import Networking

protocol PhotoProviding: Sendable {
    func fetchPhotoGrid() async throws -> [Photo]
}

final class PhotoProvider: PhotoProviding, Sendable {
    private let network: Networking
    init(network: Networking = Network()) {
        self.network = network
    }
    
    func fetchPhotoGrid() async throws -> [Photo] {
        let endpoint = PhotoGridEndpoint()
        let request = PhotoGridRequest(endpoint: endpoint)
        let response = try await network.send(request: request)
        return response.map { $0.mapped }
    }
}

// MARK: - Photo Grid
private struct PhotoGridEndpoint: EndpointProtocol {
    let base = AppConstants.API.baseURL
    let path = "/list"

    var queryParameters: [String : String]? {
        ["limit": "100"]
    }
}

private struct PhotoGridRequest: RequestProtocol {
    typealias Response = [PhotoDTO]
    let endpoint: any EndpointProtocol
    let method: HTTP.Method = .GET
}
