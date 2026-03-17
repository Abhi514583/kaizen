import Foundation
import Vision
import AVFoundation

@Observable
final class VisionManager: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var trackingState: TrackingState = .active
    
    // Joint mapping (just strong references to commonly tracked points)
    var keypoints: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint] = [:]
    
    // Performance and configuration
    private let minimumConfidence: Float = 0.5
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let request = VNDetectHumanBodyPoseRequest(completionHandler: handlePoseDetection)
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            print("Vision request failed: \(error)")
        }
    }
    
    private func handlePoseDetection(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNHumanBodyPoseObservation],
              let observation = observations.first else {
            // No person found
            updateTrackingState(to: .error(.outOfFrame))
            return
        }
        
        processObservation(observation)
    }
    
    private func processObservation(_ observation: VNHumanBodyPoseObservation) {
        do {
            // Fetch all recognized points
            let recognizedPoints = try observation.recognizedPoints(.all)
            
            // Filter and store only points that meet our confidence threshold
            // For Kaizen we track specific subsets, but we'll capture all confident points for now
            let confidentPoints = recognizedPoints.filter { $0.value.confidence >= minimumConfidence }
            
            DispatchQueue.main.async { [weak self] in
                self?.keypoints = confidentPoints
                
                // Example minimal check: do we see shoulders? Usually required for most exercises.
                let hasLeftShoulder = confidentPoints[.leftShoulder] != nil
                let hasRightShoulder = confidentPoints[.rightShoulder] != nil
                
                if hasLeftShoulder || hasRightShoulder {
                    self?.updateTrackingState(to: .active)
                } else {
                    self?.updateTrackingState(to: .error(.lowConfidence))
                }
            }
            
        } catch {
            updateTrackingState(to: .error(.lowConfidence))
        }
    }
    
    private func updateTrackingState(to newState: TrackingState) {
        // Prevent unnecessary state updates if it's identical
        if trackingState != newState {
            DispatchQueue.main.async { [weak self] in
                self?.trackingState = newState
            }
        }
    }
}
