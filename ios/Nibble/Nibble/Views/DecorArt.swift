//
//  DecorArt.swift
//  Nibble — Sprout Snacks
//
//  Vector-drawn furniture and decorations, used in the shop and placed in the
//  Sprout's room. Everything is drawn with SwiftUI shapes in a 100×100 design
//  space so it scales crisply — no emoji, no image assets.
//

import SwiftUI

struct DecorArt: View {
    let id: String
    var size: CGFloat = 60

    var body: some View {
        art
            .frame(width: 100, height: 100)
            .scaleEffect(size / 100)
            .frame(width: size, height: size)
    }

    @ViewBuilder private var art: some View {
        switch id {
        case "kit_stove":    Stove()
        case "kit_fridge":   Fridge()
        case "kit_kettle":   Kettle()
        case "gar_planter":  Planter()
        case "gar_tree":     PottedTree()
        case "gar_flowers":  FlowerVase()
        case "coz_lamp":     Lamp()
        case "coz_rug":      Rug()
        case "coz_books":    BookStack()
        case "coz_frame":    ArtFrame()
        default:             EmptyView()
        }
    }
}

// MARK: - Kitchen

private struct Stove: View {
    var body: some View {
        ZStack {
            // body
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(hex: "F6F1E7").gradient)
                .frame(width: 64, height: 56)
                .offset(y: 14)
            // cooktop
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color(hex: "3D4450"))
                .frame(width: 64, height: 12)
                .offset(y: -16)
            Circle().fill(Color(hex: "5A6270")).frame(width: 8).offset(x: -14, y: -16)
            Circle().fill(Color(hex: "5A6270")).frame(width: 8).offset(x: 14, y: -16)
            // oven window
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color(hex: "8A93A3"))
                .frame(width: 40, height: 24)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(hex: "3D4450"), lineWidth: 3))
                .offset(y: 18)
            // knobs
            HStack(spacing: 8) {
                Circle().fill(Color(hex: "C0594F")).frame(width: 7)
                Circle().fill(Color(hex: "C0594F")).frame(width: 7)
            }
            .offset(y: -2)
            // pot on top
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: "C0594F").gradient)
                .frame(width: 26, height: 14)
                .offset(x: -14, y: -29)
            Capsule().fill(Color(hex: "9E463D")).frame(width: 30, height: 4).offset(x: -14, y: -36)
        }
    }
}

private struct Fridge: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(hex: "BFE3F2").gradient)
                .frame(width: 50, height: 84)
            // door split
            Rectangle().fill(Color(hex: "8FBFD4")).frame(width: 50, height: 3).offset(y: -12)
            // handles
            Capsule().fill(Color(hex: "5A8CA3")).frame(width: 4, height: 14).offset(x: 17, y: -22)
            Capsule().fill(Color(hex: "5A8CA3")).frame(width: 4, height: 20).offset(x: 17, y: 4)
            // feet
            Capsule().fill(Color(hex: "5A8CA3")).frame(width: 8, height: 5).offset(x: -16, y: 44)
            Capsule().fill(Color(hex: "5A8CA3")).frame(width: 8, height: 5).offset(x: 16, y: 44)
        }
    }
}

private struct Kettle: View {
    var body: some View {
        ZStack {
            // body
            Circle()
                .fill(Color(hex: "E9B824").gradient)
                .frame(width: 52, height: 52)
                .offset(y: 12)
            // spout
            Capsule()
                .fill(Color(hex: "E9B824"))
                .frame(width: 26, height: 10)
                .rotationEffect(.degrees(-30))
                .offset(x: -28, y: 0)
            // handle
            Circle()
                .trim(from: 0.05, to: 0.45)
                .stroke(Color(hex: "B08054"), style: .init(lineWidth: 6, lineCap: .round))
                .frame(width: 40, height: 40)
                .offset(y: -6)
            // lid
            Circle().fill(Color(hex: "B08054")).frame(width: 10).offset(y: -16)
            // shine
            Ellipse().fill(.white.opacity(0.35)).frame(width: 12, height: 20)
                .rotationEffect(.degrees(20)).offset(x: -12, y: 6)
        }
    }
}

// MARK: - Garden

private struct Planter: View {
    var body: some View {
        ZStack {
            // sprigs
            ForEach(0..<3, id: \.self) { i in
                let x = CGFloat(i - 1) * 20
                LeafBlade().fill(Color(hex: "5FA86A").gradient)
                    .frame(width: 16, height: 30)
                    .offset(x: x - 4, y: -14)
                LeafBlade().fill(Color(hex: "7BC47F").gradient)
                    .frame(width: 16, height: 26)
                    .scaleEffect(x: -1)
                    .offset(x: x + 4, y: -11)
            }
            // box
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color(hex: "B08054").gradient)
                .frame(width: 72, height: 26)
                .offset(y: 16)
            Rectangle().fill(Color(hex: "8F6844")).frame(width: 72, height: 5).offset(y: 5)
        }
    }
}

private struct PottedTree: View {
    var body: some View {
        ZStack {
            // trunk
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(hex: "8F6844"))
                .frame(width: 8, height: 30)
                .offset(y: 14)
            // foliage blobs
            Circle().fill(Color(hex: "5FA86A").gradient).frame(width: 40).offset(x: -10, y: -16)
            Circle().fill(Color(hex: "7BC47F").gradient).frame(width: 44).offset(x: 10, y: -22)
            Circle().fill(Color(hex: "69B06E").gradient).frame(width: 34).offset(y: -4)
            // pot
            Trapezoid().fill(Color(hex: "C0594F").gradient).frame(width: 40, height: 24).offset(y: 36)
            Capsule().fill(Color(hex: "9E463D")).frame(width: 46, height: 6).offset(y: 24)
        }
    }
}

private struct FlowerVase: View {
    var body: some View {
        ZStack {
            // stems
            ForEach(0..<3, id: \.self) { i in
                let x = CGFloat(i - 1) * 12
                Capsule().fill(Color(hex: "5FA86A"))
                    .frame(width: 3, height: 28)
                    .rotationEffect(.degrees(Double(i - 1) * 14))
                    .offset(x: x * 0.5, y: -8)
            }
            // blooms
            Bloom(petal: Color(hex: "F4A6B8")).offset(x: -12, y: -24)
            Bloom(petal: Color(hex: "E9B824")).offset(x: 1, y: -30)
            Bloom(petal: Color(hex: "9B7CD4")).offset(x: 13, y: -22)
            // vase
            Trapezoid().fill(Color(hex: "BFE3F2").gradient)
                .frame(width: 28, height: 30)
                .scaleEffect(y: -1)
                .offset(y: 22)
        }
    }
    private struct Bloom: View {
        let petal: Color
        var body: some View {
            ZStack {
                ForEach(0..<5, id: \.self) { i in
                    let a = Double(i) / 5 * .pi * 2
                    Circle().fill(petal).frame(width: 9)
                        .offset(x: CGFloat(cos(a) * 7), y: CGFloat(sin(a) * 7))
                }
                Circle().fill(Color(hex: "FFE08A")).frame(width: 8)
            }
        }
    }
}

// MARK: - Cozy nook

private struct Lamp: View {
    var body: some View {
        ZStack {
            // glow
            Circle().fill(Color(hex: "FFE08A").opacity(0.35)).frame(width: 60).offset(y: -18)
            // shade
            Trapezoid().fill(Color(hex: "F4A259").gradient).frame(width: 44, height: 30).offset(y: -22)
            // pole
            RoundedRectangle(cornerRadius: 2).fill(Color(hex: "8F6844")).frame(width: 5, height: 42).offset(y: 12)
            // base
            Capsule().fill(Color(hex: "8F6844")).frame(width: 30, height: 7).offset(y: 36)
        }
    }
}

private struct Rug: View {
    var body: some View {
        ZStack {
            Ellipse().fill(Color(hex: "E0B98F").gradient).frame(width: 86, height: 40)
            Ellipse().stroke(Color(hex: "C99B6C"), lineWidth: 4).frame(width: 64, height: 28)
            Ellipse().fill(Color(hex: "F2D8BB")).frame(width: 38, height: 16)
        }
    }
}

private struct BookStack: View {
    var body: some View {
        VStack(spacing: 0) {
            book(Color(hex: "C0594F"), width: 44)
            book(Color(hex: "5FA8D3"), width: 52)
            book(Color(hex: "5FA86A"), width: 48)
        }
        .offset(y: 16)
    }
    private func book(_ color: Color, width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 3, style: .continuous)
            .fill(color.gradient)
            .frame(width: width, height: 13)
            .overlay(
                Rectangle().fill(.white.opacity(0.5)).frame(width: 4)
                    .offset(x: -width / 2 + 6)
            )
    }
}

private struct ArtFrame: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color(hex: "E9B824").gradient)
                .frame(width: 62, height: 50)
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(Color(hex: "DCEEFF"))
                .frame(width: 48, height: 36)
            // tiny landscape
            Circle().fill(Color(hex: "F4C542")).frame(width: 10).offset(x: 12, y: -8)
            HillShape().fill(Color(hex: "5FA86A")).frame(width: 48, height: 16).offset(y: 10)
        }
    }
}

// MARK: - Small helper shapes

struct Trapezoid: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX + rect.width * 0.16, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.16, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

private struct LeafBlade: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        p.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.minY),
                       control: CGPoint(x: rect.minX, y: rect.midY))
        p.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.maxY),
                       control: CGPoint(x: rect.maxX, y: rect.midY))
        return p
    }
}

private struct HillShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY),
                       control: CGPoint(x: rect.midX, y: rect.minY - rect.height * 0.4))
        p.closeSubpath()
        return p
    }
}

// MARK: - Sparkle (used by the Sprout's celebration)

struct SparkleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let r = min(rect.width, rect.height) / 2
        let inner = r * 0.32
        for i in 0..<8 {
            let a = Double(i) * .pi / 4 - .pi / 2
            let radius = i % 2 == 0 ? r : inner
            let pt = CGPoint(x: c.x + CGFloat(cos(a)) * radius, y: c.y + CGFloat(sin(a)) * radius)
            if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
        }
        p.closeSubpath()
        return p
    }
}
