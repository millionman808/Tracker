//
//  SproutView.swift
//  Nibble — Sprout Snacks
//
//  The companion, drawn entirely with SwiftUI shapes and animated procedurally
//  via TimelineView — every limb follows smooth sine motion, so the Sprout
//  always feels alive. Moods: neutral, happy, eating, sleepy, celebrating.
//
//  By design there is NO sad state — the Sprout is never distressed by eating.
//

import SwiftUI

// MARK: - Skin palette

struct SproutSkin {
    let body: Color
    let bodyDark: Color
    let cheek: Color
    let topper: Topper

    enum Topper { case leaf, flower, cap, petals, stem }

    static func forID(_ id: String) -> SproutSkin {
        switch id {
        case "skin_cactus":
            return SproutSkin(body: Color(hex: "5FA86A"), bodyDark: Color(hex: "4E8F58"),
                              cheek: Color(hex: "F0B3A0"), topper: .flower)
        case "skin_mushroom":
            return SproutSkin(body: Color(hex: "E8D9C5"), bodyDark: Color(hex: "D4C3AB"),
                              cheek: Color(hex: "F4A6B8"), topper: .cap)
        case "skin_sunflower":
            return SproutSkin(body: Color(hex: "F4C542"), bodyDark: Color(hex: "DFAF2E"),
                              cheek: Color(hex: "E89B6C"), topper: .petals)
        case "skin_cherry":
            return SproutSkin(body: Color(hex: "E06377"), bodyDark: Color(hex: "C95065"),
                              cheek: Color(hex: "FFD1DC"), topper: .stem)
        default:
            return SproutSkin(body: Color(hex: "7BC47F"), bodyDark: Color(hex: "69B06E"),
                              cheek: Color(hex: "F4A6B8"), topper: .leaf)
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

// MARK: - Per-mood motion parameters

private struct Motion {
    var armRest: Double      // arm angle at rest, degrees (positive = down)
    var armWave: Double      // wave amplitude, degrees
    var armSpeed: Double     // wave frequency
    var armPhaseGap: Double  // phase offset between arms (radians)
    var breatheAmp: Double   // body squash amplitude
    var breatheSpeed: Double
    var rockAmp: Double      // body rocking, degrees
    var rockSpeed: Double
    var hop: Bool            // celebratory hop

    static func forMood(_ mood: Mood) -> Motion {
        switch mood {
        case .neutral:
            return Motion(armRest: 38, armWave: 6, armSpeed: 1.6, armPhaseGap: 0.9,
                          breatheAmp: 0.022, breatheSpeed: 1.7, rockAmp: 0, rockSpeed: 1, hop: false)
        case .happy:
            return Motion(armRest: 14, armWave: 16, armSpeed: 3.2, armPhaseGap: 1.2,
                          breatheAmp: 0.03, breatheSpeed: 2.2, rockAmp: 2.6, rockSpeed: 2.2, hop: false)
        case .eating:
            return Motion(armRest: 28, armWave: 8, armSpeed: 2.4, armPhaseGap: 0.7,
                          breatheAmp: 0.025, breatheSpeed: 2.0, rockAmp: 0, rockSpeed: 1, hop: false)
        case .sleepy:
            return Motion(armRest: 58, armWave: 2, armSpeed: 0.7, armPhaseGap: 0.4,
                          breatheAmp: 0.035, breatheSpeed: 0.9, rockAmp: 0, rockSpeed: 1, hop: false)
        case .celebrating:
            return Motion(armRest: -52, armWave: 24, armSpeed: 6.0, armPhaseGap: .pi,
                          breatheAmp: 0.02, breatheSpeed: 2.0, rockAmp: 3, rockSpeed: 4, hop: true)
        }
    }
}

// MARK: - SproutView

struct SproutView: View {
    let skinID: String
    let mood: Mood
    var size: CGFloat = 170
    var animated: Bool = true

    private var skin: SproutSkin { SproutSkin.forID(skinID) }
    private let design = CGSize(width: 200, height: 230)

    var body: some View {
        Group {
            if animated {
                TimelineView(.animation) { timeline in
                    let t = timeline.date.timeIntervalSinceReferenceDate
                    scene(t: t)
                }
            } else {
                scene(t: 0)
            }
        }
        .frame(width: size, height: size * (design.height / design.width))
    }

    // MARK: Scene composed from time t

    private func scene(t: Double) -> some View {
        let m = Motion.forMood(mood)
        let hop: CGFloat = m.hop ? CGFloat(-10 * abs(sin(t * 4.0))) : 0
        let breathe: CGFloat = CGFloat(1.0 + m.breatheAmp * sin(t * m.breatheSpeed))
        let rock: Double = m.rockAmp * sin(t * m.rockSpeed)

        return ZStack {
            // ground shadow (shrinks slightly when hopping)
            Ellipse()
                .fill(Color.black.opacity(0.12))
                .frame(width: 110 + hop * 1.4, height: 22)
                .position(x: 100, y: 214)

            // topper sways gently
            topper
                .rotationEffect(.degrees(4 * sin(t * 0.9)), anchor: .bottom)
                .position(x: 100, y: 44)
                .offset(y: hop)

            bodyGroup(t: t, motion: m)
                .scaleEffect(x: 1, y: breathe, anchor: .bottom)
                .rotationEffect(.degrees(rock), anchor: .bottom)
                .offset(y: hop)

            moodExtras(t: t)
        }
        .frame(width: design.width, height: design.height)
        .scaleEffect(size / design.width)
        .frame(width: size, height: size * (design.height / design.width))
    }

    // MARK: Body, face, limbs

    private func bodyGroup(t: Double, motion m: Motion) -> some View {
        ZStack {
            // feet peeking out
            Ellipse().fill(skin.bodyDark).frame(width: 26, height: 13).position(x: 78, y: 196)
            Ellipse().fill(skin.bodyDark).frame(width: 26, height: 13).position(x: 122, y: 196)

            // arms behind the body silhouette edge
            arm(t: t, motion: m, left: true)
            arm(t: t, motion: m, left: false)

            SproutBody().fill(skin.body)
            SproutBody().fill(Color.white.opacity(0.14)).scaleEffect(0.78)

            // cheeks
            Circle().fill(skin.cheek).opacity(0.8).frame(width: 20).position(x: 68, y: 132)
            Circle().fill(skin.cheek).opacity(0.8).frame(width: 20).position(x: 132, y: 132)

            face(t: t)
        }
    }

    /// One arm: a rounded limb with a little paw, swinging from the shoulder.
    private func arm(t: Double, motion m: Motion, left: Bool) -> some View {
        let phase = left ? m.armPhaseGap : 0
        let wave = m.armWave * sin(t * m.armSpeed + phase)
        let angle = m.armRest + wave
        // For the right arm, positive angle = swings down (clockwise).
        // The left arm mirrors it (counter-clockwise).
        let rotation = left ? -angle : angle

        return ZStack(alignment: left ? .leading : .trailing) {
            Capsule().fill(skin.body).frame(width: 42, height: 15)
            Circle().fill(skin.bodyDark).frame(width: 12, height: 12)
                .padding(left ? .leading : .trailing, 2)
        }
        .frame(width: 42, height: 15)
        .rotationEffect(.degrees(rotation), anchor: left ? .trailing : .leading)
        .position(x: left ? 32 : 168, y: 140)
    }

    @ViewBuilder private func face(t: Double) -> some View {
        let ink = Color(hex: "3A3A3A")
        // natural blink every few seconds (open-eye moods only)
        let blinking = (mood == .neutral || mood == .happy || mood == .eating)
            && t.truncatingRemainder(dividingBy: 3.8) < 0.13

        switch mood {
        case .sleepy:
            closedEyes(ink)
            Circle().fill(ink).frame(width: 7).position(x: 100, y: 136)
        case .happy:
            if blinking { closedEyes(ink) } else {
                HappyEye().stroke(ink, style: .init(lineWidth: 6, lineCap: .round)).frame(width: 20, height: 10).position(x: 84, y: 110)
                HappyEye().stroke(ink, style: .init(lineWidth: 6, lineCap: .round)).frame(width: 20, height: 10).position(x: 116, y: 110)
            }
            Smile().stroke(ink, style: .init(lineWidth: 5, lineCap: .round)).frame(width: 34, height: 16).position(x: 100, y: 130)
        case .eating:
            if blinking { closedEyes(ink) } else { dotEyes(ink) }
            // mouth chews
            Ellipse().fill(Color(hex: "7A3B3B"))
                .frame(width: 24, height: 14 + CGFloat(6 * abs(sin(t * 6))))
                .position(x: 100, y: 134)
        case .celebrating:
            HappyEye().stroke(ink, style: .init(lineWidth: 6, lineCap: .round)).frame(width: 20, height: 12).position(x: 84, y: 110)
            HappyEye().stroke(ink, style: .init(lineWidth: 6, lineCap: .round)).frame(width: 20, height: 12).position(x: 116, y: 110)
            Smile(open: true).fill(Color(hex: "7A3B3B")).frame(width: 36, height: 22).position(x: 100, y: 126)
        case .neutral:
            if blinking { closedEyes(ink) } else { dotEyes(ink) }
            Smile().stroke(ink, style: .init(lineWidth: 5, lineCap: .round)).frame(width: 24, height: 10).position(x: 100, y: 130)
        }
    }

    private func dotEyes(_ ink: Color) -> some View {
        Group {
            Circle().fill(ink).frame(width: 7).position(x: 84, y: 108)
            Circle().fill(ink).frame(width: 7).position(x: 116, y: 108)
        }
    }

    private func closedEyes(_ ink: Color) -> some View {
        Group {
            ClosedEye().stroke(ink, style: .init(lineWidth: 5, lineCap: .round)).frame(width: 20, height: 10).position(x: 84, y: 112)
            ClosedEye().stroke(ink, style: .init(lineWidth: 5, lineCap: .round)).frame(width: 20, height: 10).position(x: 116, y: 112)
        }
    }

    // MARK: Mood extras (drawn over everything)

    @ViewBuilder private func moodExtras(t: Double) -> some View {
        switch mood {
        case .sleepy:
            let drift = t.truncatingRemainder(dividingBy: 2.6) / 2.6
            Text("z").font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: "9AAAAA"))
                .opacity(1 - drift)
                .position(x: 148 + CGFloat(drift * 8), y: 76 - CGFloat(drift * 22))
            let drift2 = (t + 1.3).truncatingRemainder(dividingBy: 2.6) / 2.6
            Text("z").font(.system(size: 21, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: "9AAAAA"))
                .opacity(1 - drift2)
                .position(x: 158 + CGFloat(drift2 * 10), y: 64 - CGFloat(drift2 * 26))
        case .celebrating:
            sparkle("✨", x: 38, y: 58, t: t, phase: 0)
            sparkle("⭐️", x: 100, y: 34, t: t, phase: 1.1)
            sparkle("✨", x: 162, y: 66, t: t, phase: 2.2)
        case .eating:
            // a leaf snack bobbing toward the mouth
            Text("🍃").font(.system(size: 18))
                .rotationEffect(.degrees(-14 * sin(t * 5)))
                .position(x: 126 - CGFloat(5 * abs(sin(t * 5))), y: 124)
        default:
            EmptyView()
        }
    }

    private func sparkle(_ s: String, x: CGFloat, y: CGFloat, t: Double, phase: Double) -> some View {
        let pulse = abs(sin(t * 3 + phase))
        return Text(s).font(.system(size: 17))
            .opacity(0.25 + 0.75 * pulse)
            .scaleEffect(0.7 + 0.4 * pulse)
            .position(x: x, y: y)
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
}

// MARK: - Shapes (200×230 design space)

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
