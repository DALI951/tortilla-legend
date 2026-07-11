# Tortilla Legend

A taco stand management simulation game for Android, built with Godot 4.3.

## About

Run your own taco stand! Serve customers, manage your kitchen, upgrade your equipment, and become the Tortilla Legend.

## Gameplay

- **Timed days** (30 seconds to ~5 minutes) - serve as many customers as you can
- **Taco prep** - fill tortilla, grill meat, add toppings, assemble
- **Manual money collection** - tap to collect money from the counter
- **Upgrade shop** - improve your kitchen between days with 20+ upgrades
- **Customer orders** - match their exact ingredient requests for full payment
- **Thief events** - defend your earnings from a classic burglar
- **60-day campaign** + endless mode

## Features

- Portrait orientation (1080x1920) optimized for mobile
- English + Arabic (RTL) language support
- Auto-save system (JSON)
- Haptic feedback + screen shake
- No music - SFX and visual barks only

## Tech Stack

- **Engine:** Godot 4.3 (GDScript)
- **Target:** Android (APK)
- **Renderer:** GL Compatibility
- **CI/CD:** GitHub Actions - auto-builds APK on every commit via `barichello/godot-ci:4.3` Docker image
- **Export:** ETC2/ASTC texture compression, armeabi-v7a + arm64-v8a

## Project Structure

```
tortilla-legend/
  project.godot          - Godot project config
  export_presets.cfg     - Android export settings
  scenes/
    main_menu.tscn       - Title screen
    gameplay.tscn        - Core gameplay
    kitchen_shop.tscn    - Upgrade shop
    day_summary.tscn     - End-of-day report
    settings_scene.tscn  - Settings menu
  scripts/
    autoload/
      game_manager.gd    - Game state, day flow, money, upgrades
      save_manager.gd    - JSON save/load
      localization_manager.gd - EN/AR translations
      feedback_manager.gd     - Haptic + screen shake
    gameplay/
      gameplay_manager.gd     - Orchestrates gameplay loop
      customer_spawner.gd     - Spawns customers on timer
      customer.gd             - Customer orders + patience
      tortilla_station.gd     - Tortilla filling logic
      grill.gd                - Meat grilling with burn mechanic
      topping_station.gd      - Topping application
      assembly_station.gd     - Taco assembly
      sides_station.gd        - Chips, rice, guac
      drinks_station.gd       - Soda filling
      money_manager.gd        - Counter money tracking
      thief.gd                - Thief event logic
      helper.gd               - Sleeping chef helper
      event_manager.gd        - Special event system
      day_timer.gd            - Day countdown (legacy)
    ui/
      main_menu.gd       - Menu logic
      upgrade_shop.gd    - Upgrade shop display
      day_summary.gd     - Day summary display
      settings_ui.gd     - Settings controls
  data/
    upgrades.json        - 20+ upgrade definitions
    events.json          - Special event definitions
    recipes.json         - Taco recipe data
  assets/
    sprites/             - AI-generated game art
```

## Building

### CI/CD (Automatic)

Every push to `main`/`master` triggers GitHub Actions which:
1. Builds the APK using `barichello/godot-ci:4.3` Docker image
2. Uploads it to a GitHub Release with a timestamped tag

### Local Build

Requires Godot 4.3 with Android export templates installed.

```bash
godot --headless --export-debug "Android" build/tortilla-legend-debug.apk
```

## License

Personal project - not for commercial distribution.
