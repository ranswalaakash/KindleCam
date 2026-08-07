//
//  EducationalResultView.swift
//  KindleCam
//
//  Native iOS / iPadOS Discovery Result View for Shape & Color Analysis.
//  Uses Apple standard system typography, Material blurs, grouped cards,
//  hierarchical SF Symbols, and native AVSpeechSynthesizer audio playback.
//

import SwiftUI
import AVFoundation

public struct EducationalResultView: View {
    @Bindable var viewModel: CameraStoryViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var synthesizer = AVSpeechSynthesizer()
    @State private var isSpeaking: Bool = false

    public init(viewModel: CameraStoryViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                // Native System Grouped Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                if let result = viewModel.educationalResult {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 20) {
                            // 1. Captured Photo Card
                            if let captured = viewModel.capturedImage {
                                VStack(spacing: 12) {
                                    Image(uiImage: captured)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxHeight: 280)
                                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)

                                    HStack(spacing: 6) {
                                        Image(systemName: "sparkles")
                                            .foregroundStyle(.tint)
                                            .symbolRenderingMode(.hierarchical)
                                        Text(result.objectLabel)
                                            .font(.headline)
                                            .foregroundStyle(.primary)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(.ultraThinMaterial, in: Capsule())
                                }
                                .padding(12)
                                .background(Color(.secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                            }

                            // 2. What Is It Used For? Card
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(red: 0.48, green: 0.24, blue: 0.93).opacity(0.15))
                                            .frame(width: 44, height: 44)
                                        Image(systemName: "questionmark.bubble.fill")
                                            .font(.title2)
                                            .symbolRenderingMode(.hierarchical)
                                            .foregroundStyle(Color(red: 0.48, green: 0.24, blue: 0.93))
                                    }

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("WHAT IS IT USED FOR?")
                                            .font(.caption.weight(.bold))
                                            .foregroundStyle(.secondary)
                                        Text("Discover \(result.objectLabel)")
                                            .font(.title2.weight(.bold))
                                            .foregroundStyle(.primary)
                                    }

                                    Spacer()
                                }

                                Divider()

                                Text(result.usageExplanation)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                    .lineSpacing(4)
                            }
                            .padding(18)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)

                            // 3. Fun Fact Card
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 8) {
                                    Image(systemName: "lightbulb.fill")
                                        .font(.title3)
                                        .symbolRenderingMode(.hierarchical)
                                        .foregroundStyle(Color.yellow)
                                    Text("Did You Know?")
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                }

                                Text(result.funFact)
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                            // 4. Try Another Picture Button
                            Button(action: {
                                stopSpeaking()
                                viewModel.phase = .capturing
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "camera.fill")
                                        .font(.headline)
                                    Text("Capture Another Object 📸")
                                        .font(.headline)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                            }
                            .buttonStyle(.borderedProminent)
                            .buttonBorderShape(.capsule)
                            .padding(.top, 8)
                            .padding(.bottom, 24)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    }
                }
            }
            .navigationTitle("Let's Capture")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        stopSpeaking()
                        viewModel.reset()
                        dismiss()
                    }
                    .font(.body.weight(.semibold))
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(action: toggleSpeech) {
                        Label(isSpeaking ? "Pause" : "Read Aloud", systemImage: isSpeaking ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                            .labelStyle(.titleAndIcon)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                }
            }
        }
        .onAppear {
            speakResult()
        }
        .onDisappear {
            stopSpeaking()
        }
    }

    private func toggleSpeech() {
        if isSpeaking {
            stopSpeaking()
        } else {
            speakResult()
        }
    }

    private func speakResult() {
        guard let result = viewModel.educationalResult else { return }
        stopSpeaking()

        let fullText = "\(result.objectLabel). \(result.usageExplanation). \(result.funFact)"
        let utterance = AVSpeechUtterance(string: fullText)
        utterance.rate = 0.48
        utterance.pitchMultiplier = 1.15
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")

        synthesizer.speak(utterance)
        isSpeaking = true
    }

    private func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
    }
}
