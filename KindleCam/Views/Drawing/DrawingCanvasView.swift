//
//  DrawingCanvasView.swift
//  KindleCam
//
//  PencilKit canvas representable for Creative doodle drawing.
//

import PencilKit
import Photos
import SwiftUI

public struct DrawingCanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    @Binding var tool: PKTool
    @Binding var clearTrigger: UUID
    @Binding var undoTrigger: UUID
    @Binding var saveTrigger: UUID
    var onSaveFinished: (Bool) -> Void

    public init(
        drawing: Binding<PKDrawing>,
        tool: Binding<PKTool>,
        clearTrigger: Binding<UUID>,
        undoTrigger: Binding<UUID>,
        saveTrigger: Binding<UUID>,
        onSaveFinished: @escaping (Bool) -> Void
    ) {
        self._drawing = drawing
        self._tool = tool
        self._clearTrigger = clearTrigger
        self._undoTrigger = undoTrigger
        self._saveTrigger = saveTrigger
        self.onSaveFinished = onSaveFinished
    }

    public func makeUIView(context: Context) -> RotationSafeCanvasView {
        let canvas = RotationSafeCanvasView()
        canvas.drawingPolicy = .anyInput
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.tool = tool
        canvas.drawing = drawing
        canvas.delegate = context.coordinator
        canvas.minimumZoomScale = 1
        canvas.maximumZoomScale = 1
        canvas.bounces = false
        canvas.isScrollEnabled = false
        
        // Remove default UIScribbleInteraction to prevent handwritingd XPC daemon connection invalidation logs
        let scribbleInteractions = canvas.interactions.compactMap { $0 as? UIScribbleInteraction }
        for interaction in scribbleInteractions {
            canvas.removeInteraction(interaction)
        }
        
        return canvas
    }

    public func updateUIView(_ canvas: RotationSafeCanvasView, context: Context) {
        canvas.tool = tool
        if canvas.drawing != drawing {
            canvas.drawing = drawing
        }
        if context.coordinator.lastClear != clearTrigger {
            canvas.drawing = PKDrawing()
            DispatchQueue.main.async {
                self.drawing = PKDrawing()
            }
            context.coordinator.lastClear = clearTrigger
        }
        if context.coordinator.lastUndo != undoTrigger {
            canvas.undoManager?.undo()
            DispatchQueue.main.async {
                self.drawing = canvas.drawing
            }
            context.coordinator.lastUndo = undoTrigger
        }
        if context.coordinator.lastSave != saveTrigger {
            context.coordinator.lastSave = saveTrigger
            save(drawing: canvas.drawing, in: canvas.bounds, scale: canvas.traitCollection.displayScale)
        }
    }

    private func save(drawing: PKDrawing, in bounds: CGRect, scale: CGFloat) {
        guard !bounds.isEmpty else { onSaveFinished(false); return }
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = scale
        let image = UIGraphicsImageRenderer(size: bounds.size, format: format).image { _ in
            UIColor.white.setFill()
            UIRectFill(CGRect(origin: .zero, size: bounds.size))
            drawing.image(from: bounds, scale: format.scale).draw(in: CGRect(origin: .zero, size: bounds.size))
        }
        let library = PHPhotoLibrary.shared()
        let write: () -> Void = {
            library.performChanges({ PHAssetChangeRequest.creationRequestForAsset(from: image) }) { success, _ in
                DispatchQueue.main.async { onSaveFinished(success) }
            }
        }
        switch PHPhotoLibrary.authorizationStatus(for: .addOnly) {
        case .authorized, .limited: write()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                status == .authorized || status == .limited ? write() : DispatchQueue.main.async { onSaveFinished(false) }
            }
        default: onSaveFinished(false)
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, clear: clearTrigger, undo: undoTrigger, save: saveTrigger)
    }

    public final class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: DrawingCanvasView
        var lastClear: UUID
        var lastUndo: UUID
        var lastSave: UUID

        init(parent: DrawingCanvasView, clear: UUID, undo: UUID, save: UUID) {
            self.parent = parent
            self.lastClear = clear
            self.lastUndo = undo
            self.lastSave = save
        }

        public func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            DispatchQueue.main.async {
                if self.parent.drawing != canvasView.drawing {
                    self.parent.drawing = canvasView.drawing
                }
            }
        }
    }
}

/// PKCanvasView is a scroll view. Resetting its content geometry after a size
/// change prevents it from retaining the old portrait/landscape coordinate space.
public final class RotationSafeCanvasView: PKCanvasView {
    private var previousSize: CGSize = .zero

    public override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.size != previousSize, !bounds.isEmpty else { return }
        previousSize = bounds.size
        contentSize = bounds.size
        contentOffset = .zero
        zoomScale = 1
    }
}
