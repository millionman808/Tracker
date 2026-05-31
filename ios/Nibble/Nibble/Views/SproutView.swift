//
//  SproutView.swift
//  Nibble — Sprout Snacks
//
//  The companion, drawn entirely with SwiftUI shapes so it animates smoothly
//  and needs no external art. Moods: neutral, happy, eating, sleepy,
//  celebrating. Skins recolour the body and swap the topper.
//
//  By design there is NO sad state — the Sprout is never distressed by eating.
//

import SwiftUI

// MARK: - Skin palette

struct SproutSkin {
    let body: Color
    let cheek: Color
    let topper: Topper

    enum Topper { case leaf, flower, cap, petals, stem }

    static func forID(_ id: String) -> SproutSkin {
        switch id {
        case "skin_cactus":
            return SproutSkin(body: Color(hex: "5FA86A"), cheek: Color(hex: "F0B3A0"), topper: .flower)
        case "skin_mushroom":
            return SproutSkin(body: Color(hex: "E8D9C5"), cheek: Color(hex: "F4A6B8"), topper: .cap)
        case "skin_sunflower":
            return SproutSkin(body: Color(hex: "F4C542"), cheek: Color(hex: "E89B6C"), topper: .petals)
        case "skin_cherry":
            return SproutSkin(body: Color(hex: "E06377"), cheek: Color(hex: "FFD1DC"), topper: .stem)
        default:
            return SproutSkin(body: Color(hex: "7BC47F"), cheek: Color(hex: "F4A6B8"), topper: .leaf)
        }
    }

    static func emoji(_ id: String) -> String {
        switch id {
        case "skin_cactus": return "🌵"
        case "skin_mushroom": return "🍄"
        case "skin_sunflower": return "🌻"
        case "skin_cherry": return "🍒"
        default: return "🌱"
        }
    }
}

// MARK: - Body blob shape (drawn in a fixed 200×230 design space)

private struct SproutBody: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 100, y: 56))
        p.addCurve(to: CGPoint(x: 160, y: 128),
                   control1: CGPoint(x: 144, y: 56), control2: CGPoint(x: 160, y: 92))
        p.addCurve(to: CGPoint(x: 100, y: 196),
                   control1: CGPoint(x: 160, y: 172), control2: CGPoint(x: 132, y: 196))
        p.addCurve(to: CGPoint(x: 40, y: 128),
                   control1: CGPoint(x: 68, y: 196), control2: CGPoint(x: 40, y: 172))
        p.addCurve(to: CGPoint(x: 100, y: 56),
                   control1: CGPoint(x: 40, y: 92), control2: CGPoint(x: 56, y: 56))
        p.closeSubpath()
        return p
    }
}

private struct Smile: Shape {
    var open: Bool = false
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY),
                       control: CGPoint(x: rect.midX, y: rect.maxY))
        if open { p.closeSubpath() }
        return p
    }
}

// MARK: - SproutView

struct SproutView: View {
    let skinID: String
    let mood: Mood
    var size: CGFloat = 170

    @State private var breathe = false
    @State private var sway = false
    @State private var pulse = false

    private var skin: SproutSkin { SproutSkin.forID(skinID) }
    private let design = CGSize(width: 200, height: 230)

    var body: some View {
        ZStack {
            // ground shadow
            Ellipse()
                .fill(Color.black.opacity(0.12))
                .frame(width: 110, height: 22)
                .position(x: 100, y: 214)

            topper
                .rotationEffect(.degrees(sway ? 5 : -5), anchor: .bottom)
                .position(x: 100, y: 44)

            bodyGroup
        }
        .frame(width: design.width, height: design.height)
        .scaleEffect(size / design.width)
        .frame(width: size, height: size * (design.height / design.width))
        .scaleEffect(pulse ? 1.12 : 1.0)
        .onAppear {
            withAnimation(.easeInOut(duration: 3.6).repeatForever(autoreverses: true)) { breathe = true }
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) { sway = true }
        }
        .onChange(of: mood) { _, newValue in
            if newValue == .eating || newValue == .happy || newValue == .celebrating { doPulse() }
        }
    }

    private func doPulse() {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.4)) { pulse = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { pulse = false }
        }
    }

    // MARK: Body + face

    private var bodyGroup: some View {
        ZStack {
            SproutBody().fill(skin.body)
            SproutBody()
                .fill(Color.white.opacity(0.14))
                .scaleEffect(0.78)

            // cheeks
            Circle().fill(skin.cheek).opacity(0.8).frame(width: 20).position(x: 68, y: 132)
            Circle().fill(skin.cheek).opacity(0.8).frame(width: 20).position(x: 132, y: 132)

            face

            // arms
            arm(left: true)
            arm(left: false)

            moodExtras
        }
        .scaleEffect(x: 1, y: breathe ? 0.97 : 1.0, anchor: .bottom)
        .rotationEffect(.degrees(moodRotation), anchor: .bottom)
        .offset(y: moodHop)
        .animation(moodBodyAnimation, value: breathe)
    }

    @ViewBuilder private var face: some View {
        let ink = Color(hex: "3A3A3A")
        switch mood {
        case .sleepy:
            ClosedEye().stroke(ink, style: .init(lineWidth: 5, lineCap: .round)).frame(width: 20, height: 10).position(x: 84, y: 112)
            ClosedEye().stroke(ink, style: .init(lineWidth: 5, lineCap: .round)).frame(width: 20, height: 10).position(x: 116, y: 112)
            Circle().fill(ink).frame(width: 7).position(x: 100, y: 136)
        case .happy:
            HappyEye().stroke(ink, style: .init(lineWidth: 6, lineCap: .round)).frame(width: 20, height: 10).position(x: 84, y: 110)
            HappyEye().stroke(ink, style: .init(lineWidth: 6, lineCap: .round)).frame(width: 20, height: 10).position(x: 116, y: 110)
            Smile().stroke(ink, style: .init(lineWidth: 5, lineCap: .round)).frame(width: 34, height: 16).position(x: 100, y: 130)
        case .eating:
            Circle().fill(ink).frame(width: 7).position(x: 84, y: 108)
            Circle().fill(ink).frame(width: 7).position(x: 116, y: 108)
            Ellipse().fill(Color(hex: "7A3B3B")).frame(width: 24, height: 20).position(x: 100, y: 134)
        case .celebrating:
            HappyEye().stroke(ink, style: .init(lineWidth: 6, lineCap: .round)).frame(width: 20, height: 12).position(x: 84, y: 110)
            HappyEye().stroke(ink, style: .init(lineWidth: 6, lineCap: .round)).frame(width: 20, height: 12).position(x: 116, y: 110)
            Smile(open: true).fill(Color(hex: "7A3B3B")).frame(width: 36, height: 22).position(x: 100, y: 126)
        case .neutral:
            Circle().fill(ink).frame(width: 7).position(x: 84, y: 108)
            Circle().fill(ink).frame(width: 7).position(x: 116, y: 108)
            Smile().stroke(ink, style: .init(lineWidth: 5, lineCap: .round)).frame(width: 24, height: 10).position(x: 100, y: 130)
        }
    }

    @ViewBuilder private var moodExtras: some View {
        switch mood {
        case .sleepy:
            Text("z").font(.system(size: 16, weight: .bold)).foregroundStyle(Color(hex: "9AAAAA")).opacity(breathe ? 0.2 : 1).position(x: 150, y: 70)
            Text("z").font(.system(size: 22, weight: .bold)).foregroundStyle(Color(hex: "9AAAAA")).opacity(breathe ? 1 : 0.2).position(x: 162, y: 50)
        case .celebrating:
            Text("✨").font(.system(size: 18)).position(x: 40, y: 60).opacity(sway ? 1 : 0.3)
            Text("⭐️").font(.system(size: 16)).position(x: 100, y: 36).opacity(breathe ? 1 : 0.3)
            Text("✨").font(.system(size: 18)).position(x: 160, y: 70).opacity(sway ? 0.3 : 1)
        case .eating:
            Text("🍃").font(.system(size: 18)).position(x: 128, y: 124).rotationEffect(.degrees(breathe ? -12 : 0))
        default:
            EmptyView()
        }
    }

    private func arm(left: Bool) -> some View {
        ArmShape(left: left)
            .stroke(skin.body, style: .init(lineWidth: 12, lineCap: .round))
            .frame(width: 30, height: 30)
            .position(x: left ? 40 : 160, y: 150)
            .rotationEffect(.degrees((left ? -1 : 1) * (sway ? 12 : -2)),
                            anchor: left ? .topTrailing : .topLeading)
    }

    // MARK: Topper

    @ViewBuilder private var topper: some View {
        switch skin.topper {
        case .leaf:
            ZStack {
                Leaf().fill(Color(hex: "4F9D57")).frame(width: 30, height: 22).offset(x: 12, y: -2)
                Leaf().fill(Color(hex: "5FB368")).frame(width: 30, height: 22).scaleEffect(x: -1).offset(x: -12, y: 0)
            }
        case .flower:
            ZStack {
                ForEach(0..<5, id: \.self) { i in
                    let a = Double(i) / 5 * .pi * 2
                    Circle().fill(Color(hex: "F7C9D6")).frame(width: 12)
                        .offset(x: CGFloat(cos(a) * 10), y: CGFloat(sin(a) * 10))
                }
                Circle().fill(Color(hex: "FFE08A")).frame(width: 9)
            }
        case .cap:
            ZStack {
                CapDome().fill(Color(hex: "C0594F")).frame(width: 86, height: 44).offset(y: 14)
                Circle().fill(.white).frame(width: 7).offset(x: -14, y: 4)
                Circle().fill(.white).frame(width: 5).offset(x: 12, y: 6)
                Circle().fill(.white).frame(width: 6).offset(x: 0, y: -2)
            }
        case .petals:
            ZStack {
                ForEach(0..<8, id: \.self) { i in
                    let a = Double(i) / 8 * .pi * 2
                    Ellipse().fill(Color(hex: "F4C542")).frame(width: 14, height: 7)
                        .offset(x: CGFloat(cos(a) * 16), y: CGFloat(sin(a) * 16))
                        .rotationEffect(.radians(a))
                }
                Circle().fill(Color(hex: "7A4A25")).frame(width: 18)
            }
        case .stem:
            ZStack {
                StemShape().stroke(Color(hex: "4F9D57"), style: .init(lineWidth: 4, lineCap: .round))
                    .frame(width: 24, height: 28)
                Leaf().fill(Color(hex: "5FB368")).frame(width: 16, height: 10).offset(x: 12, y: -6)
            }
        }
    }

    // MARK: Mood-driven motion

    private var moodRotation: Double {
        guard mood == .happy else { return 0 }
        return sway ? 2 : -2
    }
    private var moodHop: CGFloat {
        guard mood == .celebrating else { return 0 }
        return breathe ? -8 : 0
    }
    private var moodBodyAnimation: Animation {
        switch mood {
        case .happy:       return .easeInOut(duration: 1.6).repeatForever(autoreverses: true)
        case .celebrating: return .easeInOut(duration: 0.6).repeatForever(autoreverses: true)
        default:           return .easeInOut(duration: 3.6).repeatForever(autoreverses: true)
        }
    }
}

// MARK: - Small shapes

private struct ClosedEye: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.midY))
        p.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.midY),
                       control: CGPoint(x: rect.midX, y: rect.maxY))
        return p
    }
}

private struct HappyEye: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY),
                       control: CGPoint(x: rect.midX, y: rect.minY))
        return p
    }
}

private struct ArmShape: Shape {
    var left: Bool
    func path(in rect: CGRect) -> Path {
        var p = Path()
        if left {
            p.move(to: CGPoint(x: rect.maxX, y: rect.minY))
            p.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY),
                           control: CGPoint(x: rect.minX, y: rect.minY))
        } else {
            p.move(to: CGPoint(x: rect.minX, y: rect.minY))
            p.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY),
                           control: CGPoint(x: rect.maxX, y: rect.minY))
        }
        return p
    }
}

private struct Leaf: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY),
                       control: CGPoint(x: rect.minX, y: rect.minY))
        p.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY),
                       control: CGPoint(x: rect.maxX, y: rect.maxY))
        return p
    }
}

private struct CapDome: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY),
                       control: CGPoint(x: rect.midX, y: rect.minY - rect.height * 0.4))
        p.closeSubpath()
        return p
    }
}

private struct StemShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        p.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY),
                       control: CGPoint(x: rect.maxX, y: rect.midY))
        return p
    }
}
