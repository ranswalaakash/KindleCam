//
//  EducationalShapeColorService.swift
//  KindleCam
//
//  Service that analyzes detected objects and generates exciting, child-friendly
//  explanations of what objects are used for (e.g. Clock, Laptop, Book, Chair).
//  Uses Apple Foundation Models on supported devices with smart dynamic fallbacks.
//

import Foundation
import UIKit
#if canImport(FoundationModels)
import FoundationModels
#endif

public struct EducationalAnalysisResult: Sendable, Equatable {
    public let objectLabel: String
    public let usageExplanation: String
    public let funFact: String
    
    public init(
        objectLabel: String,
        usageExplanation: String,
        funFact: String
    ) {
        self.objectLabel = objectLabel
        self.usageExplanation = usageExplanation
        self.funFact = funFact
    }
}

public final class EducationalShapeColorService: Sendable {
    
    public init() {}
    
    /// Generates educational insights on what a detected object is used for in children's language.
    public func analyze(
        objectLabel: String
    ) async -> EducationalAnalysisResult {
        #if canImport(FoundationModels)
        if let aiResult = await generateWithFoundationModels(objectLabel: objectLabel) {
            return aiResult
        }
        #endif
        
        return generateFallbackAnalysis(objectLabel: objectLabel)
    }
    
    // MARK: - Foundation Models Integration
    
    #if canImport(FoundationModels)
    @available(iOS 26.0, *)
    private func generateWithFoundationModels(
        objectLabel: String
    ) async -> EducationalAnalysisResult? {
        let model = SystemLanguageModel.default
        guard model.isAvailable else { return nil }
        
        let prompt = """
        You are a friendly teacher for children aged 3–7.

        The object is: "\(objectLabel)"

        Explain what the object is used for in simple, fun words. Also give one interesting fact about it.

        Return only this JSON:

        {
          "objectLabel": "\(objectLabel)",
          "usageExplanation": "A short, fun explanation of what the object is used for.",
          "funFact": "One simple and interesting fact about the object."
        }

        Use easy words and an excited, kid-friendly tone.
        """
        
        do {
            let session = LanguageModelSession()
            let response = try await session.respond(to: prompt)
            if let jsonData = extractJSON(from: response.content),
               let result = try? JSONDecoder().decode(EducationalAnalysisResultDTO.self, from: jsonData) {
                return result.toDomain()
            }
        } catch {
            print("[EducationalShapeColorService] AI generation error: \(error)")
        }
        return nil
    }
    
    private func extractJSON(from text: String) -> Data? {
        if let start = text.range(of: "{"), let end = text.range(of: "}", options: .backwards) {
            let jsonString = String(text[start.lowerBound...end.upperBound])
            return jsonString.data(using: .utf8)
        }
        return nil
    }
    #endif
    
    // MARK: - Dynamic Fallback Engine
    
    private func generateFallbackAnalysis(
        objectLabel: String
    ) -> EducationalAnalysisResult {
        let (usage, fact) = generateFallbackUsage(for: objectLabel)
        
        return EducationalAnalysisResult(
            objectLabel: objectLabel.capitalized,
            usageExplanation: usage,
            funFact: fact
        )
    }
    
    private func generateFallbackUsage(for label: String) -> (usage: String, fact: String) {
        let l = label.lowercased()
        if l.contains("clock") || l.contains("time") || l.contains("watch") {
            return (
                "Oh wow! A Clock tells us what time it is! It tick-tocks all day long to let us know when it's time to wake up, play with toys, eat yummy meals, and go to sleep!",
                "Did you know? Clocks have numbers from 1 to 12 around their face, and the little hands spin around to count the hours!"
            )
        } else if l.contains("laptop") || l.contains("computer") || l.contains("screen") {
            return (
                "Awesome! A Laptop is a super smart portable computer! People use it to write fun stories, learn new things, draw artwork, and talk to family!",
                "Did you know? Laptops have thousands of tiny glowing lights called pixels inside their screens to show colorful pictures!"
            )
        } else if l.contains("book") || l.contains("notebook") {
            return (
                "Oh wow! A Book is full of magical stories and exciting pictures! When you open a book, you can go on adventures with dragons, astronauts, and talking animals!",
                "Did you know? Reading books every day helps your brain grow big and strong and learn lots of amazing words!"
            )
        } else if l.contains("chair") || l.contains("couch") || l.contains("seat") {
            return (
                "Oh wow! A Chair is a cozy seat made for resting your legs! It keeps you comfortable while you draw pictures, read books, or eat delicious dinner!",
                "Did you know? Most chairs have 4 strong legs to balance sturdy and safe on the floor!"
            )
        } else if l.contains("cup") || l.contains("mug") || l.contains("bottle") || l.contains("glass") {
            return (
                "Awesome! A Cup holds tasty drinks like cold water, fresh juice, and warm milk so you can sip safely without spilling!",
                "Did you know? Cups are shaped like hollow cylinders with a round opening at the top so liquids stay inside!"
            )
        } else if l.contains("shoe") || l.contains("sneaker") || l.contains("boot") {
            return (
                "Oh wow! Shoes protect your feet when you walk, run, and jump outside! They keep your toes warm, clean, and safe from bumpy rocks!",
                "Did you know? Shoes have soft cushions inside called insoles to make every step feel like walking on clouds!"
            )
        } else if l.contains("phone") || l.contains("mobile") {
            return (
                "Awesome! A Phone is a little gadget that lets people call, text, take fun photos, and send happy messages to friends and family anywhere!",
                "Did you know? Smart phones use invisible wireless radio signals to send pictures through the air in a split second!"
            )
        } else if l.contains("ball") || l.contains("toy") {
            return (
                "Oh wow! A Ball is made for bouncy fun and games! You can roll it, catch it, kick it, and play sports with your friends!",
                "Did you know? Because a ball is perfectly round, it can roll smoothly in any direction!"
            )
        } else if l.contains("guitar") || l.contains("music") {
            return (
                "Oh wow! A Guitar is a wonderful musical instrument! You pluck its strings to play happy tunes, songs, and melody music!",
                "Did you know? Guitars have 6 strings that vibrate back and forth to create sound waves in the air!"
            )
        } else {
            let cleanName = label.capitalized
            return (
                "Oh wow! A \(cleanName) is a super helpful item! It helps us in our daily lives so we can play, learn, and do fun activities every day!",
                "Did you know? Everything in our world has its own unique story and job!"
            )
        }
    }
}

// MARK: - Private DTO for JSON Parsing
private struct EducationalAnalysisResultDTO: Codable {
    let objectLabel: String
    let usageExplanation: String
    let funFact: String
    
    func toDomain() -> EducationalAnalysisResult {
        EducationalAnalysisResult(
            objectLabel: objectLabel,
            usageExplanation: usageExplanation,
            funFact: funFact
        )
    }
}
