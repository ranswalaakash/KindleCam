//
//  DoodleView.swift
//  KindleCam
//
//  Main Creative Doodle drawing studio view.
//

import SwiftUI

public struct DoodleView: View {
    @StateObject private var viewModel = DoodleViewModel()
    @State private var showHintSheet = false

    public init() {}

    public var body: some View {
        GeometryReader { proxy in
            let isLandscape = proxy.size.width > proxy.size.height
            let horizontalPadding: CGFloat = 16
            
            // Calculate a generous canvas size that fills available screen space
            let maxCanvasSide = isLandscape
                ? min(proxy.size.width - 340, proxy.size.height - 100)
                : min(proxy.size.width - (horizontalPadding * 2), proxy.size.height - 280)
            let canvasSide = max(300, maxCanvasSide)

            ZStack {
                // Background Gradient matching Creative Drawing theme
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.96, blue: 0.96),
                        Color(red: 1.0, green: 0.91, blue: 0.91)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 12) {
                    // Header Subtitle Banner
                    if let shape = viewModel.selectedShape {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 1.0, green: 0.35, blue: 0.35).opacity(0.15))
                                    .frame(width: 38, height: 38)
                                Image(systemName: "lightbulb.fill")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(Color(red: 1.0, green: 0.35, blue: 0.35))
                            }
                            
                            HStack(spacing: 4) {
                                Text("Turn the \(shape.title) into...")
                                    .font(.system(size: 18, weight: .black, design: .rounded))
                                    .foregroundStyle(Color(red: 0.7, green: 0.15, blue: 0.15))
                                
                                Image(systemName: "sparkles")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(Color(red: 1.0, green: 0.6, blue: 0.2))
                            }
                            Spacer()

                            // Interactive Hint Button
                            Button(action: { showHintSheet = true }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "lightbulb.fill")
                                        .font(.system(size: 14, weight: .bold))
                                    Text("Hints 💡")
                                        .font(.system(size: 14, weight: .black, design: .rounded))
                                }
                                .foregroundStyle(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color(red: 1.0, green: 0.35, blue: 0.35), Color(red: 1.0, green: 0.52, blue: 0.38)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .shadow(color: Color(red: 1.0, green: 0.35, blue: 0.35).opacity(0.3), radius: 6, x: 0, y: 3)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
                        )
                    }

                    if isLandscape {
                        HStack(spacing: 16) {
                            landscapeToolRail
                                .frame(width: 220)

                            canvasContainer
                                .frame(width: canvasSide, height: canvasSide)

                            LandscapeShapeRail(viewModel: viewModel)
                                .frame(width: 90, height: canvasSide)
                        }
                    } else {
                        canvasContainer
                            .frame(width: canvasSide, height: canvasSide)

                        toolPalette

                        ShapeSelectionView(viewModel: viewModel)
                            .background(.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                // Native Toast Banner for Save Notifications
                if let message = viewModel.saveMessage {
                    VStack {
                        Spacer()
                        HStack(spacing: 8) {
                            Image(systemName: message.hasPrefix("Saved") ? "checkmark.circle.fill" : "info.circle.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(message.hasPrefix("Saved") ? Color.green : Color.orange)

                            Text(message)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.primary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
                        )
                        .padding(.bottom, 20)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .task(id: message) {
                        try? await Task.sleep(for: .seconds(2.5))
                        guard !Task.isCancelled, viewModel.saveMessage == message else { return }
                        withAnimation { viewModel.saveMessage = nil }
                    }
                }
            }
        }
        .navigationTitle(viewModel.selectedShape != nil ? viewModel.selectedShape!.title : "Creative Canvas")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showHintSheet) {
            if let shape = viewModel.selectedShape {
                DrawingHintsView(shape: shape)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: { viewModel.undo() }) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 16, weight: .bold))
                }
                .accessibilityLabel("Undo")

                Button(action: { viewModel.clearCanvas() }) {
                    Image(systemName: "trash")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.red)
                }
                .accessibilityLabel("Clear Canvas")

                Button(action: { viewModel.saveDrawing() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.down.fill")
                            .font(.system(size: 14, weight: .bold))
                        Text("Save")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.35, blue: 0.35), Color(red: 1.0, green: 0.52, blue: 0.38)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: Capsule()
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .onAppear {
            lockLandscape()
        }
        .onDisappear {
            unlockOrientation()
        }
    }

    private func lockLandscape() {
        AppDelegate.orientationLock = .landscape
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscape)) { _ in }
        }
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }

    private func unlockOrientation() {
        AppDelegate.orientationLock = .all
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .all)) { _ in }
        }
        UIViewController.attemptRotationToDeviceOrientation()
    }

    private var canvasContainer: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 6)

            if let shape = viewModel.selectedShape {
                GeometryReader { board in
                    VStack {
                        Spacer()
                        ReferenceShape(shape: shape)
                            .frame(width: board.size.width * 0.52, height: board.size.height * 0.52)
                            .opacity(0.16)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .allowsHitTesting(false)
                }
            }

            DrawingCanvasView(
                drawing: $viewModel.drawing,
                tool: $viewModel.currentTool,
                clearTrigger: $viewModel.clearTrigger,
                undoTrigger: $viewModel.undoTrigger,
                saveTrigger: $viewModel.saveTrigger
            ) { success in
                viewModel.saveFinished(success: success)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
    }

    private var toolPalette: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                Text("Tools")
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color(red: 0.7, green: 0.15, blue: 0.15))

                ForEach(DrawingTool.allCases) { tool in
                    Button { viewModel.selectTool(tool) } label: {
                        ToolButton(tool: tool, selected: viewModel.selectedTool == tool && !viewModel.isEraserActive)
                            .frame(width: 70)
                    }
                    .buttonStyle(.plain)
                }

                Button { viewModel.toggleEraser() } label: {
                    ToolButton(symbol: "eraser.fill", title: "Eraser", selected: viewModel.isEraserActive)
                        .frame(width: 70)
                }
                .buttonStyle(.plain)

                Divider().frame(height: 44)

                Text("Colors")
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color(red: 0.7, green: 0.15, blue: 0.15))

                ForEach(viewModel.availableColors, id: \.self) { color in
                    Button { viewModel.selectColor(color) } label: {
                        Circle()
                            .fill(color)
                            .frame(width: 28, height: 28)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: viewModel.selectedColor == color && !viewModel.isEraserActive ? 3 : 0)
                            )
                            .shadow(radius: 2)
                    }
                    .buttonStyle(.plain)
                }

                ColorPicker("Custom color", selection: $viewModel.selectedColor, supportsOpacity: false)
                    .labelsHidden()
                    .onChange(of: viewModel.selectedColor) { _, _ in viewModel.selectColor(viewModel.selectedColor) }

                Divider().frame(height: 44)

                Text("Size")
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color(red: 0.7, green: 0.15, blue: 0.15))

                Slider(value: $viewModel.lineWidth, in: 4...34)
                    .tint(Color(red: 1.0, green: 0.35, blue: 0.35))
                    .frame(width: 110)
                    .onChange(of: viewModel.lineWidth) { _, _ in viewModel.updateTool() }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
        }
        .background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }

    private var landscapeToolRail: some View {
        VStack(spacing: 10) {
            Text("Tools")
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundStyle(Color(red: 0.7, green: 0.15, blue: 0.15))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(DrawingTool.allCases) { tool in
                    Button { viewModel.selectTool(tool) } label: {
                        ToolButton(tool: tool, selected: viewModel.selectedTool == tool && !viewModel.isEraserActive)
                    }
                    .buttonStyle(.plain)
                }
                Button { viewModel.toggleEraser() } label: {
                    ToolButton(symbol: "eraser.fill", title: "Eraser", selected: viewModel.isEraserActive)
                }
                .buttonStyle(.plain)
            }

            Divider()

            Text("Colors")
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundStyle(Color(red: 0.7, green: 0.15, blue: 0.15))

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 6) {
                ForEach(viewModel.availableColors, id: \.self) { color in
                    Button { viewModel.selectColor(color) } label: {
                        Circle()
                            .fill(color)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: viewModel.selectedColor == color && !viewModel.isEraserActive ? 2 : 0)
                            )
                    }
                    .buttonStyle(.plain)
                }
                ColorPicker("Custom color", selection: $viewModel.selectedColor, supportsOpacity: false)
                    .labelsHidden()
                    .onChange(of: viewModel.selectedColor) { _, _ in viewModel.selectColor(viewModel.selectedColor) }
            }

            Divider()

            Text("Size")
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundStyle(Color(red: 0.7, green: 0.15, blue: 0.15))

            Slider(value: $viewModel.lineWidth, in: 4...34)
                .tint(Color(red: 1.0, green: 0.35, blue: 0.35))
                .onChange(of: viewModel.lineWidth) { _, _ in viewModel.updateTool() }
        }
        .padding(12)
        .background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}

private struct LandscapeShapeRail: View {
    @ObservedObject var viewModel: DoodleViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 8) {
                ForEach(viewModel.shapes) { shape in
                    Button {
                        withAnimation(.spring(response: 0.3)) { viewModel.selectShape(shape) }
                    } label: {
                        Group {
                            if let assetName = shape.assetName {
                                Image(assetName)
                                    .resizable()
                                    .scaledToFit()
                                    .padding(6)
                            } else {
                                Image(systemName: shape.symbolName)
                                    .font(.title3)
                                    .foregroundStyle(Color(red: 1.0, green: 0.35, blue: 0.35))
                            }
                        }
                        .frame(width: 52, height: 52)
                        .background(.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(viewModel.selectedShape == shape ? Color(red: 1.0, green: 0.35, blue: 0.35) : Color.clear, lineWidth: 2)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
        }
        .background(.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct ReferenceShape: View {
    let shape: DoodleObject

    var body: some View {
        Group {
            if let asset = shape.assetName {
                Image(asset)
                    .resizable()
                    .scaledToFit()
                    .opacity(0.30)
            } else {
                Image(systemName: shape.symbolName)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Color.black.opacity(0.30))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct ToolButton: View {
    let symbol: String
    let title: String
    let selected: Bool

    init(tool: DrawingTool, selected: Bool) {
        symbol = tool.symbol
        title = tool.label
        self.selected = selected
    }

    init(symbol: String, title: String, selected: Bool) {
        self.symbol = symbol
        self.title = title
        self.selected = selected
    }

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .bold))
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
        }
        .foregroundStyle(selected ? Color(red: 0.7, green: 0.15, blue: 0.15) : .primary)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            selected ? Color(red: 1.0, green: 0.35, blue: 0.35).opacity(0.14) : Color.gray.opacity(0.08),
            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(selected ? Color(red: 1.0, green: 0.35, blue: 0.35) : Color.clear, lineWidth: 2)
        }
    }
}

#Preview {
    NavigationStack {
        DoodleView()
    }
}
