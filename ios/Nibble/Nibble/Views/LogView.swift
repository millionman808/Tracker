//
//  LogView.swift
//  Nibble — Sprout Snacks
//
//  Quick manual entry plus one-tap re-logging from recents and favorites.
//

import SwiftUI

struct LogView: View {
    @Environment(AppStore.self) private var store
    @Environment(UIBus.self) private var bus

    @State private var name = ""
    @State private var calText = ""
    @State private var meal: Meal = Meal.suggested()
    @State private var servings = 1.0
    @State private var pText = ""
    @State private var cText = ""
    @State private var fText = ""
    @State private var listTab = 0   // 0 recents, 1 favorites
    @FocusState private var nameFocused: Bool

    private var list: [Food] { listTab == 0 ? store.state.recent : store.state.favorites }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ScreenTitle(text: "Log food")
                addForm
                tabPicker
                foodList
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 96)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    // MARK: Add form

    private var addForm: some View {
        Card {
            VStack(spacing: 12) {
                HStack(spacing: 10) {
                    TextField("Food name", text: $name)
                        .textFieldStyle(NibbleField())
                        .focused($nameFocused)
                    TextField("kcal", text: $calText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .textFieldStyle(NibbleField())
                        .frame(width: 90)
                }

                MealPicker(meal: $meal)

                HStack {
                    Text("Servings").font(.system(size: 14, weight: .semibold, design: .rounded)).foregroundStyle(Theme.inkSoft)
                    Spacer()
                    Stepper(value: $servings, in: 0.25...20, step: 0.25) {
                        Text(servings.formatted(.number.precision(.fractionLength(0...2))))
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .frame(minWidth: 40)
                    }
                    .fixedSize()
                }

                if store.state.settings.showMacros {
                    HStack(spacing: 8) {
                        macroField("Protein", $pText)
                        macroField("Carbs", $cText)
                        macroField("Fat", $fText)
                    }
                }

                Button("Log it 🌱") { submit() }
                    .buttonStyle(PrimaryButtonStyle(big: true))
            }
        }
    }

    private func macroField(_ label: String, _ text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.system(size: 11, weight: .semibold, design: .rounded)).foregroundStyle(Theme.inkSoft)
            TextField("g", text: text)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .textFieldStyle(NibbleField())
        }
    }

    // MARK: Tabs + list

    private var tabPicker: some View {
        HStack(spacing: 8) {
            SubTab(title: "Recent", active: listTab == 0) { listTab = 0 }
            SubTab(title: "Favorites ★", active: listTab == 1) { listTab = 1 }
            Spacer()
        }
    }

    private var foodList: some View {
        VStack(spacing: 8) {
            if list.isEmpty {
                Text(listTab == 1 ? "No favorites yet — tap ★ on any food." : "Nothing logged yet. Add something above!")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(Theme.inkSoft)
                    .padding(.vertical, 24)
            } else {
                ForEach(list) { food in
                    FoodRow(food: food,
                            isFav: store.isFavorite(food.name),
                            onLog: { quickLog(food) },
                            onFav: { _ = store.toggleFavorite(food) })
                }
            }
        }
    }

    // MARK: Actions

    private func submit() {
        let cal = Int(calText.trimmingCharacters(in: .whitespaces)) ?? -1
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty, cal >= 0 else {
            bus.say("Add a name and calories 🙂"); return
        }
        let s = servings
        let food = Food(name: trimmedName,
                        cal: Int((Double(cal) * s).rounded()),
                        p: Int(((Double(Int(pText) ?? 0)) * s).rounded()),
                        c: Int(((Double(Int(cText) ?? 0)) * s).rounded()),
                        f: Int(((Double(Int(fText) ?? 0)) * s).rounded()),
                        meal: meal)
        commit(food)
        name = ""; calText = ""; pText = ""; cText = ""; fText = ""; servings = 1
        nameFocused = false
    }

    private func quickLog(_ food: Food) { commit(food) }

    private func commit(_ food: Food) {
        let earned = store.addEntry(food)
        let word = GameData.kindWords.randomElement() ?? "Logged!"
        bus.say("\(word) +\(earned) 💧")
        bus.tab = .home   // bounce home so the Sprout's reaction is visible
    }
}

// MARK: - Meal picker

private struct MealPicker: View {
    @Binding var meal: Meal
    var body: some View {
        HStack(spacing: 8) {
            ForEach(Meal.allCases) { m in
                let selected = meal == m
                Button {
                    meal = m
                } label: {
                    Text("\(m.icon) \(m.label)")
                        .font(.system(size: 12.5, weight: .bold, design: .rounded))
                        .foregroundStyle(selected ? Theme.greenD : Theme.inkSoft)
                        .padding(.vertical, 8).padding(.horizontal, 10)
                        .background(Capsule().fill(selected ? Theme.greenL : Color(hex: "EEF6F0")))
                        .overlay(Capsule().stroke(selected ? Theme.green : .clear, lineWidth: 2))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Food row

private struct FoodRow: View {
    @Environment(AppStore.self) private var store
    let food: Food
    let isFav: Bool
    let onLog: () -> Void
    let onFav: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Button(action: onLog) {
                HStack(spacing: 12) {
                    Text(food.meal.icon).font(.system(size: 22))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(food.name).font(.system(size: 15, weight: .bold, design: .rounded)).foregroundStyle(Theme.ink)
                        Text(calLine).font(.system(size: 12, design: .rounded)).foregroundStyle(Theme.inkSoft)
                    }
                    Spacer()
                }
                .padding(.vertical, 12).padding(.leading, 14)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button(action: onFav) {
                Image(systemName: isFav ? "star.fill" : "star")
                    .font(.system(size: 18))
                    .foregroundStyle(isFav ? Theme.gold : Color(hex: "D6E0D8"))
                    .padding(14)
            }
            .buttonStyle(.plain)
        }
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSm, style: .continuous))
        .shadow(color: Theme.cardShadow, radius: 6, y: 2)
    }

    private var calLine: String {
        if store.state.settings.showMacros {
            return "\(food.cal) kcal · \(food.p)p \(food.c)c \(food.f)f"
        }
        return "\(food.cal) kcal"
    }
}

// MARK: - Shared small pieces

struct SubTab: View {
    let title: String
    let active: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13.5, weight: .bold, design: .rounded))
                .foregroundStyle(active ? .white : Theme.inkSoft)
                .padding(.vertical, 8).padding(.horizontal, 14)
                .background(Capsule().fill(active ? Theme.green : Color(hex: "EEF6F0")))
        }
        .buttonStyle(.plain)
    }
}

struct NibbleField: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.system(size: 16, design: .rounded))
            .padding(.vertical, 12).padding(.horizontal, 14)
            .background(RoundedRectangle(cornerRadius: Theme.radiusSm).fill(.white))
            .overlay(RoundedRectangle(cornerRadius: Theme.radiusSm).stroke(Color(hex: "E3EFE4"), lineWidth: 2))
    }
}
