import Foundation

/// Represents the current state of the device camera and ML tracking engine
enum TrackingState: Equatable {
    case active
    case error(TrackingError)
    
    var feedbackMessage: String? {
        switch self {
        case .active:
            return nil
        case .error(let error):
            return error.localizedDescription
        }
    }
}

/// Specific errors that can interrupt the workout tracking
enum TrackingError: Error, LocalizedError, Equatable {
    case lowLight
    case outOfFrame
    case lowConfidence
    case unauthorized
    case cameraUnavailable
    
    var errorDescription: String? {
        switch self {
        case .lowLight:
            return "Increase lighting"
        case .outOfFrame:
            return "Move fully into frame"
        case .lowConfidence:
            return "Adjust phone position"
        case .unauthorized:
            return "Camera access required"
        case .cameraUnavailable:
            return "Camera unavailable"
        }
    }
}
