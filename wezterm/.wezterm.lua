local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Font
config.font = wezterm.font('JetBrainsMono Nerd Font')
config.font_size = 14.0

-- Colors
config.color_scheme = 'Catppuccin Mocha'

-- Window
config.window_decorations = 'RESIZE'
config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }

-- Tab bar
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false

-- Cursor
config.default_cursor_style = 'BlinkingBlock'

-- Scrollback
config.scrollback_lines = 10000

config.front_end = "WebGpu"  -- uses Metal on macOS
config.treat_east_asian_ambiguous_width_as_wide = true

return config
