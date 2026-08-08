//
//  CameraStoryViewModel.swift
//  KindleCam
//
//  ViewModel orchestrating the Shape & Color Camera Discovery flow.
//  State Machine: idle → capturing → reviewing → detectingObjects → educationalResult
//  Analyzes captured photos for objects, shapes (e.g. Octagon, Circle), and colors,
//  providing instant educational insights without story tasks or persistence.
//

import Foundation
import SwiftUI
import Observation

/// State machine phases for the Camera Explorer.
public enum StoryPhase: Equatable {
    case idle
    case capturing
    case reviewing
    case detectingObjects
    case educationalResult
}

/// Observable ViewModel for Camera Explorer.
@Observable
@MainActor
public final class CameraStoryViewModel {
    
    // MARK: - Published State
    
    public var phase: StoryPhase = .idle
    public var capturedImage: UIImage?
    public var detectedObjects: [CapturedObject] = []
    public var educationalResult: EducationalAnalysisResult?
    public var errorMessage: String?
    
    // MARK: - Services
    
    private let visionDetector = VisionObjectDetector()
    private let educationalService = EducationalShapeColorService()
    
    public init() {}
    
    // MARK: - Feature Flow
    
    /// Step 1: Called when the photo is captured or selected — shows review & draw annotation screen.
    public func startReview(with image: UIImage) {
        capturedImage = image
        phase = .reviewing
    }
    
    /// Step 2: Called from ImageAnnotationView when user finishes circling or tapping objects.
    public func processAnnotatedRegions(circles: [CGRect], in viewSize: CGSize) async {
        guard let image = capturedImage else { return }
        phase = .detectingObjects
        errorMessage = nil
        
        var allObjects: [CapturedObject] = []
        var dominantColor: String = "Blue"
        var dominantShape: String = "Octagon"
        
        if circles.isEmpty {
            // Whole image processing
            let objects = await visionDetector.detectObjects(in: image)
            allObjects.append(contentsOf: objects)
            dominantColor = visionDetector.detectColor(in: image)
            dominantShape = visionDetector.detectShape(in: image)
        } else {
            // Process annotated cropped regions
            for circle in circles {
                let croppedImage = cropImage(image, circleRect: circle, viewSize: viewSize)
                let objects = await visionDetector.detectObjects(in: croppedImage)
                allObjects.append(contentsOf: objects)
                
                dominantColor = visionDetector.detectColor(in: croppedImage)
                dominantShape = visionDetector.detectShape(in: croppedImage)
            }
        }
        
        let dedupedObjects = deduplicate(objects: allObjects)
        detectedObjects = dedupedObjects
        let primaryLabel = dedupedObjects.first?.label ?? "Clock"
        
        // Step 3: Run Kid-Friendly Object Usage Analysis
        let result = await educationalService.analyze(
            objectLabel: primaryLabel
        )
        
        self.educationalResult = result
        self.phase = .educationalResult
    }
    
    /// Reset the ViewModel for a new camera capture session.
    public func reset() {
        phase = .idle
        capturedImage = nil
        detectedObjects = []
        educationalResult = nil
        errorMessage = nil
    }
    
    // MARK: - Private Helpers
    
    private func cropImage(_ image: UIImage, circleRect: CGRect, viewSize: CGSize) -> UIImage {
        guard let cgImage = image.cgImage, viewSize.width > 0, viewSize.height > 0 else {
            return image
        }
        
        let pixelWidth = CGFloat(cgImage.width)
        let pixelHeight = CGFloat(cgImage.height)
        
        let scaleX = pixelWidth / viewSize.width
        let scaleY = pixelHeight / viewSize.height
        
        let cropX = max(0, circleRect.origin.x * scaleX)
        let cropY = max(0, circleRect.origin.y * scaleY)
        let cropW = min(pixelWidth - cropX, circleRect.width * scaleX)
        let cropH = min(pixelHeight - cropY, circleRect.height * scaleY)
        
        let cropRect = CGRect(x: cropX, y: cropY, width: max(1, cropW), height: max(1, cropH))
        
        guard let croppedCG = cgImage.cropping(to: cropRect) else {
            return image
        }
        
        return UIImage(cgImage: croppedCG, scale: image.scale, orientation: image.imageOrientation)
    }
    
    private func deduplicate(objects: [CapturedObject]) -> [CapturedObject] {
        var seen = Set<String>()
        var result: [CapturedObject] = []
        for obj in objects {
            let key = obj.label.lowercased()
            if !seen.contains(key) {
                seen.insert(key)
                result.append(obj)
            }
        }
        return result
    }
}
