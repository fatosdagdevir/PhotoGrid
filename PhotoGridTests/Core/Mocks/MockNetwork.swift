import Foundation
import Networking
@testable import PhotoGrid

final class MockNetwork: Networking {
    var sendCallCount = 0
    var lastRequest: (any RequestProtocol)?
    var mockData: Data?
    var mockError: Error?
    
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    
    enum MockError: Error {
        case missingMockData
        case invalidResponse
    }
    
    func data(for request: some RequestProtocol) async throws -> (Data, URLResponse) {
        sendCallCount += 1
        lastRequest = request
        
        if let error = mockError {
            throw error
        }
        
        guard let data = mockData else {
            throw MockError.missingMockData
        }
        
        let url = URL(string: "https://test.com")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (data, response)
    }
}

