local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local act = wezterm.action

-- 設定をマージするユーティリティ関数
local function merge_config(source)
  for k, v in pairs(source) do
    config[k] = v
  end
end

-- vim / nvim（tmux 経由も想定）を判定
local function is_vim_like(pane)
  local p = pane:get_foreground_process_name() or ''
  local base = (p:match('([^/\\]+)$') or p):lower()  -- フルパス → basename → 小文字化
  return base == 'vim' or base == 'nvim'
end

-- ime
merge_config({
  use_ime = true,
  macos_forward_to_ime_modifier_mask = 'SHIFT|CTRL',
})

-- font
merge_config({
  font_size = 13,
  line_height = 1.2,
  font = wezterm.font_with_fallback({
    'Monaco',
    'HackGen',
  })
})

-- color
merge_config({
  color_scheme = "Dracula+",
  colors = {
    cursor_bg = 'orange',  -- カーソル本体の色
    cursor_fg = 'black',  -- カーソル上の文字色（反転色）
    cursor_border = 'orange', -- カーソル枠線色（ブロックカーソル用）
    tab_bar = {
      active_tab = {
        bg_color = '#696969',
        fg_color = '#ffffff',
      },
      inactive_tab = {
        bg_color = '#000000',
        fg_color = '#ffffff',
      },
      new_tab = {
        bg_color = '#000000',
        fg_color = '#ffffff',
      },
    }
  },
})

-- コマンドパレット
merge_config({
  command_palette_font_size = 17.0,
  command_palette_rows = 15,
})

-- タブ
merge_config({
  tab_max_width = 50,
})

wezterm.on('format-tab-title', function(tab)
  local title = tab.active_pane.title
  local min_width = 30
  -- タイトルをスペースで埋めて右側を切り詰める
  local padded = title .. string.rep(' ', min_width)
  return ' ' .. wezterm.truncate_right(padded, min_width) .. ' '
end)

-- Ctrl+V のスマート動作
wezterm.on('smart-paste', function(win, pane)
  if is_vim_like(pane) then
    -- vim 中は WezTerm 側では貼り付けず、^V をそのまま送る
    win:perform_action(act.SendKey { key = 'v', mods = 'CTRL' }, pane)
  else
    -- vim 以外ではクリップボードから貼り付け
    win:perform_action(act.PasteFrom 'Clipboard', pane)
  end
end)

-- keys
merge_config({
  leader = { key = 'x', mods = 'CTRL', timeout_milliseconds = 1000 },
  keys = {
    -- 貼り付け
    { key = 'v', mods = 'CTRL',  action = act.EmitEvent 'smart-paste' }, -- Ctrl+V
    { key = 'v', mods = 'SUPER', action = act.PasteFrom 'Clipboard' }, -- Cmd+V
    -- コマンドパレット
    { key = 'p', mods = 'LEADER|CTRL', action = act.ActivateCommandPalette },
    -- Ctrl+. → 次のタブへ
    { key = '.', mods = 'CTRL', action = wezterm.action.ActivateTabRelative(1) },
    -- Ctrl+, → 前のタブへ
    { key = ',', mods = 'CTRL', action = wezterm.action.ActivateTabRelative(-1) },
    -- Ctrl+[ で 1 行上にスクロール
    { key = '[', mods = 'CTRL', action = wezterm.action.ScrollByLine(-5) },
    -- Ctrl+] で 1 行下にスクロール
    { key = ']', mods = 'CTRL', action = wezterm.action.ScrollByLine(5) },

    -- Ctrl+X, Ctrl+V で右に分割（縦割り）
    { key = 'v', mods = 'LEADER|CTRL', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    -- ペイン移動
    { key = 'h', mods = 'LEADER|CTRL', action = act.ActivatePaneDirection 'Left' },
    { key = 'j', mods = 'LEADER|CTRL', action = act.ActivatePaneDirection 'Down' },
    { key = 'k', mods = 'LEADER|CTRL', action = act.ActivatePaneDirection 'Up' },
    { key = 'l', mods = 'LEADER|CTRL', action = act.ActivatePaneDirection 'Right' },
    -- Ctrl-X, Ctrl-B → ^X^B を送信
    { key = 'b', mods = 'LEADER|CTRL', action = act.SendString('\x18\x02') },
    -- Ctrl-X, Ctrl-A → ^X^A を送信
    { key = 'a', mods = 'LEADER|CTRL', action = act.SendString('\x18\x01') },
    -- Ctrl-X, Ctrl-S → ^X^S を送信
    { key = 's', mods = 'LEADER|CTRL', action = act.SendString('\x18\x13') },
  },
})

return config
