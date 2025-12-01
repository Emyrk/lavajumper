# Lava Jump Timer

A World of Warcraft (Vanilla 1.12) addon that helps you time lava jumps by displaying a countdown timer for the 2-second lava damage cycle.

## Features

- 🔥 **Visual Timer**: Progress bar showing time until next lava tick
- 📡 **Latency Compensation**: Automatically accounts for your ping/latency
- 🎨 **Color Coded**: Green (safe) → Orange (caution) → Red (danger)
- 🖱️ **Draggable**: Click and drag to reposition the timer anywhere on screen
- ⚡ **Auto-Sync**: Automatically syncs to lava damage when you take it
- ⚙️ **Configurable**: Adjust latency buffer for your playstyle

## How It Works

Lava damage in WoW occurs every 2 seconds. This addon detects when you take lava damage and displays a countdown timer showing exactly when the next tick will occur.

**Latency Compensation**: The timer automatically reads your current ping using `GetNetStats()` and adjusts the countdown to show when *you* need to act, not when the server will tick. By default, it uses a 1.5x safety buffer (so 100ms latency = 150ms adjustment).

This allows you to:
- Time your jumps to escape lava between ticks
- Account for your network latency automatically
- Minimize damage by knowing the safe window
- Navigate lava sections more efficiently

## Installation

1. Extract the `lava-jump-addon` folder to your WoW `Interface/AddOns/` directory
2. Rename the folder to `LavaJump` (if needed)
3. Restart WoW or reload UI (`/reload`)

## Usage

The timer will automatically appear when you take lava damage. It shows:
- **Time remaining** (adjusted for your latency)
- **Current ping** displayed below the timer
- **Green bar**: Safe time (1.0s+ remaining after latency adjustment)
- **Orange bar**: Caution (0.5-1.0s remaining)
- **Red bar**: Danger! Damage incoming (< 0.5s)
- **Dark red "ACT NOW!"**: Too late, you're in the danger zone!

### Commands

- `/lj` or `/lavajump` - Show help and current settings
- `/lj test` - Start a test timer (useful for positioning)
- `/lj reset` - Hide and reset the timer
- `/lj buffer <number>` - Set latency multiplier (0-5, default 1.5)
  - Example: `/lj buffer 2.0` for more safety margin
  - Example: `/lj buffer 1.0` for no buffer (1:1 latency adjustment)

### Positioning

Click and drag the timer frame to move it anywhere on your screen. The position will remain until you move it again.

## Tips for Lava Jumping

1. **Wait for Green**: Don't enter lava until you see the full 2-second window
2. **Quick Escapes**: You have ~1.5 seconds to get out safely after a tick
3. **Practice with `/lj test`**: Position the timer where you can see it easily
4. **Combine with Speed Buffs**: Use Sprint, Blink, or speed potions for safer crossing

## Compatibility

- World of Warcraft 1.12 (Vanilla)
- Works on all classes
- No dependencies required

## License

Free to use and modify
