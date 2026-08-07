//
//  GeneratedStoryContent.swift
//  KindleCam
//
//  DTOs used to map structured output from Foundation Models into SwiftData models.
//  These structs carry the AI-generated story and task definitions before they are
//  persisted as CameraStory + StoryTask records.
//

import Foundation

public struct GeneratedStoryContent: Codable, Sendable {
    public let title: String
    public let story: String
    public let tasks: [GeneratedTaskContent]
    
    public init(title: String, story: String, tasks: [GeneratedTaskContent]) {
        self.title = title
        self.story = story
        self.tasks = tasks
    }
}

public struct GeneratedTaskContent: Codable, Sendable {
    public let title: String
    public let storySegment: String
    public let taskDescription: String
    public let taskType: TaskType
    public let difficulty: DifficultyLevel
    public let payload: TaskPayload
    
    public init(
        title: String,
        storySegment: String,
        taskDescription: String,
        taskType: TaskType,
        difficulty: DifficultyLevel,
        payload: TaskPayload
    ) {
        self.title = title
        self.storySegment = storySegment
        self.taskDescription = taskDescription
        self.taskType = taskType
        self.difficulty = difficulty
        self.payload = payload
    }
}

public enum TaskPayload: Codable, Sendable, Equatable {
    case quiz(options: [String], correctAnswerIndex: Int)
    case count(correctCount: Int, objectLabel: String)
    case tap(targetCount: Int, objectLabel: String)
    
    
    private enum CodingKeys: String, CodingKey {
        case type, options, correctAnswerIndex, correctCount, targetCount, objectLabel
    }
    
    private enum PayloadType: String, Codable {
        case quiz, count, tap
    }
    
    public nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .quiz(let options, let correctAnswerIndex):
            try container.encode(PayloadType.quiz, forKey: .type)
            try container.encode(options, forKey: .options)
            try container.encode(correctAnswerIndex, forKey: .correctAnswerIndex)
        case .count(let correctCount, let objectLabel):
            try container.encode(PayloadType.count, forKey: .type)
            try container.encode(correctCount, forKey: .correctCount)
            try container.encode(objectLabel, forKey: .objectLabel)
        case .tap(let targetCount, let objectLabel):
            try container.encode(PayloadType.tap, forKey: .type)
            try container.encode(targetCount, forKey: .targetCount)
            try container.encode(objectLabel, forKey: .objectLabel)
        }
    }
    
    public nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(PayloadType.self, forKey: .type)
        switch type {
        case .quiz:
            let options = try container.decode([String].self, forKey: .options)
            let correctAnswerIndex = try container.decode(Int.self, forKey: .correctAnswerIndex)
            self = .quiz(options: options, correctAnswerIndex: correctAnswerIndex)
        case .count:
            let correctCount = try container.decode(Int.self, forKey: .correctCount)
            let objectLabel = try container.decode(String.self, forKey: .objectLabel)
            self = .count(correctCount: correctCount, objectLabel: objectLabel)
        case .tap:
            let targetCount = try container.decode(Int.self, forKey: .targetCount)
            let objectLabel = try container.decode(String.self, forKey: .objectLabel)
            self = .tap(targetCount: targetCount, objectLabel: objectLabel)
        }
    }
}
