//
//  CameraCaptureView.swift
//  KindleCam
//
//  Child-friendly native camera capture view using AVFoundation.
//  Matches native iOS Camera app behavior with auto-focus, aspect fill, motion-relative orientation.
//  On capture/selection, passes image to ViewModel review stage.
//

import SwiftUI
import AVFoundation
import PhotosUI
import Combine

// MARK: - Camera Capture View

public struct CameraCaptureView: View {
    @Bindable var viewModel: CameraStoryViewModel
    @StateObject private var cameraManager = CameraManager()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedSimulatedScene: SimulatedScene = .toyAndBook
    @State private var forceSimulatedMode: Bool = false
    
    public init(viewModel: CameraStoryViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            // Camera Preview or Simulated Viewfinder
            if !forceSimulatedMode && cameraManager.isCameraAvailable && cameraManager.isPermissionGranted {
                CameraPreviewRepresentable(session: cameraManager.captureSession)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
            } else {
                simulatedCameraView
            }
            
            // Overlay UI Controls
            VStack {
                // Top Navigation Bar
                HStack {
                    Button(action: {
                        viewModel.phase = .idle
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(.white.opacity(0.9))
                            .shadow(radius: 4)
                    }
                    
                    Spacer()
                    
                    Text((!forceSimulatedMode && cameraManager.isCameraAvailable && cameraManager.isPermissionGranted)
                         ? "Point at something cool! 📸"
                         : "Camera Story 📸")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Capsule())
                    
                    Spacer()
                    
                    // Toggle Mode Switch (Live vs Simulated/Gallery)
                    if cameraManager.isCameraAvailable && cameraManager.isPermissionGranted {
                        Button(action: {
                            forceSimulatedMode.toggle()
                        }) {
                            Image(systemName: forceSimulatedMode ? "camera.fill" : "wand.and.stars")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                    } else {
                        Color.clear.frame(width: 32, height: 32)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                Spacer()
                
                // Processing Indicator Overlay
                if viewModel.phase == .detectingObjects {
                    VStack(spacing: 14) {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                            .scaleEffect(1.6)
                        
                        Text("Discovering shapes & colors... 🔍")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .padding(28)
                    .background(Color.black.opacity(0.75))
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shadow(radius: 10)
                }
                
                Spacer()
                
                // Bottom Control Bar
                if viewModel.phase == .idle || viewModel.phase == .capturing {
                    HStack(spacing: 36) {
                        // Photo Gallery Button
                        PhotosPicker(
                            selection: $selectedPhotoItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            VStack(spacing: 4) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.25))
                                        .frame(width: 56, height: 56)
                                    
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                                Text("Gallery")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.9))
                            }
                        }
                        .buttonStyle(ShutterButtonStyle())
                        
                        // Main Shutter Button
                        Button(action: triggerCapture) {
                            ZStack {
                                Circle()
                                    .fill(.white)
                                    .frame(width: 80, height: 80)
                                
                                Circle()
                                    .stroke(.white, lineWidth: 4)
                                    .frame(width: 90, height: 90)
                                
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundStyle(Color(red: 0.48, green: 0.24, blue: 0.93))
                            }
                        }
                        .buttonStyle(ShutterButtonStyle())
                    }
                    .padding(.bottom, 36)
                }
            }
        }
        .onAppear {
            cameraManager.requestPermissionAndStart()
        }
        .onDisappear {
            cameraManager.stopSession()
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    viewModel.startReview(with: image)
                }
                selectedPhotoItem = nil
            }
        }
    }
    
    // MARK: - Simulated Camera View (For Simulator or when physical camera is unavailable)
    
    private var simulatedCameraView: some View {
        ZStack {
            // Viewfinder Simulated Background Gradient
            LinearGradient(
                colors: selectedSimulatedScene.backgroundColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Viewfinder Grid Overlay
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack(spacing: 14) {
                        Text(selectedSimulatedScene.emoji)
                            .font(.system(size: 110))
                            .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
                        
                        Text(selectedSimulatedScene.title)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .shadow(radius: 4)
                        
                        Text("Interactive Viewfinder • Tap shutter to capture!")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    Spacer()
                }
                Spacer()
                
                // Scene Selector Picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(SimulatedScene.allCases, id: \.self) { scene in
                            Button(action: {
                                selectedSimulatedScene = scene
                            }) {
                                HStack(spacing: 6) {
                                    Text(scene.emoji)
                                        .font(.system(size: 18))
                                    Text(scene.shortName)
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                }
                                .foregroundStyle(selectedSimulatedScene == scene ? Color(red: 0.3, green: 0.1, blue: 0.5) : .white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(selectedSimulatedScene == scene ? Color.white : Color.white.opacity(0.25))
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 120)
            }
        }
    }
    
    // MARK: - Capture Logic
    
    private func triggerCapture() {
        viewModel.phase = .capturing
        
        let handleImage: (UIImage) -> Void = { image in
            viewModel.startReview(with: image)
        }
        
        if !forceSimulatedMode && cameraManager.isCameraAvailable && cameraManager.isPermissionGranted {
            cameraManager.capturePhoto { image in
                let captureImage = image ?? self.selectedSimulatedScene.generateImage()
                handleImage(captureImage)
            }
        } else {
            let simulatedImage = selectedSimulatedScene.generateImage()
            handleImage(simulatedImage)
        }
    }
}

// MARK: - Simulated Scenes for Testing / Simulator

private enum SimulatedScene: String, CaseIterable {
    case toyAndBook
    case catAndCup
    case appleAndPencil
    
    var title: String {
        switch self {
        case .toyAndBook: return "Teddy Bear & Storybook 🧸📚"
        case .catAndCup: return "Playful Cat & Mug 🐱☕"
        case .appleAndPencil: return "Red Apple & Colored Pencil 🍎✏️"
        }
    }
    
    var shortName: String {
        switch self {
        case .toyAndBook: return "Teddy & Book"
        case .catAndCup: return "Cat & Mug"
        case .appleAndPencil: return "Apple & Pencil"
        }
    }
    
    var emoji: String {
        switch self {
        case .toyAndBook: return "🧸"
        case .catAndCup: return "🐱"
        case .appleAndPencil: return "🍎"
        }
    }
    
    var backgroundColors: [Color] {
        switch self {
        case .toyAndBook: return [Color(red: 0.35, green: 0.2, blue: 0.7), Color(red: 0.6, green: 0.3, blue: 0.8)]
        case .catAndCup: return [Color(red: 0.1, green: 0.5, blue: 0.7), Color(red: 0.3, green: 0.7, blue: 0.8)]
        case .appleAndPencil: return [Color(red: 0.8, green: 0.25, blue: 0.35), Color(red: 0.95, green: 0.45, blue: 0.3)]
        }
    }
    
    func generateImage() -> UIImage {
        let size = CGSize(width: 800, height: 800)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let cgContext = context.cgContext
            
            // Draw gradient background
            let colors = [
                UIColor(red: 0.35, green: 0.2, blue: 0.7, alpha: 1.0).cgColor,
                UIColor(red: 0.6, green: 0.3, blue: 0.8, alpha: 1.0).cgColor
            ] as CFArray
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: nil) {
                cgContext.drawLinearGradient(gradient, start: CGPoint.zero, end: CGPoint(x: 800, y: 800), options: [])
            }
            
            // Render main emoji illustration onto canvas
            let string = self.emoji as NSString
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 220)
            ]
            let textSize = string.size(withAttributes: attributes)
            let rect = CGRect(
                x: (800 - textSize.width) / 2,
                y: (800 - textSize.height) / 2 - 40,
                width: textSize.width,
                height: textSize.height
            )
            string.draw(in: rect, withAttributes: attributes)
            
            // Draw title text at bottom of image
            let titleStr = self.title as NSString
            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 36),
                .foregroundColor: UIColor.white
            ]
            let titleSize = titleStr.size(withAttributes: titleAttrs)
            titleStr.draw(at: CGPoint(x: (800 - titleSize.width) / 2, y: 680), withAttributes: titleAttrs)
        }
    }
}

// MARK: - Shutter Button Style

private struct ShutterButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.85 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

// MARK: - Camera Manager (AVFoundation)

private class CameraManager: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var photoContinuation: ((UIImage?) -> Void)?
    
    @Published var isCameraAvailable: Bool = false
    @Published var isPermissionGranted: Bool = false
    
    override init() {
        super.init()
    }
    
    func requestPermissionAndStart() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            DispatchQueue.main.async { self.isPermissionGranted = true }
            self.setupAndStartSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.isPermissionGranted = granted
                    if granted {
                        self.setupAndStartSession()
                    } else {
                        self.isCameraAvailable = false
                    }
                }
            }
        default:
            DispatchQueue.main.async {
                self.isPermissionGranted = false
                self.isCameraAvailable = false
            }
        }
    }
    
    private func getCameraDevice() -> AVCaptureDevice? {
        if let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return backCamera
        }
        if let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            return frontCamera
        }
        if let anyDevice = AVCaptureDevice.default(for: .video) {
            return anyDevice
        }
        return nil
    }
    
    private func setupAndStartSession() {
        guard let camera = getCameraDevice(),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            DispatchQueue.main.async {
                self.isCameraAvailable = false
            }
            return
        }
        
        // Native camera focus and exposure configuration
        try? camera.lockForConfiguration()
        if camera.isFocusModeSupported(.continuousAutoFocus) {
            camera.focusMode = .continuousAutoFocus
        }
        if camera.isExposureModeSupported(.continuousAutoExposure) {
            camera.exposureMode = .continuousAutoExposure
        }
        if camera.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
            camera.whiteBalanceMode = .continuousAutoWhiteBalance
        }
        camera.unlockForConfiguration()
        
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo
        
        for existingInput in captureSession.inputs {
            captureSession.removeInput(existingInput)
        }
        for existingOutput in captureSession.outputs {
            captureSession.removeOutput(existingOutput)
        }
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        captureSession.commitConfiguration()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
            DispatchQueue.main.async {
                self.isCameraAvailable = true
            }
        }
    }
    
    func startSession() {
        guard !captureSession.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    func stopSession() {
        guard captureSession.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        guard isPermissionGranted, isCameraAvailable else {
            completion(nil)
            return
        }
        photoContinuation = completion
        
        let settings = AVCapturePhotoSettings()
        if let connection = photoOutput.connection(with: .video), connection.isVideoOrientationSupported {
            let orientation = UIDevice.current.orientation
            switch orientation {
            case .portrait: connection.videoOrientation = .portrait
            case .portraitUpsideDown: connection.videoOrientation = .portraitUpsideDown
            case .landscapeLeft: connection.videoOrientation = .landscapeRight
            case .landscapeRight: connection.videoOrientation = .landscapeLeft
            default: connection.videoOrientation = .portrait
            }
        }
        
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            photoContinuation?(nil)
            photoContinuation = nil
            return
        }
        photoContinuation?(image)
        photoContinuation = nil
    }
}

// MARK: - Camera Preview UIViewRepresentable with layerClass override & motion relative orientation

private struct CameraPreviewRepresentable: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> PreviewContainerView {
        let view = PreviewContainerView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIView(_ uiView: PreviewContainerView, context: Context) {
        uiView.previewLayer.session = session
    }
}

private class PreviewContainerView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = bounds
        if let connection = previewLayer.connection, connection.isVideoOrientationSupported {
            let orientation = UIDevice.current.orientation
            switch orientation {
            case .portrait: connection.videoOrientation = .portrait
            case .portraitUpsideDown: connection.videoOrientation = .portraitUpsideDown
            case .landscapeLeft: connection.videoOrientation = .landscapeRight
            case .landscapeRight: connection.videoOrientation = .landscapeLeft
            default: connection.videoOrientation = .portrait
            }
        }
    }
}
