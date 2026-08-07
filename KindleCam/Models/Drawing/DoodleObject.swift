//
//  DoodleObject.swift
//  KindleCam
//
//  Data model representing a template shape for creative doodle drawing,
//  including interactive step-by-step drawing hints.
//

import Foundation

public struct DrawingHint: Identifiable, Hashable {
    public let id: String
    public let icon: String
    public let title: String
    public let instruction: String
    
    public init(id: String = UUID().uuidString, icon: String, title: String, instruction: String) {
        self.id = id
        self.icon = icon
        self.title = title
        self.instruction = instruction
    }
}

public struct DoodleObject: Identifiable, Hashable {
    public let id: String
    public let assetName: String?
    public let symbolName: String
    public let title: String
    public let ideas: String
    public let hints: [DrawingHint]

    public init(
        assetName: String? = nil,
        symbolName: String,
        title: String,
        ideas: String,
        hints: [DrawingHint] = []
    ) {
        self.assetName = assetName
        self.symbolName = symbolName
        self.title = title
        self.ideas = ideas
        self.hints = hints
        self.id = assetName ?? symbolName
    }
}
