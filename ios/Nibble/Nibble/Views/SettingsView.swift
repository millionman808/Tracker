//
//  SettingsView.swift
//  Nibble — Sprout Snacks
//
//  Goal (or goal-free) mode, water goal, macros & reminder toggles, backup /
//  transfer via export-import, privacy note, and reset.
//

import SwiftUI
import UIKit

struct SettingsView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var goalText = ""
    @State private var waterGoalText = ""
    @State private var showExport = false
    @State private var showImport = false
    @State private var importText = ""
    @State private var confirmReset = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    sproutCard
                    goalCard
                    prefsCard
                    backupCard
                    resetCard
                    Text("Nibble — Sprout Snacks · supportive calorie logging. No accounts, no ads, no shame.")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(Theme.inkSoft)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8).padding(.top, 4)
                }
                .padding(16)
            }
            .background(Theme.bg)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }.fontWeight(.bold)
                }
            }
            .onAppear {
                name = store.state.sproutName
                goalText = store.state.goal.map(String.init) ?? ""
                waterGoalText = String(store.state.water.goal)
            }
            .alert("Erase everything?", isPresented: $confirmReset) {
                Button("Cancel", role: .cancel) {}
                Button("Erase", role: .destructive) { store.resetAll(); dismiss() }
            } message: {
                Text("This permanently clears your Sprout, streak, Dewdrops and decorations on this device.")
            }
            .sheet(isPresented: $showExport) { exportSheet }
            .sheet(isPresented: $showImport) { importSheet }
        }
    }

    // MARK: Cards

    private var sproutCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 8) {
                Text("Your Sprout").font(.system(size: 15, weight: .bold, design: .rounded))
                TextField("Name", text: $name)
                    .textFieldStyle(NibbleField())
                    .onSubmit { store.setName(name) }
                    .onChange(of: name) { _, v in store.setName(v) }
            }
        }
    }

    private var goalCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 10) {
                Text("Daily goal").font(.system(size: 15, weight: .bold, design: .rounded))
                Text("Calorie goal (leave blank for goal-free mode)")
                    .font(.system(size: 12, design: .rounded)).foregroundStyle(Theme.inkSoft)
                TextField("e.g. 2000", text: $goalText)
                    .keyboardType(.numberPad)
                    .textFieldStyle(NibbleField())
                    .onChange(of: goalText) { _, v in
                        store.setGoal(v.isEmpty ? nil : Int(v))
                    }
                Text("Going over your goal never upsets your Sprout. Logging is the win. 🌱")
                    .font(.system(size: 12, design: .rounded)).foregroundStyle(Theme.inkSoft)

                Text("Daily water goal (cups)")
                    .font(.system(size: 12, design: .rounded)).foregroundStyle(Theme.inkSoft).padding(.top, 4)
                TextField("8", text: $waterGoalText)
                    .keyboardType(.numberPad)
                    .textFieldStyle(NibbleField())
                    .onChange(of: waterGoalText) { _, v in
                        if let n = Int(v), n >= 1 { store.setWaterGoal(n) }
                    }
            }
        }
    }

    private var prefsCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 6) {
                Text("Preferences").font(.system(size: 15, weight: .bold, design: .rounded))
                Toggle(isOn: Binding(
                    get: { store.state.settings.showMacros },
                    set: { store.setShowMacros($0) })) {
                        Text("Track macros (protein / carbs / fat)")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                    }
                    .tint(Theme.green)
                Toggle(isOn: Binding(
                    get: { store.state.settings.remindersOn },
                    set: { store.setReminders($0) })) {
                        Text("Meal reminders")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                    }
                    .tint(Theme.green)
            }
        }
    }

    private var backupCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 10) {
                Text("Backup & transfer").font(.system(size: 15, weight: .bold, design: .rounded))
                HStack(spacing: 10) {
                    Button("Export save") { showExport = true }.buttonStyle(GhostButtonStyle())
                    Button("Import save") { importText = ""; showImport = true }.buttonStyle(GhostButtonStyle())
                }
                Text("Your data is stored only on this device. Nothing is uploaded.")
                    .font(.system(size: 12, design: .rounded)).foregroundStyle(Theme.inkSoft)
            }
        }
    }

    private var resetCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 10) {
                Text("Reset").font(.system(size: 15, weight: .bold, design: .rounded))
                Button("Erase all progress") { confirmReset = true }
                    .buttonStyle(DangerButtonStyle())
            }
        }
    }

    // MARK: Export / import sheets

    private var exportSheet: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Text("Copy this and keep it safe:").font(.system(size: 14, design: .rounded)).foregroundStyle(Theme.inkSoft)
                ScrollView {
                    Text(store.exportSave())
                        .font(.system(size: 11, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 12).fill(.white))
                }
                Button("Copy to clipboard") {
                    UIPasteboard.general.string = store.exportSave()
                }
                .buttonStyle(PrimaryButtonStyle(big: true))
            }
            .padding(16)
            .background(Theme.bg)
            .navigationTitle("Export save")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { showExport = false } } }
        }
    }

    private var importSheet: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Text("Paste a previously exported save:").font(.system(size: 14, design: .rounded)).foregroundStyle(Theme.inkSoft)
                TextEditor(text: $importText)
                    .font(.system(size: 11, design: .monospaced))
                    .frame(height: 180)
                    .padding(6)
                    .background(RoundedRectangle(cornerRadius: 12).fill(.white))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "E3EFE4"), lineWidth: 2))
                Button("Load") {
                    if store.importSave(importText) { showImport = false; dismiss() }
                }
                .buttonStyle(PrimaryButtonStyle(big: true))
                Spacer()
            }
            .padding(16)
            .background(Theme.bg)
            .navigationTitle("Import save")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { showImport = false } } }
        }
    }
}
