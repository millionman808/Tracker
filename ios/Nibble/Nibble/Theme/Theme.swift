//
//  Theme.swift
//  Nibble — Sprout Snacks
//
//  Shared palette, helpers and small reusable view styles.
//

import SwiftUI

extension Color {
    init(hex: String) {
        var s = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        if s.count == 3 { s = s.map { "\($0)\($0)" }.joined() }
        var v: UInt64 = 0
        Scanner(string: s).scanHexInt64(&v)
        let r = Double((v & 0xFF0000) >> 16) / 255
        let g = Double((v & 0x00FF00) >> 8) / 255
        let b = Double(v & 0x0000FF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}

enum Theme {
    static let green   = Color(hex: "7BC47F")
    static let greenD  = Color(hex: "5FA86A")
    static let greenL  = Color(hex: "D6F5E3")
    static let ink     = Color(hex: "3A4A3F")
    static let inkSoft = Color(hex: "6B7D70")
    static let bg      = Color(hex: "F4FAF2")
    static let card    = Color.white
    static let drop    = Color(hex: "4AA3DF")
    static let gold    = Color(hex: "F4C542")
    static let danger  = Color(hex: "E0726B")
    static let proA    = Color(hex: "B07CF0")
    static let proB    = Color(hex: "7C5CF0")

    static let radius: CGFloat = 18
    static let radiusSm: CGFloat = 12

    static let cardShadow = Color.black.opacity(0.06)
}

// MARK: - Card container

struct Card<Content: View>: View {
    var padding: CGFloat = 16
    @ViewBuilder var content: () -> Content
    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity)
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: Theme.radius, style: .continuous))
            .shadow(color: Theme.cardShadow, radius: 8, x: 0, y: 3)
    }
}

// MARK: - Buttons

struct PrimaryButtonStyle: ButtonStyle {
    var big: Bool = false
    var enabled: Bool = true
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: big ? 17 : 15, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .padding(.vertical, big ? 15 : 11)
            .padding(.horizontal, big ? 18 : 18)
            .frame(maxWidth: big ? .infinity : nil)
            .background(
                Capsule().fill(enabled
                    ? AnyShapeStyle(LinearGradient(colors: [Theme.green, Theme.greenD],
                                                   startPoint: .top, endPoint: .bottom))
                    : AnyShapeStyle(Color(hex: "CDD8CF")))
            )
            .shadow(color: Theme.green.opacity(enabled ? 0.35 : 0), radius: 8, y: 4)
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct GhostButtonStyle: ButtonStyle {
    var big: Bool = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: big ? 17 : 15, weight: .bold, design: .rounded))
            .foregroundStyle(Theme.ink)
            .padding(.vertical, big ? 15 : 11)
            .padding(.horizontal, 18)
            .frame(maxWidth: big ? .infinity : nil)
            .background(Capsule().fill(Theme.card))
            .shadow(color: Theme.cardShadow, radius: 6, y: 2)
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct DangerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .padding(.vertical, 11)
            .padding(.horizontal, 18)
            .background(Capsule().fill(Theme.danger))
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct ProButtonStyle: ButtonStyle {
    var big: Bool = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: big ? 17 : 15, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .padding(.vertical, big ? 15 : 11)
            .padding(.horizontal, 18)
            .frame(maxWidth: big ? .infinity : nil)
            .background(Capsule().fill(LinearGradient(colors: [Theme.proA, Theme.proB],
                                                      startPoint: .topLeading, endPoint: .bottomTrailing)))
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Icon chip (SF Symbol on a tinted rounded square — the app's icon language)

struct IconChip: View {
    let symbol: String
    let tint: Color
    var size: CGFloat = 34
    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: size * 0.44, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(
                RoundedRectangle(cornerRadius: size * 0.3, style: .continuous)
                    .fill(tint.gradient)
            )
            .shadow(color: tint.opacity(0.35), radius: 3, y: 2)
    }
}

// MARK: - Section title

struct ScreenTitle: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 26, weight: .heavy, design: .rounded))
            .foregroundStyle(Theme.ink)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 2)
            .padding(.top, 4)
    }
}

// MARK: - Toast

struct ToastData: Equatable, Identifiable {
    let id = UUID()
    let message: String
}

struct ToastView: View {
    let message: String
    var body: some View {
        Text(message)
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .padding(.vertical, 11)
            .padding(.horizontal, 18)
            .background(Capsule().fill(Theme.ink))
            .shadow(color: .black.opacity(0.2), radius: 10, y: 4)
            .padding(.horizontal, 24)
    }
}
