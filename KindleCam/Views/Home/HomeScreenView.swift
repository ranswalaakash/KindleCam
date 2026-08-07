//
//  HomeScreenView.swift
//  KindleCam
//
//  Redesigned iPad-first Home Screen featuring 3 GIANT hero cards
//  that adapt dynamically to both Portrait and Landscape orientations,
//  a kid-friendly ambient background, BIG HERO TITLES spanning across cards,
//  zero text clipping, and native NavigationStack transitions.
//
//  Strictly no emojis — all visuals use SF Symbols, custom vector shapes,
//  and the KidDesignSystem components.
//

import SwiftUI

public struct HomeScreenView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    private var isPad: Bool {
        horizontalSizeClass == .regular
    }

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                // Kid-friendly ambient background with floating clouds, twinkling stars, and color spheres
                KidBackgroundView(variant: .home)

                // Main Home Content
                VStack(spacing: 0) {
                    // Header
                    headerSection
                        .padding(.top, isPad ? 20 : 12)
                        .padding(.bottom, isPad ? 16 : 8)

                    // 4 GIANT Feature Cards — Adaptive Geometry Container for Portrait & Landscape
                    GeometryReader { geo in
                        let isLandscape = geo.size.width > geo.size.height
                        let availW = max(0, geo.size.width - (isPad ? 48 : 24))
                        let availH = max(0, geo.size.height - 20)

                        if isLandscape {
                            // LANDSCAPE: 4 vertical column cards side-by-side
                            let cardW = max(0, (availW - 48) / 4)

                            HStack(spacing: 16) {
                                giantCameraStoryCard(isLandscape: true)
                                    .frame(width: max(0, cardW), height: max(0, availH))

                                giantCreativeDrawingCard(isLandscape: true)
                                    .frame(width: max(0, cardW), height: max(0, availH))

                                giantCuriosityCardsCard(isLandscape: true)
                                    .frame(width: max(0, cardW), height: max(0, availH))

                                giantGamesCard(isLandscape: true)
                                    .frame(width: max(0, cardW), height: max(0, availH))
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            // PORTRAIT: 4 horizontal hero cards stacked vertically.
                            // The fourth card remains reachable on smaller phones by scrolling.
                            let cardH = max(180, (availH - 48) / 4)

                            ScrollView(.vertical, showsIndicators: false) {
                                VStack(spacing: 16) {
                                    giantCameraStoryCard(isLandscape: false)
                                        .frame(width: max(0, availW), height: max(0, cardH))

                                    giantCreativeDrawingCard(isLandscape: false)
                                        .frame(width: max(0, availW), height: max(0, cardH))

                                    giantCuriosityCardsCard(isLandscape: false)
                                        .frame(width: max(0, availW), height: max(0, cardH))

                                    giantGamesCard(isLandscape: false)
                                        .frame(width: max(0, availW), height: max(0, cardH))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, isPad ? 24 : 12)
                    .padding(.bottom, isPad ? 24 : 12)
                }
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 6) {
            HStack(spacing: 10) {
                Text("KindleCam")
                    .font(.system(size: isPad ? 42 : 32, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [KidColors.cosmicPurple, KidColors.coralPink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                SparkleVector(size: isPad ? 32 : 24, color: KidColors.sunshineYellow)
            }

            Text("What would you like to explore today?")
                .font(.system(size: isPad ? 18 : 15, weight: .bold, design: .rounded))
                .foregroundStyle(KidColors.softText)
        }
    }

    // MARK: - 1. GIANT Camera Story Card (Native NavigationLink)

    private func giantCameraStoryCard(isLandscape: Bool) -> some View {
        NavigationLink(destination: CameraStoryHomeView()) {
            GiantHomeCard(
                title: "Let's Capture",
                subtitle: "Snap photos of real objects and discover what they're used for!",
                iconName: "camera.fill",
                badgeText: "CAPTURE!",
                badgeColors: [KidColors.coralPink, KidColors.roseGold],
                gradientColors: [KidColors.cosmicPurple, KidColors.cosmicPurpleEnd],
                buttonText: "Start Capturing",
                graphicType: .cameraLens,
                isLandscape: isLandscape
            )
        }
        .buttonStyle(KidPressButtonStyle())
    }

    // MARK: - 2. GIANT Creative Drawing Card (Native NavigationLink)

    private func giantCreativeDrawingCard(isLandscape: Bool) -> some View {
        NavigationLink(destination: CreativeDrawingHomeView()) {
            GiantHomeCard(
                title: "Creative Drawing",
                subtitle: "Paint on digital canvases & color fun artwork templates!",
                iconName: "paintpalette.fill",
                badgeText: "CREATIVE!",
                badgeColors: [KidColors.sunshineYellow, KidColors.coralPink],
                gradientColors: [KidColors.coralPink, KidColors.coralPinkEnd],
                buttonText: "Start Drawing",
                graphicType: .paintPalette,
                isLandscape: isLandscape
            )
        }
        .buttonStyle(KidPressButtonStyle())
    }

    // MARK: - 3. GIANT Curiosity Cards Card (Native NavigationLink)

    private func giantCuriosityCardsCard(isLandscape: Bool) -> some View {
        NavigationLink(destination: CuriosityCardsHomeView()) {
            GiantHomeCard(
                title: "Curiosity Cards",
                subtitle: "Discover science facts, space wonders & fun 3D Q&A card decks!",
                iconName: "lightbulb.fill",
                badgeText: "DISCOVER!",
                badgeColors: [KidColors.skyBlue, KidColors.tropicalTeal],
                gradientColors: [KidColors.tropicalTeal, KidColors.tropicalTealEnd],
                buttonText: "Explore Card Decks",
                graphicType: .cardStack,
                isLandscape: isLandscape
            )
        }
        .buttonStyle(KidPressButtonStyle())
    }

    // MARK: - 4. GIANT Games Card (Native NavigationLink)

    private func giantGamesCard(isLandscape: Bool) -> some View {
        NavigationLink(destination: GamesHomeView()) {
            GiantHomeCard(
                title: "Fun Learning Games",
                subtitle: "Play exciting games that build counting, memory, words, and more!",
                iconName: "gamecontroller.fill",
                badgeText: "PLAY!",
                badgeColors: [KidColors.sunshineYellow, KidColors.coralPink],
                gradientColors: [KidColors.skyBlue, KidColors.cosmicPurpleEnd],
                buttonText: "Play Games",
                graphicType: .gameController,
                isLandscape: isLandscape
            )
        }
        .buttonStyle(KidPressButtonStyle())
    }
}

// MARK: - GIANT Home Feature Card Component (Big Hero Titles & Zero Overlap)

private struct GiantHomeCard: View {
    let title: String
    let subtitle: String
    let iconName: String
    let badgeText: String
    let badgeColors: [Color]
    let gradientColors: [Color]
    let buttonText: String
    let graphicType: CardGraphicType
    let isLandscape: Bool

    enum CardGraphicType {
        case cameraLens, paintPalette, cardStack, gameController
    }

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isPad: Bool { horizontalSizeClass == .regular }

    @State private var floatGraphic = false

    var body: some View {
        GeometryReader { geo in
            let w = max(0, geo.size.width)
            let h = max(0, geo.size.height)

            ZStack(alignment: .topLeading) {
                // Background gradient
                LinearGradient(
                    colors: gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // Radial glow highlight
                RadialGradient(
                    colors: [.white.opacity(0.18), .clear],
                    center: .topLeading,
                    startRadius: 10,
                    endRadius: max(1, min(w, h) * 0.8)
                )

                // Background Graphic Visual (Positioned strictly above bottom action bar with zero overlap)
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        graphicVisual(for: graphicType, containerSize: CGSize(width: w, height: h))
                            .offset(y: floatGraphic ? -5 : 5)
                    }
                }
                .padding(.trailing, isLandscape ? 12 : 20)
                .padding(.bottom, isPad ? (isLandscape ? 52 : 60) : 46)
                .allowsHitTesting(false)

                // Card Content Overlay
                VStack(alignment: .leading, spacing: 0) {
                    // Top Bar Row: Icon Circle + Spacer + Badge
                    HStack {
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.22))
                                .frame(width: isPad ? 52 : 44, height: isPad ? 52 : 44)
                                .overlay(Circle().strokeBorder(.white.opacity(0.35), lineWidth: 1.5))

                            Image(systemName: iconName)
                                .font(.system(size: isPad ? 24 : 20, weight: .bold))
                                .foregroundStyle(.white)
                        }

                        Spacer()

                        GradientBadge(text: badgeText, colors: badgeColors, fontSize: isPad ? (isLandscape ? 10 : 11) : 9)
                    }

                    // BIG PROMINENT HERO TITLE (Spans across the card proudly)
                    Text(title)
                        .font(.system(size: isPad ? (isLandscape ? 28 : 34) : 22, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                        .padding(.top, isPad ? (isLandscape ? 10 : 14) : 8)

                    // Subtitle
                    Text(subtitle)
                        .font(.system(size: isPad ? (isLandscape ? 13 : 15) : 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.92))
                        .lineLimit(2)
                        .minimumScaleFactor(0.80)
                        .padding(.top, 4)
                        .padding(.trailing, isLandscape ? 10 : w * 0.28)

                    Spacer(minLength: 8)

                    // Bottom Action Bar
                    HStack {
                        Text(buttonText)
                            .font(.system(size: isPad ? (isLandscape ? 13 : 15) : 12, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.80)

                        Spacer(minLength: 4)

                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: isPad ? (isLandscape ? 22 : 26) : 20, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, isPad ? (isLandscape ? 14 : 18) : 12)
                    .padding(.vertical, isPad ? (isLandscape ? 10 : 13) : 8)
                    .background(
                        Capsule()
                            .fill(.white.opacity(0.22))
                            .overlay(Capsule().strokeBorder(.white.opacity(0.18), lineWidth: 1))
                    )
                    .zIndex(5)
                }
                .padding(isPad ? (isLandscape ? 18 : 24) : 14)
            }
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .strokeBorder(.white.opacity(0.25), lineWidth: 1.5)
            )
            .shadow(color: gradientColors.first?.opacity(0.32) ?? .clear, radius: 16, x: 0, y: 8)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                floatGraphic = true
            }
        }
    }

    // MARK: - Feature Card Right Visual Graphic

    @ViewBuilder
    private func graphicVisual(for type: CardGraphicType, containerSize: CGSize) -> some View {
        let w = max(0, containerSize.width)
        let h = max(0, containerSize.height)
        let size = max(0, min(w * (isLandscape ? 0.36 : 0.30), h * (isLandscape ? 0.38 : 0.42)))

        switch type {
        case .cameraLens:
            ZStack {
                Circle()
                    .fill(.white.opacity(0.15))
                    .frame(width: size, height: size)

                Image(systemName: "camera.aperture")
                    .font(.system(size: max(1, size * 0.65), weight: .bold))
                    .foregroundStyle(.white.opacity(0.85))

                SparkleVector(size: 18, color: KidColors.sunshineYellow)
                    .offset(x: size * 0.38, y: -size * 0.38)
            }

        case .paintPalette:
            ZStack {
                Circle()
                    .fill(.white.opacity(0.15))
                    .frame(width: size, height: size)

                Image(systemName: "paintpalette.fill")
                    .font(.system(size: max(1, size * 0.60), weight: .bold))
                    .foregroundStyle(.white.opacity(0.88))

                Circle()
                    .fill(KidColors.sunshineYellow)
                    .frame(width: 12, height: 12)
                    .offset(x: -size * 0.25, y: -size * 0.2)

                Circle()
                    .fill(KidColors.coralPink)
                    .frame(width: 10, height: 10)
                    .offset(x: size * 0.2, y: -size * 0.25)
            }

        case .cardStack:
            ZStack {
                // 3D Card Stack
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(LinearGradient(colors: [KidColors.coralPink, KidColors.roseGold], startPoint: .top, endPoint: .bottom))
                    .frame(width: size * 0.65, height: size * 0.85)
                    .rotationEffect(.degrees(12))
                    .offset(x: 8, y: 5)

                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(LinearGradient(colors: [KidColors.cosmicPurple, KidColors.skyBlue], startPoint: .top, endPoint: .bottom))
                    .frame(width: size * 0.65, height: size * 0.85)
                    .rotationEffect(.degrees(-8))
                    .offset(x: -6, y: -3)

                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(LinearGradient(colors: [KidColors.tropicalTeal, KidColors.mintGreen], startPoint: .top, endPoint: .bottom))
                    .frame(width: size * 0.65, height: size * 0.85)
                    .overlay(
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: max(1, size * 0.25), weight: .bold))
                            .foregroundStyle(.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .strokeBorder(.white.opacity(0.4), lineWidth: 1)
                    )
                    .rotationEffect(.degrees(3))

                SparkleVector(size: 18, color: KidColors.sunshineYellow)
                    .offset(x: size * 0.40, y: -size * 0.40)
            }

        case .gameController:
            ZStack {
                Circle()
                    .fill(.white.opacity(0.15))
                    .frame(width: size, height: size)

                Image(systemName: "gamecontroller.fill")
                    .font(.system(size: max(1, size * 0.58), weight: .bold))
                    .foregroundStyle(.white.opacity(0.88))

                SparkleVector(size: 18, color: KidColors.sunshineYellow)
                    .offset(x: size * 0.38, y: -size * 0.38)
            }
        }
    }
}

#Preview {
    HomeScreenView()
}
