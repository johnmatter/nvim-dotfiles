# Base16 Colorscheme Management System

## Overview

This is a sophisticated cross-application theme synchronization system that maintains a single source of truth for the Base16 colorscheme and applies it consistently across Neovim, Kitty terminal, and Fish shell. The system uses lazy loading, live preview, and async operations for a seamless user experience.

### Design Principles

1. **Single Source of Truth**: One file (`~/.config/.theme`) stores the current theme name
2. **Synchronized Application**: Changes propagate to all three applications (Neovim, Kitty, Fish)
3. **Automatic Variant Selection**: Prefers 256-color variants when available
4. **Live Preview**: Interactive theme picker with real-time preview as you navigate
5. **Graceful Degradation**: Non-blocking operations with proper error handling

---

## Architecture

### File Structure

```
~/.config/nvim/
├── init.lua                          # Theme initialization & custom highlights
├── lua/
│   ├── base16-theme-sync.lua        # Core theme synchronization module
│   └── plugins/
│       ├── base16.lua               # Base16 colorscheme plugin config
│       └── telescope.lua            # Interactive theme picker
└── .config/
    ├── .theme                        # Single source of truth (theme name)
    ├── kitty/
    │   └── theme.conf               # Generated Kitty theme config
    ├── base16-kitty/
    │   └── colors/
    │       └── base16-*.conf        # 466 theme files (233 themes)
    └── base16-shell/
        └── scripts/
            └── base16-*.sh          # Shell scripts for terminal colors
```

### Data Flow

```
┌─────────────────────────────────────────────────┐
│          Single Source of Truth                 │
│          ~/.config/.theme                       │
└─────────────┬───────────────────────────────────┘
              │
              │ read on startup / write on change
              │
┌─────────────▼───────────────────────────────────┐
│       base16-theme-sync.lua (Core Module)       │
│  • get_available_themes()                       │
│  • get_current_theme()                          │
│  • set_theme(name)                              │
│  • initialize_theme()                           │
└─────┬──────────────┬──────────────┬─────────────┘
      │              │              │
      ▼              ▼              ▼
┌─────────┐    ┌─────────┐    ┌─────────┐
│ Neovim  │    │  Kitty  │    │  Fish   │
│ vim.cmd │    │ remote  │    │  bash   │
└─────────┘    └─────────┘    └─────────┘
```

---

## Core Module: `lua/base16-theme-sync.lua`

### Module State

```lua
M.theme_file = vim.fn.expand(vim.env.HOME .. '/.config/.theme')
```

The module maintains a single state variable pointing to the source of truth file.

### Functions

#### `M.get_available_themes()` (Lines 8-43)

**Purpose**: Discovers all available Base16 themes from Kitty theme directory

**Algorithm**:
1. Scans `~/.config/base16-kitty/colors/` for `base16-*.conf` files
2. Uses pattern matching to extract theme names:
   - Regular themes: `base16-(.-)%.conf$` (line 19)
   - 256 variants: `base16-(.-)%-256%.conf$` (line 25)
3. Tracks both regular and 256 variants in `theme_variants` table
4. **Smart filtering** (lines 32-37): Only includes regular themes, or 256-only themes if no regular version exists
5. Returns alphabetically sorted list

**Returns**: Array of theme name strings (without "base16-" prefix)

**Example**:
```lua
local themes = require('base16-theme-sync').get_available_themes()
-- Returns: { "3024", "apathy", "atlas", ..., "zenburn" }
```

#### `M.get_current_theme()` (Lines 46-54)

**Purpose**: Reads current theme from source of truth file

**Logic**:
1. Checks if `~/.config/.theme` is readable (line 47)
2. Reads first line and trims whitespace (line 50)
3. Returns "gruvbox-dark-hard" as default if file missing/empty (line 53)

**Returns**: Theme name string

**Example**:
```lua
local current = require('base16-theme-sync').get_current_theme()
-- Returns: "gruvbox-material-dark-hard"
```

#### `M.set_theme(theme_name)` (Lines 57-132)

**Purpose**: Core function that applies theme across all applications

**Flow**:

**Phase 1: Validation (Lines 58-73)**
1. Constructs paths for both regular and 256 variants
2. **Prefers 256-color variant** if it exists (lines 62-66)
3. Validates theme file exists, shows error notification if not

```lua
-- Preference order:
-- 1. base16-<theme>-256.conf
-- 2. base16-<theme>.conf
```

**Phase 2: Neovim Application (Lines 75-81)**
1. Strips `-256` suffix since nvim only has regular variants (line 77)
2. Constructs colorscheme name: `"base16-" .. nvim_theme_name`
3. Uses `pcall` for safe colorscheme application (line 79)

**Phase 3: Persistence (Lines 84-85)**
- Only writes to source of truth file if Neovim application succeeded
- Ensures consistency across restarts

**Phase 4: Kitty Application (Lines 87-118)**
1. Reads selected theme file content
2. Writes to `~/.config/kitty/theme.conf` (line 92)
3. **Async application via remote control** (lines 97-113):
   - Uses `vim.loop.spawn` for non-blocking execution
   - Executes: `kitty @ set-colors --all <theme_path>`
   - Scheduled notifications to avoid fast event context issues (line 106)
   - Success notification only shown if remote control succeeds (code == 0)

**Phase 5: Shell Application (Lines 125-131)**
1. Checks for shell script: `~/.config/base16-shell/scripts/base16-<theme>.sh`
2. **Async execution** via `vim.loop.spawn('bash', ...)`
3. No error handling (silent failure if script missing)
4. Script sets terminal colors via ANSI escape sequences

**Example**:
```lua
require('base16-theme-sync').set_theme('nord')
-- Applies nord theme to Neovim, Kitty, and Fish
```

#### `M.initialize_theme()` (Lines 134-141)

**Purpose**: Loads persisted theme on Neovim startup

**Implementation**:
- **Scheduled execution** (line 137): Avoids fast event context issues
- Calls `get_current_theme()` then `set_theme()`

**Called from**: `init.lua` line 63

#### `M.create_theme_preview(theme_name)` (Lines 143-179)

**Purpose**: Generates preview content for Telescope picker

**Returns**: Markdown-formatted array with:
- Theme name header
- Benefits description
- Lua and Python syntax highlighting examples
- Current theme display

**Note**: Currently unused in Telescope implementation (no previewer enabled)

---

## Initialization: `init.lua`

### Custom Highlight Configuration (Lines 27-59)

#### Global Highlight Variables (Lines 28-31)

```lua
_G.custom_cursorline_color = "#18573e"
_G.custom_cursorline_fg = "#cac0ae"
_G.custom_visual_fg = "#cac0ae"
_G.custom_visual_bg = "#4c7842"
```

These global variables persist across colorscheme changes and are used by the autocmd.

#### Initial Application (Lines 33-44)

- Sets `CursorLine` and `Visual` highlight groups
- Disables LSP semantic token highlighting for C++ comments

#### Persistence Mechanism (Lines 46-59)

**The Challenge**: Custom highlights are lost when colorscheme changes

**The Solution**: ColorScheme autocmd that reapplies highlights

```lua
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.api.nvim_set_hl(0, "CursorLine", {
      fg = _G.custom_cursorline_fg,
      bg = _G.custom_cursorline_color
    })
    -- ... other highlights
  end,
})
```

This ensures custom colors persist after every theme switch.

### Theme System Integration (Lines 61-76)

#### Module Loading (Lines 62-63)

```lua
local theme_sync = require('base16-theme-sync')
theme_sync.initialize_theme()
```

Loads theme sync module and immediately initializes theme from persisted state.

#### Manual Theme Command (Lines 68-76)

```vim
:SetTheme <theme-name>
```

**Features**:
- Custom user command for CLI theme switching
- **Tab completion** (lines 72-74): Uses `theme_sync.get_available_themes()`
- Directly calls `theme_sync.set_theme()`

**Example**:
```vim
:SetTheme gruvbox-dark-hard
:SetTheme nord
```

---

## Telescope Integration: `lua/plugins/telescope.lua`

### Interactive Theme Picker (Lines 124-201)

#### Function: `theme_picker()` (Lines 125-198)

**Keymap**: `<leader>th`

#### UI Configuration (Lines 134-137)

- Uses dropdown theme with `winblend = 10` (slight transparency)
- No previewer enabled (could be enhanced with `create_theme_preview()`)

#### Picker Setup (Lines 145-197)

**Finder Configuration** (Lines 147-156):
```lua
finders.new_table({
  results = theme_sync.get_available_themes(),
  entry_maker = function(entry)
    return {
      value = entry,
      display = entry,
      ordinal = entry,
    }
  end,
})
```

**Selection Handler** (Lines 158-165):
```lua
actions.select_default:replace(function(prompt_bufnr)
  local selection = action_state.get_selected_entry()
  actions.close(prompt_bufnr)
  theme_sync.set_theme(selection.value)
end)
```

Overrides Enter key to apply selected theme and close picker.

#### Live Preview Implementation (Lines 167-193)

**Key Innovation**: Themes preview as you navigate

**Helper Function** `preview_theme()` (lines 168-173):
```lua
local function preview_theme()
  local entry = action_state.get_selected_entry()
  if entry then
    theme_sync.set_theme(entry.value)
  end
end
```

Gets currently highlighted entry and immediately applies theme for live preview.

**Mapped Keys with Preview**:
- `<C-p>` / `<C-n>`: Move up/down with preview (lines 175-183)
- `<Up>` / `<Down>`: Arrow keys with preview (lines 185-193)

**Navigation Flow**:
1. Move selection (e.g., `actions.move_selection_next`)
2. Call `preview_theme()` to immediately apply
3. User sees theme change in real-time

**User Experience**:
```
Open picker with <leader>th
  ↓
Press <C-n> to move down
  ↓
Theme instantly changes (live preview)
  ↓
Continue browsing
  ↓
Press <Enter> to confirm, or <Esc> to keep last previewed
```

---

## Base16 Plugin: `lua/plugins/base16.lua`

**Plugin**: `RRethy/nvim-base16`

**Configuration**:
```lua
return {
  "RRethy/nvim-base16",
  lazy = false,    -- Loads immediately on startup
  priority = 1000, -- Loads before other plugins
  config = function()
    -- Minimal config: plugin just needs to be available
    -- Actual colorscheme application handled by theme-sync module
  end,
}
```

The plugin provides the colorscheme definitions, but doesn't apply them directly. Theme synchronization is handled by `base16-theme-sync.lua`.

---

## External Dependencies

### Base16-Kitty: `~/.config/base16-kitty/colors/`

**File Pattern**:
- Regular: `base16-<theme-name>.conf`
- 256 variant: `base16-<theme-name>-256.conf`

**Example**: `base16-gruvbox-material-dark-hard.conf`
```conf
background #202020
foreground #ddc7a1
selection_background #ddc7a1
selection_foreground #202020
color0  #202020
color1  #ea6962
color2  #a9b665
color3  #d8a657
color4  #7daea3
color5  #d3869b
color6  #89b482
color7  #ddc7a1
color8  #5a524c
color9  #ea6962
color10 #a9b665
color11 #d8a657
color12 #7daea3
color13 #d3869b
color14 #89b482
color15 #ddc7a1
```

**Discovery**:
- Scanned by `get_available_themes()` using `globpath()`
- Current count: 466 theme files (233 themes, many with 256 variants)

**Application**:
- Content copied to `~/.config/kitty/theme.conf`
- Applied live via `kitty @ set-colors --all <path>`

### Base16-Shell: `~/.config/base16-shell/scripts/`

**File Pattern**: `base16-<theme-name>.sh`

**Script Structure** (example from base16-3024.sh):
```bash
#!/bin/sh
export BASE16_THEME=3024

# Define 21 colors (base16 palette)
color00="09/03/00"  # Base 00 - Black
color01="db/2d/20"  # Base 08 - Red
color02="01/a2/52"  # Base 0B - Green
# ... (color03-color21)

# Apply colors via ANSI escape sequences
put_template 0 $color00
put_template 1 $color01
# ... (2-15)

# Special handling for tmux, screen, iTerm2, etc.
```

**Purpose**: Sets terminal colors for Fish shell and other terminal applications

**Application**: Executed via `vim.loop.spawn('bash', { args = { script } })`

**Note**: Theme name mismatch handling
- Kitty theme exists but shell script may not (e.g., "gruvbox-material-dark-hard")
- System gracefully handles missing scripts (silent failure)

### Source of Truth: `~/.config/.theme`

**Current Contents**: Single line with theme name (e.g., `gruvbox-material-dark-hard`)

**Role**:
- Single file storing active theme name
- Read on startup by `initialize_theme()`
- Written only after successful Neovim colorscheme application
- Ensures theme persists across Neovim restarts
- **Not version controlled** (personal preference file)

---

## Theme Application Flow

### Complete Flow Diagram

```
User Action: <leader>th or :SetTheme <name>
    │
    ▼
┌─────────────────────────────────────────────┐
│ 1. Validate Theme                           │
│    • Check both regular and 256 variants    │
│    • Prefer 256 variant if exists           │
│    • Return error if neither exists         │
└──────────────────┬──────────────────────────┘
                   ▼
┌─────────────────────────────────────────────┐
│ 2. Apply to Neovim                          │
│    • Strip -256 suffix                      │
│    • vim.cmd.colorscheme("base16-<theme>")  │
│    • pcall for safe execution               │
└──────────────────┬──────────────────────────┘
                   ▼
         ┌─────────┴──────────┐
         │ Success?           │
         └─────────┬──────────┘
                   │ YES
                   ▼
┌─────────────────────────────────────────────┐
│ 3. Persist to Source of Truth               │
│    • vim.fn.writefile({theme}, ~/.theme)    │
└──────────────────┬──────────────────────────┘
                   ▼
┌─────────────────────────────────────────────┐
│ 4. Apply to Kitty (async)                   │
│    • Read theme file content                │
│    • Write to ~/.config/kitty/theme.conf    │
│    • vim.loop.spawn kitty @ set-colors      │
│    • Show notification on success           │
└──────────────────┬──────────────────────────┘
                   ▼
┌─────────────────────────────────────────────┐
│ 5. Apply to Shell (async)                   │
│    • Find matching .sh script               │
│    • vim.loop.spawn bash <script>           │
│    • Silent if script missing               │
└─────────────────────────────────────────────┘
```

### Startup Flow

```
Neovim Launch
    │
    ▼
init.lua loads
    │
    ▼
require('config.lazy')  [Plugin system loads]
    │
    ▼
base16 plugin loads (priority: 1000)
    │
    ▼
theme_sync = require('base16-theme-sync')
    │
    ▼
theme_sync.initialize_theme()
    │
    ▼
vim.schedule() to avoid fast event context
    │
    ▼
current_theme = get_current_theme()
    │  [Reads ~/.config/.theme]
    ▼
set_theme(current_theme)
    │
    ▼
[Same flow as user-initiated theme change]
    │
    ▼
Custom highlight autocmd applies CursorLine/Visual
```

---

## Integration Points

### Neovim ↔ Kitty

**Write Path**: `~/.config/kitty/theme.conf`

**Live Update**:
```bash
kitty @ set-colors --all <theme-path>
```

**Requirements**:
- Kitty's remote control must be enabled
- Add to `~/.config/kitty/kitty.conf`: `allow_remote_control yes`

**Fallback**: New Kitty tabs/windows use updated `theme.conf`

### Neovim ↔ Fish

**Execution**:
```bash
bash ~/.config/base16-shell/scripts/base16-<theme>.sh
```

**Mechanism**:
- Shell script exports `BASE16_THEME` environment variable
- Sets ANSI colors via escape sequences

**Scope**:
- Affects current terminal session
- Future Fish shells inherit colors

**Compatibility**: Also works with:
- tmux
- screen
- iTerm2 (detection in script)

### Neovim ↔ Neovim (Persistence)

**Write**: `~/.config/.theme` (single line with theme name)

**Read**: On startup via `initialize_theme()`

**Timing**: Written immediately after successful colorscheme application

**Synchronization**: Multiple Neovim instances read same file, ensuring consistency

---

## Error Handling and Edge Cases

### 1. Theme Validation

**Location**: `set_theme()` lines 58-73

**Checks**:
- Theme file exists in Kitty directory
- Prefers 256 variant, falls back to regular

**Error**:
```lua
vim.schedule(function()
  vim.notify(
    "Theme file not found: " .. theme_name,
    vim.log.levels.ERROR
  )
end)
```

**Recovery**: No theme change, current theme preserved

### 2. Neovim Colorscheme Failure

**Protection**: `pcall()` wrapper (line 79)

**Error**:
```lua
vim.notify(
  "Failed to apply Neovim colorscheme: " .. nvim_theme_name,
  vim.log.levels.ERROR
)
```

**Recovery**:
- Source of truth not updated
- Kitty/shell not touched
- Previous theme remains active

### 3. Kitty Theme Application

**File Write Failure** (lines 114-117):
```lua
vim.schedule(function()
  vim.notify(
    "Failed to write kitty theme file",
    vim.log.levels.ERROR
  )
end)
```

**Remote Control Failure** (lines 107-111):
- Silent failure (commented out notification)
- Theme still saved to `theme.conf` for future Kitty instances

### 4. Shell Script Missing

**Check**: `vim.fn.filereadable()` (line 127)

**Behavior**: Silent skip if script doesn't exist

**Impact**: Neovim and Kitty still themed correctly

**Example**: "gruvbox-material-dark-hard" theme exists in Kitty but not in base16-shell

### 5. Fast Event Context

**Issue**: Notifications during fast events can crash or be lost

**Solution**: `vim.schedule()` wrappers (lines 69, 106, 115, 120, 137)

**Applied to**:
- All `vim.notify()` calls
- `initialize_theme()` function
- Any UI updates during event callbacks

### 6. Theme Discovery Edge Cases

**256-only themes**: Included if no regular version exists (line 34)

**Empty directory**: Returns empty array, Telescope shows "No results"

**Invalid files**: Filtered out by pattern matching (lines 19, 25)

---

## Implementation Details

### Async Operations with vim.loop.spawn

#### Kitty Application (Lines 97-113)

```lua
vim.loop.spawn('kitty', {
  args = { '@', 'set-colors', '--all', final_kitty_path }
}, function(code, signal)
  vim.schedule(function()
    if code == 0 then
      vim.notify(
        "Theme applied successfully",
        vim.log.levels.INFO
      )
    end
  end)
end)
```

**Features**:
- **Non-blocking**: Neovim continues immediately
- **Callback**: Executes when process completes
- **Exit code check**: Only shows success notification if `code == 0`
- **Scheduled notification**: Avoids fast event context issues

#### Shell Application (Lines 128-130)

```lua
vim.loop.spawn('bash', {
  args = { shell_script }
}, nil)
```

**Features**:
- **Fire and forget**: No callback (nil)
- **No output capture**: Shell script output ignored
- **Silent failure**: Missing scripts don't show errors

### Theme Discovery Algorithm

**Complexity**: O(n) where n = number of .conf files

**Steps**:
1. Glob all `base16-*.conf` files
2. For each file:
   - Extract theme name with pattern matching
   - Track regular and 256 variants separately
3. Build final list:
   - Include regular themes
   - Include 256-only themes (no regular version)
   - Exclude 256 variants if regular exists
4. Sort alphabetically

**Result**: Clean list without duplicates, preferring regular names

**Example**:
```
Files:
  base16-nord.conf
  base16-nord-256.conf
  base16-onedark-256.conf  (no regular version)

Result:
  ["nord", "onedark"]
```

### Highlight Persistence Pattern

**Challenge**: Custom highlights lost on ColorScheme event

**Solution** (`init.lua` lines 46-59):
```lua
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.api.nvim_set_hl(0, "CursorLine", {
      fg = _G.custom_cursorline_fg,
      bg = _G.custom_cursorline_color
    })
    vim.api.nvim_set_hl(0, "Visual", {
      fg = _G.custom_visual_fg,
      bg = _G.custom_visual_bg
    })
    -- Disable LSP semantic highlighting for C++ comments
    vim.api.nvim_set_hl(0, "@lsp.type.comment.cpp", { link = "" })
  end,
})
```

**Key Points**:
- **Global storage**: `_G.*` variables persist across events
- **Autocmd**: Reapplies after every colorscheme change
- **Applied to**: CursorLine, Visual, @lsp.type.comment.cpp

---

## Key Design Decisions

### 1. Why Single Source of Truth?

**Problem**: Multiple config files could become inconsistent

**Solution**: One file (`~/.config/.theme`) owned by Neovim

**Benefits**:
- Always know current theme
- Easy to debug
- Single write point prevents race conditions
- Other applications can read if needed

### 2. Why Prefer 256 Variants?

**Reasoning**: Better color accuracy in some terminals

**Implementation**: Check 256 file first, fall back to regular (lines 62-66)

**Neovim Exception**: Always uses regular (strips -256) since nvim-base16 has no variants

### 3. Why Async Operations?

**Problem**: External commands can block Neovim UI

**Solution**: `vim.loop.spawn()` for Kitty and shell

**Trade-off**:
- Pro: Non-blocking, smooth user experience
- Con: Slightly delayed application (imperceptible)

### 4. Why vim.schedule() Everywhere?

**Problem**: Notifications during fast events crash or get lost

**Solution**: Schedule all notifications and initialization

**Locations**:
- All `vim.notify()` calls
- `initialize_theme()`
- Any callback that updates UI

### 5. Why No Shell Script Error Handling?

**Reasoning**: Optional enhancement, not critical for core functionality

**Impact**: Neovim and Kitty themed correctly regardless

**Future**: Could add notification if script missing (commented option available)

### 6. Why Live Preview in Telescope?

**User Experience**: See theme immediately while browsing

**Implementation**: Call `set_theme()` on cursor movement

**Cost**: Many theme switches during browsing (but fast due to async operations)

**Alternative Considered**: Preview window with syntax examples (function exists but not used)

---

## Usage Examples

### 1. Interactive Theme Selection

```vim
" Open theme picker with live preview
<leader>th

" Navigate with:
"   <C-n> / <Down> - Next theme (with preview)
"   <C-p> / <Up>   - Previous theme (with preview)
"   <Enter>        - Confirm selection and close
"   <Esc>          - Cancel (last previewed theme stays active)
```

**Workflow**:
1. Press `<leader>th`
2. Start typing to filter (fuzzy finding)
3. Use arrow keys to browse - themes change instantly
4. Press Enter to confirm, or Esc to keep current

### 2. Command Line

```vim
" Set specific theme
:SetTheme gruvbox-dark-hard

" Tab completion works - press <Tab> to cycle through themes
:SetTheme <Tab>

" Partial matching with tab completion
:SetTheme nord<Tab>
```

### 3. Programmatic Usage

```lua
-- In Neovim Lua code or init.lua
local theme_sync = require('base16-theme-sync')

-- Get available themes
local themes = theme_sync.get_available_themes()
print(vim.inspect(themes))

-- Get current theme
local current = theme_sync.get_current_theme()
print("Current theme: " .. current)

-- Set new theme
theme_sync.set_theme('nord')

-- Conditional theme based on time
local hour = tonumber(os.date("%H"))
if hour >= 6 and hour < 18 then
  theme_sync.set_theme('one-light')
else
  theme_sync.set_theme('nord')
end
```

### 4. Automation Examples

**Time-based theme switching** (add to `init.lua`):
```lua
-- Auto-switch based on time of day
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local hour = tonumber(os.date("%H"))
    local theme_sync = require('base16-theme-sync')

    if hour >= 7 and hour < 19 then
      theme_sync.set_theme('one-light')
    else
      theme_sync.set_theme('nord')
    end
  end,
})
```

**Random theme on startup**:
```lua
local theme_sync = require('base16-theme-sync')
local themes = theme_sync.get_available_themes()
local random_theme = themes[math.random(#themes)]
theme_sync.set_theme(random_theme)
```

---

## Debugging and Troubleshooting

### Check Current Theme

```bash
cat ~/.config/.theme
# Output: gruvbox-material-dark-hard
```

### Check Kitty Config

```bash
cat ~/.config/kitty/theme.conf
# Should show: background, foreground, color0-color15
```

### Verify Theme Files Exist

```bash
ls ~/.config/base16-kitty/colors/ | grep base16-nord
# Should show: base16-nord.conf and/or base16-nord-256.conf
```

### List All Available Themes

```bash
ls ~/.config/base16-kitty/colors/ | wc -l
# Count of theme files (should be 466)
```

### Test Kitty Remote Control

```bash
kitty @ set-colors --all ~/.config/base16-kitty/colors/base16-nord.conf
# Should immediately change terminal colors

# If error: "Can't connect to kitty"
# Add to ~/.config/kitty/kitty.conf:
#   allow_remote_control yes
```

### Check Shell Script

```bash
bash ~/.config/base16-shell/scripts/base16-nord.sh
# Should change terminal colors

# If error: "No such file"
# Shell script for that theme doesn't exist (non-critical)
```

### Neovim Debugging

```vim
" Check if colorscheme loaded
:echo g:colors_name
" Should show: base16-<theme-name>

" Check theme sync module
:lua print(require('base16-theme-sync').get_current_theme())

" List all available themes
:lua print(vim.inspect(require('base16-theme-sync').get_available_themes()))

" Manually reinitialize theme system
:lua require('base16-theme-sync').initialize_theme()

" Check if module loaded correctly
:lua print(package.loaded['base16-theme-sync'])

" View recent notifications
:Notifications  " (if using snacks.nvim)
```

### Common Issues

#### Theme doesn't apply to Kitty

**Symptoms**: Neovim changes but terminal stays same

**Diagnosis**:
```bash
# Check if remote control enabled
kitty @ ls
# If error: remote control not enabled
```

**Solution**: Add to `~/.config/kitty/kitty.conf`:
```conf
allow_remote_control yes
```

#### Theme doesn't persist on restart

**Symptoms**: Theme resets to default on Neovim restart

**Diagnosis**:
```bash
# Check if source of truth file exists and is writable
ls -la ~/.config/.theme
cat ~/.config/.theme
```

**Solution**:
- Ensure `~/.config/.theme` is writable
- Check file permissions: `chmod 644 ~/.config/.theme`

#### Custom highlights not persisting

**Symptoms**: CursorLine/Visual colors revert after theme change

**Diagnosis**: Check if ColorScheme autocmd is set up in `init.lua`

**Solution**: Ensure autocmd is present (lines 46-59 in init.lua)

#### 256 variant not preferred

**Symptoms**: Regular theme used even though 256 variant exists

**Diagnosis**: Check variant preference code

**Verification**:
```lua
:lua local theme = "nord"; local path_256 = vim.fn.expand("~/.config/base16-kitty/colors/base16-" .. theme .. "-256.conf"); print(vim.fn.filereadable(path_256))
" Should return 1 if 256 variant exists
```

---

## Future Enhancement Opportunities

### 1. Preview Window in Telescope

**Current**: No previewer enabled

**Enhancement**: Use `create_theme_preview()` function
```lua
previewer = previewers.new_buffer_previewer({
  define_preview = function(self, entry)
    local preview_lines = theme_sync.create_theme_preview(entry.value)
    vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, preview_lines)
    vim.bo[self.state.bufnr].filetype = "markdown"
  end,
})
```

**Benefit**: Show syntax examples while browsing

### 2. Theme History

**Feature**: Track recently used themes

**Implementation**:
```lua
-- Store in: ~/.config/nvim/theme-history.json
M.recent_themes = {}
M.add_to_history = function(theme_name)
  -- Keep last 10 themes
end
```

**UI**: Add to Telescope picker as section

**Benefit**: Quick switch between favorites

### 3. Theme Groups/Categories

**Feature**: Organize themes by light/dark or color family

**Implementation**:
```lua
M.categorize_themes = function(themes)
  return {
    dark = { ... },
    light = { ... },
    colorful = { ... },
    minimal = { ... },
  }
end
```

**UI**: Multi-level Telescope picker or sections

### 4. Error Recovery

**Feature**: Revert to previous theme on failure

**Implementation**:
```lua
local previous_theme = M.get_current_theme()
if not pcall(set_new_theme) then
  M.set_theme(previous_theme)
end
```

**Benefit**: Always have working theme

### 5. Shell Script Notifications

**Feature**: Notify if shell script missing

**Implementation**: Uncomment line 130 notification

**Benefit**: User awareness of partial application

### 6. Remote Neovim Instances Sync

**Feature**: Sync theme across multiple Neovim instances

**Implementation**: File watching on `~/.config/.theme`
```lua
local watch = vim.loop.new_fs_event()
watch:start(M.theme_file, {}, function()
  vim.schedule(function()
    M.initialize_theme()
  end)
end)
```

**Benefit**: All Neovim windows stay synchronized

### 7. Time-Based Themes

**Feature**: Auto-switch based on time of day

**Implementation**:
```lua
M.auto_theme_by_time = function()
  local hour = tonumber(os.date("%H"))
  if hour >= 7 and hour < 19 then
    M.set_theme('one-light')
  else
    M.set_theme('nord')
  end
end
```

**Benefit**: Automatic light/dark mode switching

### 8. Theme Variants (Contrast)

**Feature**: Support different contrast levels of same theme

**Example**: `nord`, `nord-high-contrast`, `nord-low-contrast`

**Implementation**: Group variants in picker

### 9. Color Palette Preview

**Feature**: Show theme's color palette as boxes

**Implementation**: Terminal RGB color codes in preview

**Benefit**: Visual theme browsing

### 10. Export/Import Theme Preferences

**Feature**: Share theme configurations

**Format**: JSON file with theme + custom highlights

**Benefit**: Easy sharing across machines

---

## Summary

This Base16 colorscheme management system is a **production-quality** cross-application theme synchronization solution featuring:

### Strengths

✓ **Clean Architecture**: Single module, clear separation of concerns
✓ **Robust Error Handling**: pcall wrappers, existence checks, graceful degradation
✓ **User Experience Focus**: Live preview, async operations, clear notifications
✓ **Persistence**: Theme survives restarts across all applications
✓ **Cross-Application**: Neovim, Kitty, and Fish shell in perfect sync
✓ **Performance**: Non-blocking operations, efficient theme discovery
✓ **Maintainability**: Well-documented, modular design

### Technical Highlights

- **Async I/O**: Uses `vim.loop.spawn` for non-blocking external commands
- **Event Safety**: `vim.schedule()` for all UI updates during callbacks
- **Smart Defaults**: Prefers 256-color variants, fallback to regular
- **Variant Management**: Automatically handles theme variants
- **Custom Highlights**: Persists across theme changes via autocmds
- **Tab Completion**: User command with full theme name completion
- **Live Preview**: Real-time theme changes while browsing in Telescope

### Architecture Pattern

The system demonstrates advanced Lua patterns including:
- Module-based organization
- Functional programming style
- Async operation handling
- Event-driven updates
- Single source of truth pattern
- Custom Telescope pickers

This is an excellent example of integrating Neovim with external tools while maintaining a smooth, professional user experience.
