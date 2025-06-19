### Documentation create by ChatGPT because I am lazy
---

# 🧩 uiDebugModule

A lightweight debug UI overlay for Roblox that displays live key-value pairs on the local player's screen. Perfect for tracking game state, debugging logic, or inspecting live systems during development.

---

## ✨ Features

* 🧠 **Key-Value Debug Overlay**: `key: value` display in top-left corner of screen
* 📁 **Nested Keys**: Automatically indents subkeys like `Audio.Master`
* 🎨 **Custom Styling**: Colours, fonts, sizes, and layout configurable via `:style()`
* ⏳ **Auto-Expire Entries**: Set TTLs for temporary debug lines
* 📌 **Headers**: Visually separate debug sections with `:header()`
* 🧽 **Clear Keys or Groups**: Remove one or many debug entries
* 🎥 **Animated Updates**: Optional value change flash animation
* ⏸️ **Pause & Resume Updates**: Freeze debug updates without removing data
* 📋 **Dump Current State**: Retrieve all keys and values with `:dump()`

---

## 📦 Installation

1. Copy the module into **ReplicatedStorage** (or another shared location).
2. Require it from a **LocalScript**.

```lua
local uiDebug = require(game.ReplicatedStorage:WaitForChild("uiDebugModule"))
```

---

## 🧪 Example Usage

```lua
-- Set basic debug info
uiDebug:set("PlayerState", "Idle")
uiDebug:set("Audio", true)
uiDebug:set("Audio.Master", 50)
uiDebug:set("Audio.Environment", 25)
uiDebug:set("Audio.Environment.Reverb", "Cave")

-- Expiring key (disappears after 3 seconds)
uiDebug:set("TemporaryStatus", "Loading assets...", {ttl = 3})

-- Add section header
uiDebug:header("=== Player Info ===")
uiDebug:set("Player.Health", 100)

-- Update style
uiDebug:style({
	TextColor3 = Color3.fromRGB(255, 255, 255),
	BackgroundColor3 = Color3.fromRGB(20, 20, 20),
	BackgroundTransparency = 0.1,
	TextSize = 16,
	PaddingLeft = 10,
	IndentSize = 20,
})

-- Clear a group of keys
uiDebug:clear("Audio") -- removes Audio and its children

-- Pause/resume debug updates
uiDebug:pause(true) -- freezes all :set() calls
uiDebug:pause(false)

-- Show/hide the entire UI
uiDebug:toggle() -- toggle current state
uiDebug:toggle(true) -- force show
uiDebug:toggle(false) -- force hide

-- Dump current values (returns key-text table)
print(uiDebug:dump())
```

---

## 🔧 API Reference

### `uiDebug:set(key: string, value: any, options?: { ttl: number })`

Creates or updates a debug entry. Use dot notation to indent subkeys.

### `uiDebug:header(text: string)`

Adds a bold header to the debug list for visual grouping.

### `uiDebug:style(config: table)`

Updates the visual style of all entries.

#### Supported Style Properties:

| Property                 | Type        | Description                              |
| ------------------------ | ----------- | ---------------------------------------- |
| `Font`                   | `Enum.Font` | Font type                                |
| `TextSize`               | `number`    | Size of text                             |
| `TextColor3`             | `Color3`    | Default text colour                      |
| `TextStrokeTransparency` | `number`    | Stroke transparency                      |
| `TextStrokeColor3`       | `Color3`    | Stroke colour                            |
| `BackgroundColor3`       | `Color3`    | Background colour                        |
| `BackgroundTransparency` | `number`    | Background transparency                  |
| `PaddingLeft`            | `number`    | Base horizontal padding in pixels        |
| `IndentSize`             | `number`    | Extra pixels of padding per indent level |
| `MaxWidth`               | `number`    | Width of the debug UI                    |
| `AnimateUpdates`         | `boolean`   | Flash on value changes                   |
| `Visible`                | `boolean`   | Initial visibility toggle                |
| `ColorByType`		   | `boolean`   | Toggles type-bsaed coloring of labels    |

### `uiDebug:clear(prefix?: string)`

Removes a specific key or all keys with a given prefix (e.g. `Audio` removes `Audio.Master`, etc).

### `uiDebug:toggle(state?: boolean)`

Toggles the visibility of the entire debug UI. If `state` is provided, forces on/off.

### `uiDebug:pause(state: boolean)`

Pauses or resumes all updates to the debug system.

### `uiDebug:dump(): { [string]: string }`

Returns a table of current keys and their display text.

---

## 📌 Tip

You can bind a key to toggle the UI during testing:

```lua
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.F10 then
		uiDebug:toggle()
	end
end)
```

---

## 📄 License

MIT License. Free to use and modify. Attribution appreciated but not required.

---
