//
//  GameData.swift
//  Nibble — Sprout Snacks
//
//  Static content: starter foods, the shop catalog, milestones, reward tuning
//  and the rotating kind words shown after logging.
//

import Foundation

enum GameData {

    // MARK: Economy tuning
    enum Rewards {
        static let logMeal = 5
        static let waterCup = 1
        static let waterGoalBonus = 8
        static let streakDay = 3
        static let milestone = 50
    }

    static let waterGoalDefault = 8

    // MARK: Starter foods (seed the recents list on day one)
    static let starterFoods: [Food] = [
        Food(name: "Oatmeal with berries", cal: 290, p: 8,  c: 54, f: 5,  meal: .breakfast),
        Food(name: "Greek yogurt",         cal: 120, p: 17, c: 9,  f: 1,  meal: .breakfast),
        Food(name: "Scrambled eggs (2)",   cal: 180, p: 12, c: 2,  f: 13, meal: .breakfast),
        Food(name: "Banana",               cal: 105, p: 1,  c: 27, f: 0,  meal: .snack),
        Food(name: "Apple",                cal: 95,  p: 0,  c: 25, f: 0,  meal: .snack),
        Food(name: "Chicken salad",        cal: 350, p: 30, c: 12, f: 18, meal: .lunch),
        Food(name: "Turkey sandwich",      cal: 320, p: 22, c: 38, f: 9,  meal: .lunch),
        Food(name: "Veggie stir-fry",      cal: 400, p: 14, c: 52, f: 15, meal: .dinner),
        Food(name: "Salmon & rice",        cal: 520, p: 34, c: 45, f: 22, meal: .dinner),
        Food(name: "Mixed nuts (handful)", cal: 170, p: 6,  c: 6,  f: 15, meal: .snack),
        Food(name: "Latte",                cal: 130, p: 8,  c: 13, f: 5,  meal: .snack),
        Food(name: "Dark chocolate (2 sq)",cal: 110, p: 1,  c: 11, f: 8,  meal: .snack)
    ]

    // MARK: Shop catalog
    static let shop: [ShopItem] = [
        // Sprout skins
        ShopItem(id: "skin_sprout",    type: .skin, name: "Classic Sprout",  price: 0,   theme: "skins", desc: "The original little sprout.", emoji: "🌱"),
        ShopItem(id: "skin_cactus",    type: .skin, name: "Cactus Sprout",   price: 120, theme: "skins", desc: "Prickly but lovable.",        emoji: "🌵"),
        ShopItem(id: "skin_mushroom",  type: .skin, name: "Mushroom Sprout", price: 150, theme: "skins", desc: "A cosy little fungi friend.",  emoji: "🍄"),
        ShopItem(id: "skin_sunflower", type: .skin, name: "Sunflower Sprout",price: 200, theme: "skins", desc: "Always facing the light.",     emoji: "🌻"),
        ShopItem(id: "skin_cherry",    type: .skin, name: "Cherry Sprout",   price: 350, theme: "skins", desc: "Sweet and round.",            emoji: "🍒", pro: true),

        // Wallpapers
        ShopItem(id: "wall_mint",     type: .wallpaper, name: "Mint Walls",     price: 60,  theme: "walls", desc: "Fresh and calm.",   colorHex: "D6F5E3"),
        ShopItem(id: "wall_peach",    type: .wallpaper, name: "Peach Walls",    price: 60,  theme: "walls", desc: "Warm and soft.",    colorHex: "FFE3D3"),
        ShopItem(id: "wall_sky",      type: .wallpaper, name: "Sky Walls",      price: 90,  theme: "walls", desc: "Open and breezy.",  colorHex: "DCEEFF"),
        ShopItem(id: "wall_lavender", type: .wallpaper, name: "Lavender Walls", price: 120, theme: "walls", desc: "Dreamy dusk tones.", colorHex: "ECE1FF", pro: true),

        // Kitchen
        ShopItem(id: "kit_stove",  type: .decor, name: "Tiny Stove",     price: 80,  theme: "kitchen", desc: "For imaginary soup.",  emoji: "🍲", slot: .floorLeft),
        ShopItem(id: "kit_fridge", type: .decor, name: "Mini Fridge",    price: 110, theme: "kitchen", desc: "Stocked with snacks.", emoji: "🧊", slot: .floorRight),
        ShopItem(id: "kit_kettle", type: .decor, name: "Whistle Kettle", price: 70,  theme: "kitchen", desc: "Always a brew on.",    emoji: "🫖", slot: .shelf),

        // Garden
        ShopItem(id: "gar_planter", type: .decor, name: "Window Planter", price: 90,  theme: "garden", desc: "A row of herbs.",  emoji: "🪴", slot: .shelf),
        ShopItem(id: "gar_tree",    type: .decor, name: "Potted Tree",    price: 160, theme: "garden", desc: "Shade for naps.",  emoji: "🌳", slot: .floorLeft),
        ShopItem(id: "gar_flowers", type: .decor, name: "Flower Bunch",   price: 75,  theme: "garden", desc: "Fresh cut blooms.", emoji: "💐", slot: .floorRight),

        // Cozy nook
        ShopItem(id: "coz_lamp",  type: .decor, name: "Warm Lamp",  price: 85,  theme: "cozy", desc: "Soft evening glow.", emoji: "💡", slot: .floorRight),
        ShopItem(id: "coz_rug",   type: .decor, name: "Round Rug",  price: 100, theme: "cozy", desc: "Toes love it.",      emoji: "🟫", slot: .rug),
        ShopItem(id: "coz_books", type: .decor, name: "Book Stack", price: 95,  theme: "cozy", desc: "Bedtime stories.",   emoji: "📚", slot: .floorLeft),
        ShopItem(id: "coz_frame", type: .decor, name: "Art Frame",  price: 130, theme: "cozy", desc: "A little masterpiece.", emoji: "🖼️", pro: true, slot: .shelf)
    ]

    static let shopThemes: [ShopTheme] = [
        ShopTheme(id: "skins",   label: "Sprout Skins"),
        ShopTheme(id: "walls",   label: "Walls"),
        ShopTheme(id: "kitchen", label: "Kitchen"),
        ShopTheme(id: "garden",  label: "Garden"),
        ShopTheme(id: "cozy",    label: "Cozy Nook")
    ]

    static func item(_ id: String) -> ShopItem? { shop.first { $0.id == id } }

    // MARK: Milestones / badges
    static let milestones: [Milestone] = [
        Milestone(id: "first_log", label: "First Bite", icon: "🌱",
                  desc: "Logged your very first meal.",
                  check: { $0.stats.totalFoodsLogged >= 1 }),
        Milestone(id: "week_streak", label: "Seven Sprouts", icon: "🔥",
                  desc: "Logged 7 days in a row.",
                  check: { $0.streak.best >= 7 }),
        Milestone(id: "month_streak", label: "Steady Gardener", icon: "🏆",
                  desc: "Logged 30 days in a row.",
                  check: { $0.streak.best >= 30 }),
        Milestone(id: "hundred", label: "Century Snacks", icon: "💯",
                  desc: "Logged 100 foods total.",
                  check: { $0.stats.totalFoodsLogged >= 100 }),
        Milestone(id: "water_day", label: "Well Watered", icon: "💧",
                  desc: "Hit your water goal in a day.",
                  check: { $0.stats.waterGoalsHit >= 1 }),
        Milestone(id: "explorer", label: "Curious Palate", icon: "🧭",
                  desc: "Tried 15 different foods.",
                  check: { $0.stats.uniqueFoods.count >= 15 }),
        Milestone(id: "decorator", label: "Home Maker", icon: "🛋️",
                  desc: "Bought your first decoration.",
                  check: { state in
                      state.owned.contains { id in item(id)?.type == .decor }
                  })
    ]

    // MARK: Kind words (never about eating less)
    static let kindWords = [
        "Nice — your Sprout did a happy wiggle.",
        "Logged! Taking care of yourself counts.",
        "Your Sprout nibbled along with you. 🌱",
        "Every log is a little act of self-care.",
        "Sprout is content. So are we.",
        "That's the habit growing stronger.",
        "Well done showing up today."
    ]
}
