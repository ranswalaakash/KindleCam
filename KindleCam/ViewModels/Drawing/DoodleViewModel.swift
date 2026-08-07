//
//  DoodleViewModel.swift
//  KindleCam
//
//  ViewModel for Creative Doodle interactive drawing canvas.
//

import Combine
import PencilKit
import SwiftUI

public enum DrawingTool: String, CaseIterable, Identifiable {
    case pencil, marker, crayon
    public var id: String { rawValue }
    public var label: String { rawValue.capitalized }
    public var symbol: String { self == .pencil ? "pencil.tip" : self == .marker ? "highlighter" : "paintbrush.pointed" }
}

public final class DoodleViewModel: ObservableObject {
    @Published public var shapes: [DoodleObject] = [
        .init(
            assetName: "spoon",
            symbolName: "spoon",
            title: "Spoon",
            ideas: "a giraffe, bunny, guitar, or rocket",
            hints: [
                .init(icon: "🦒", title: "Tall Giraffe", instruction: "Draw a long neck up the handle, add two ears at the top oval, and paint brown spots!"),
                .init(icon: "🐰", title: "Fluffy Bunny", instruction: "Turn the top spoon oval into a bunny head! Add two long floppy ears and a pink nose."),
                .init(icon: "🎸", title: "Rockstar Guitar", instruction: "Draw 6 straight string lines down the handle and add tuning pegs at the top!"),
                .init(icon: "🚀", title: "Cosmic Rocket", instruction: "Add two pointy fins at the handle base and draw fiery orange flames blasting out!")
            ]
        ),
        .init(
            assetName: "cloud",
            symbolName: "cloud.fill",
            title: "Cloud",
            ideas: "a sheep, dragon, or castle",
            hints: [
                .init(icon: "🐑", title: "Fluffy Sheep", instruction: "Add 4 little black legs underneath the cloud and draw a happy sheep face!"),
                .init(icon: "🐉", title: "Sky Dragon", instruction: "Draw a long dragon tail, wings, and a cute snout to turn the cloud into a dragon!"),
                .init(icon: "🏰", title: "Cloud Castle", instruction: "Draw tall castle towers and red flags poking out from the top of the cloud!")
            ]
        ),
        .init(
            assetName: "moon",
            symbolName: "moon.fill",
            title: "Moon",
            ideas: "a banana, smile, or hammock",
            hints: [
                .init(icon: "🍌", title: "Cheeky Banana", instruction: "Color it bright yellow, add a green stem at the top, and draw a fruit sticker!"),
                .init(icon: "😊", title: "Happy Moon", instruction: "Draw two big shiny eyes and a wide open smile inside the crescent curve!"),
                .init(icon: "⛵", title: "Cozy Hammock", instruction: "Draw two palm trees on each end and a cozy blanket hanging from the moon curve!")
            ]
        ),
        .init(
            assetName: "umbrella",
            symbolName: "umbrella.fill",
            title: "Umbrella",
            ideas: "a jellyfish, mushroom, or tent",
            hints: [
                .init(icon: "🪼", title: "Sea Jellyfish", instruction: "Draw long wavy swimming tentacles hanging down from the bottom edge!"),
                .init(icon: "🍄", title: "Forest Mushroom", instruction: "Draw a thick mushroom stem underneath and paint white polka dots on top!"),
                .init(icon: "⛺", title: "Camping Tent", instruction: "Draw a tent door opening underneath and add a warm campfire in front!")
            ]
        ),
        .init(
            assetName: "drop",
            symbolName: "drop.fill",
            title: "Drop",
            ideas: "a fish, flame, or jellyfish",
            hints: [
                .init(icon: "🐠", title: "Swimming Fish", instruction: "Add a tail fin at the narrow top, two side fins, and a smiling eye!"),
                .init(icon: "🔥", title: "Campfire Flame", instruction: "Color it fiery red, yellow, and orange, and draw wooden logs underneath!"),
                .init(icon: "💧", title: "Magic Raindrop", instruction: "Add giant sparkling eyes and a cute smile to make a friendly raindrop!")
            ]
        ),
        .init(
            symbolName: "star.fill",
            title: "Star",
            ideas: "a superhero, flower, or magic wand",
            hints: [
                .init(icon: "🦸", title: "Star Superhero", instruction: "Draw a red cape behind the star and a superhero mask over the top point!"),
                .init(icon: "🌸", title: "Star Flower", instruction: "Draw green leaves and a stem growing down from the bottom point!"),
                .init(icon: "🪄", title: "Magic Wand", instruction: "Draw a sparkly golden wand handle pointing down from the star!")
            ]
        ),
        .init(
            symbolName: "heart.fill",
            title: "Heart",
            ideas: "a butterfly, strawberry, or hot-air balloon",
            hints: [
                .init(icon: "🦋", title: "Heart Butterfly", instruction: "Draw two big wings extending out from the heart sides and add two antennae!"),
                .init(icon: "🍓", title: "Sweet Strawberry", instruction: "Draw green leaves at the top and little black seeds all over the heart!"),
                .init(icon: "🎈", title: "Hot-Air Balloon", instruction: "Draw a little basket hanging underneath with tiny ropes!")
            ]
        ),
        .init(
            symbolName: "circle.fill",
            title: "Circle",
            ideas: "a turtle, clock, or planet",
            hints: [
                .init(icon: "🐢", title: "Sea Turtle", instruction: "Draw a head, 4 flippers, and a tail sticking out around the circle shell!"),
                .init(icon: "⏰", title: "Alarm Clock", instruction: "Draw clock numbers 1 to 12 around the circle and two hands pointing to 12!"),
                .init(icon: "🪐", title: "Ringed Planet", instruction: "Draw a glowing cosmic ring wrapping around the middle of the circle!")
            ]
        ),
        .init(
            symbolName: "triangle.fill",
            title: "Triangle",
            ideas: "a mountain, fox, or sailboat",
            hints: [
                .init(icon: "⛰️", title: "Snowy Mountain", instruction: "Paint white snow caps on the top point and green pine trees at the bottom!"),
                .init(icon: "🦊", title: "Cute Fox", instruction: "Turn the triangle into a pointy fox face! Add two ears and a black nose."),
                .init(icon: "⛵", title: "Ocean Sailboat", instruction: "Draw a wooden boat hull underneath the triangle sail and add blue waves!")
            ]
        )
    ]

    @Published public var selectedShape: DoodleObject?
    @Published public var drawing: PKDrawing = PKDrawing()
    @Published public var selectedColor: Color = Color(red: 1.0, green: 0.35, blue: 0.35)
    @Published public var selectedTool: DrawingTool = .marker
    @Published public var lineWidth: CGFloat = 14
    @Published public var isEraserActive = false
    @Published public var clearTrigger = UUID()
    @Published public var undoTrigger = UUID()
    @Published public var saveTrigger = UUID()
    @Published public var saveMessage: String?
    @Published public var currentTool: PKTool = PKInkingTool(.marker, color: UIColor(Color(red: 1.0, green: 0.35, blue: 0.35)), width: 14)

    public let availableColors: [Color] = [
        Color(red: 1.0, green: 0.35, blue: 0.35),
        .orange,
        .yellow,
        .green,
        .mint,
        .blue,
        .purple,
        .pink,
        .brown,
        .black
    ]

    public init() {
        selectedShape = shapes.first
        updateTool()
    }

    public func selectShape(_ shape: DoodleObject) {
        selectedShape = shape
        clearCanvas()
    }

    public func clearCanvas() {
        drawing = PKDrawing()
        clearTrigger = UUID()
    }

    public func undo() {
        undoTrigger = UUID()
    }

    public func saveDrawing() {
        saveMessage = "Saving your masterpiece…"
        saveTrigger = UUID()
    }

    public func saveFinished(success: Bool) {
        saveMessage = success ? "Saved to Photos!" : "Photos permission is needed to save."
    }

    public func selectColor(_ color: Color) {
        selectedColor = color
        isEraserActive = false
        updateTool()
    }

    public func selectTool(_ tool: DrawingTool) {
        selectedTool = tool
        isEraserActive = false
        updateTool()
    }

    public func toggleEraser() {
        isEraserActive.toggle()
        updateTool()
    }

    public func updateTool() {
        if isEraserActive {
            currentTool = PKEraserTool(.vector)
            return
        }
        let ink: PKInkingTool.InkType = selectedTool == .pencil ? .pencil : selectedTool == .marker ? .marker : .crayon
        currentTool = PKInkingTool(ink, color: UIColor(selectedColor), width: lineWidth)
    }
}
