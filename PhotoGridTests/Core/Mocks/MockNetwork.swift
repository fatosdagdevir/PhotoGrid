import Foundation
import Networking
@testable import PhotoGrid

actor MockNetwork: Networking {
    // MARK: - Thread-safe mutable state
    private var _sendCallCount = 0
    private var _lastRequest: (any RequestProtocol)?
    private var _mockData: Data?
    private var _mockError: Error?
    
    // MARK: - Sendable immutable properties
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    
    // MARK: - Public interface for accessing mutable state
    var sendCallCount: Int {
        get async { _sendCallCount }
    }
    
    var lastRequest: (any RequestProtocol)? {
        get async { _lastRequest }
    }
    
    var mockData: Data? {
        get async { _mockData }
    }
    
    var mockError: Error? {
        get async { _mockError }
    }
    
    enum MockError: Error {
        case missingMockData
        case invalidResponse
    }
    
    func data(for request: some RequestProtocol) async throws -> (Data, URLResponse) {
        _sendCallCount += 1
        _lastRequest = request
        
        if let error = _mockError {
            throw error
        }
        
        guard let data = _mockData else {
            throw MockError.missingMockData
        }
        
        let url = URL(string: "https://test.com")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (data, response)
    }
    
    // MARK: - Helper methods for testing
    func setMockData(_ data: Data?) {
        _mockData = data
    }
    
    func setMockError(_ error: Error?) {
        _mockError = error
    }
    
    func reset() {
        _sendCallCount = 0
        _lastRequest = nil
        _mockData = nil
        _mockError = nil
    }
}

