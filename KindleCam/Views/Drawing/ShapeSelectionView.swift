//
//  ShapeSelectionView.swift
//  KindleCam
//
//  Horizontal shape template selector for Creative doodle drawing.
//

import SwiftUI

public struct ShapeSelectionView: View {
    @ObservedObject var viewModel: DoodleViewModel

    public init(viewModel: DoodleViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                Label("Shapes", systemImage: "square.grid.2x2.fill")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.35, blue: 0.35), Color(red: 1.0, green: 0.52, blue: 0.38)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: Capsule()
                    )

                ForEach(viewModel.shapes) { shape in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            viewModel.selectShape(shape)
                        }
                    } label: {
                        ShapeTile(shape: shape, selected: viewModel.selectedShape == shape)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(shape.title)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
    }
}

private struct ShapeTile: View {
    let shape: DoodleObject
    let selected: Bool

    var body: some View {
        Group {
            if let assetName = shape.assetName {
                Image(assetName)
                    .resizable()
                    .scaledToFit()
                    .padding(8)
            } else {
                Image(systemName: shape.symbolName)
                    .font(.title2)
                    .foregroundStyle(selected ? Color(red: 0.7, green: 0.15, blue: 0.15) : .primary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(width: 62, height: 62)
        .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(selected ? Color(red: 1.0, green: 0.35, blue: 0.35) : Color.gray.opacity(0.15), lineWidth: selected ? 3 : 1)
        }
        .shadow(color: selected ? Color(red: 1.0, green: 0.35, blue: 0.35).opacity(0.25) : Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
}
