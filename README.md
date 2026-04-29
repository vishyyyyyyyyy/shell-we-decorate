# 🦀🫧 Shell We Decorate ⋆｡°✩🦀
A cozy shell decorating game, where you serve crabby customers and try your best to earn pearl paychecks.

<img width="1142" height="642" alt="Screenshot 2026-04-29 131036" src="https://github.com/user-attachments/assets/418c9337-ffb1-493b-b368-446cfb5e6b0a" />

## Gameplay 🐚𓇼 ˖°
Each in game day lasts 24 hours (compressed into 60 seconds).
Crabby customers visit your seaside stand hoping to decorate and purchase their perfect shell!

<img width="1146" height="644" alt="Screenshot 2026-04-29 131108" src="https://github.com/user-attachments/assets/d38d7d0d-1402-491e-8274-821986932fd1" />

You earn pearls based on how well you fulfill each order:
- Perfect order → +10 pearls ✧
- Second try → +5 pearls

Use your pearls to buy shop upgrades and unlock more customization options!

<img width="954" height="536" alt="Screenshot 2026-04-29 134315" src="https://github.com/user-attachments/assets/3fe7421d-023e-4ba1-8d7d-f24afa788ce5" />

Each order can include:
- Shell shape 🐚
- Shell Colors 🎨
- Starfish ⭐
- Barnacles 🪸
- Bows 🎀

Match everything correctly to earn pearls and keep your customers happy (˶˃ ᵕ ˂˶)

Survive 10 days underwater and prove your shell decorating skills!

## Achievements 🏆✧･ﾟ: *

<img width="1142" height="636" alt="Screenshot 2026-04-29 131300" src="https://github.com/user-attachments/assets/2c873161-8522-41f8-a598-1933f2b0dd3e" />

Unlock secret milestones that can give(or take away) more pearls!:
- Flawless Day: no mistakes all day (๑•̀ㅂ•́)و✧
- Combo Master: 10 perfect orders in a row
- Speedy Sheller: serve super fast
- Shell Legend: reach Day 10 
- Chaos Mode: ???

## Gameplay Mechanisms 🦀🎮
- Time & Day: 
  - A constant DAY_LENGTH := 60 seconds defines a full in-game day
  - Time is tracked using time_passed += delta
  - Hours are derived using: `var new_hour := int(time_passed / SECONDS_PER_HOUR)`
  - When current_hour >= 24, the day automatically ends via end_day()
    
- Crab Spawning:
  - Crab customers are spawned dynamically using: `func spawn_crab()` through and animation player
  - Each crab instance randomly selects a texture from crab_textures []
  - Special crabs are selected using weighted randomness: `var crab_event = [0,0,0,0,0,0,1]`
- Order Generation:
  - Crab orders are generated using a dictionary based on what the player has unlocked:
    - `var current_order = {"shape": "","color": "","stars": -1,"bow": -1,"barnacle": -1}`
  - Orders are randomly generated with weighted pools for customization options based on the day
- Earning Pearls
  - currency variables stored in the global script through: `daily_pearls, pearls_earned, shells_sold`
  - Each order has a base reward per correct order with increased payout for special events or extra decorations : `bonus += 2 * selected_stars, bonus += 3 * selected_barnacle, bonus += 5 if bow correct`
This creates a layered reward multiplier system.
- Streaks
  - A global streak counter tracks consecutive successful orders: `Global.streak += 1`
  - Resets on failure
- Achievements
  - A state based unlockable animation stored in a global dictionary: ex.`Global.achievements["flawless_day"]`
  - Each achievement contains:
    - name
    - description
    - reward
    - unlocked state
  - Triggered by gameplay conditions

## Planned Features + Future Improvements ٩(^ᗜ^ )و ´-
- More crab skins
- A LOT more animations

## Credits 💘

<img width="1148" height="642" alt="Screenshot 2026-04-29 131331" src="https://github.com/user-attachments/assets/3b288180-c6f9-41ef-90f6-480f28a40af5" />

- Game Development & Design: Vishalya Sairam
- Art & Visuals: Vishalya Sairam
- Music: “Cute Mood” - SoulProdMusic
- Font: Lalezar
- Made with love in Godot <3
