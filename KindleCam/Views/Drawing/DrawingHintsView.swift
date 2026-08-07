//
//  DrawingHintsView.swift
//  KindleCam
//
//  Interactive drawing hints modal sheet displaying creative step-by-step ideas for doodle shapes.
//

import AVFoundation
import SwiftUI

public struct DrawingHintsView: View {
    let shape: DoodleObject
    @Environment(\.dismiss) private var dismiss
    
    @State private var isSpeaking = false
    @State private var synthesizer = AVSpeechSynthesizer()

    public init(shape: DoodleObject) {
        self.shape = shape
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // Header Banner Card
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 1.0, green: 0.35, blue: 0.35).opacity(0.15))
                                    .frame(width: 52, height: 52)
                                Image(systemName: "lightbulb.fill")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(Color(red: 1.0, green: 0.35, blue: 0.35))
                            }

                            VStack(alignment: .leading, spacing: 3) {
                                Text("Drawing Ideas for \(shape.title)")
                                    .font(.system(size: 20, weight: .black, design: .rounded))
                                    .foregroundStyle(Color.primary)

                                Text("Try turning it into: \(shape.ideas)")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color(red: 0.7, green: 0.15, blue: 0.15))
                            }
                            Spacer()
                        }
                        .padding(16)
                        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))

                        // Speech Read-Aloud Button
                        Button(action: toggleSpeech) {
                            HStack(spacing: 8) {
                                Image(systemName: isSpeaking ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                                    .font(.system(size: 16, weight: .bold))
                                Text(isSpeaking ? "Stop Reading" : "Read Hints Aloud 🔊")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                            }
                            .foregroundStyle(isSpeaking ? Color.white : Color(red: 0.7, green: 0.15, blue: 0.15))
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(isSpeaking ? Color.orange : Color(red: 1.0, green: 0.35, blue: 0.35).opacity(0.15))
                            )
                        }

                        // Hint Cards Grid
                        VStack(spacing: 14) {
                            ForEach(shape.hints) { hint in
                                HStack(alignment: .top, spacing: 14) {
                                    Text(hint.icon)
                                        .font(.system(size: 36))
                                        .frame(width: 48, height: 48)
                                        .background(Color(red: 1.0, green: 0.95, blue: 0.90), in: Circle())

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(hint.title)
                                            .font(.system(size: 17, weight: .bold, design: .rounded))
                                            .foregroundStyle(Color(red: 0.7, green: 0.15, blue: 0.15))

                                        Text(hint.instruction)
                                            .font(.system(size: 15, weight: .medium, design: .rounded))
                                            .foregroundStyle(Color.primary.opacity(0.85))
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    Spacer(minLength: 0)
                                }
                                .padding(16)
                                .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                            }
                        }

                        // Bottom Action Button
                        Button(action: {
                            stopSpeech()
                            dismiss()
                        }) {
                            Text("Got It! Let's Draw 🎨")
                                .font(.system(size: 17, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    LinearGradient(
                                        colors: [Color(red: 1.0, green: 0.35, blue: 0.35), Color(red: 1.0, green: 0.52, blue: 0.38)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                                )
                                .shadow(color: Color(red: 1.0, green: 0.35, blue: 0.35).opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.top, 8)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Creative Hints")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        stopSpeech()
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.secondary)
                    }
                }
            }
            .onDisappear {
                stopSpeech()
            }
        }
    }

    private func toggleSpeech() {
        if isSpeaking {
            stopSpeech()
        } else {
            let fullText = "Drawing hints for \(shape.title). " + shape.hints.map { "\($0.title): \($0.instruction)" }.joined(separator: " ")
            let utterance = AVSpeechUtterance(string: fullText)
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            synthesizer.speak(utterance)
            isSpeaking = true
        }
    }

    private func stopSpeech() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
    }
}
