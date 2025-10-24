local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local act = wezterm.action
local isWindows = wezterm.target_triple:find("windows") ~= nil

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

-- ファイル存在チェック
local function file_exists(path)
  local f = io.open(path, 'r')
  if f ~= nil then f:close() return true end
  return false
end

-- Windows 用: 最初に見つかった zsh を返す
local function first_existing_path(paths)
  for _, p in ipairs(paths) do
    if file_exists(p) then
      return p
    end
  end
  return nil
end

local function windows_default_prog()
  local candidates = {
    'C:/git-sdk-64/usr/bin/zsh.exe',
    'C:/dev/gitsdk/usr/bin/zsh.exe',
    'C:/dev/git-sdk/usr/bin/zsh.exe',
  }
  -- どれも無ければ最後の候補（従来の既定と同等）
  local zsh = first_existing_path(candidates) or candidates[#candidates]
  return { zsh, '-l' }
end

if isWindows then
  config.default_prog = windows_default_prog()
end

-- ime
merge_config({
  use_ime = true,
  macos_forward_to_ime_modifier_mask = 'SHIFT|CTRL',
})

if isWindows then
  merge_config({
    font_size = 12,
    line_height = 1.2,
    font = wezterm.font_with_fallback({
      'HackGen',
      "Cascadia Code PL",
      "Meiryo",
      "MS Gothic",
      "Segoe UI Emoji",
      "Segoe UI Symbol",
    })
  })
else
  -- mac
  merge_config({
    font_size = 13,
    line_height = 1.2,
    font = wezterm.font_with_fallback({
      'Monaco',
      'HackGen',
    })
  })
end

-- term
merge_config({
  audible_bell = "Disabled",
  warn_about_missing_glyphs = false, -- font が無い場合の警告
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

-- mouse
merge_config({
  mouse_bindings = {
    -- 既存設定を維持しつつ右クリックで貼り付け
    {
      event = { Down = { streak = 1, button = 'Right' } },
      mods = 'NONE',
      action = wezterm.action.PasteFrom 'Clipboard',
    },
  },
})

-- ローカル上書き設定の読み込み（ホーム直下の .wezterm.local.lua を対象）
do
  local home = wezterm.home_dir or os.getenv('HOME') or os.getenv('USERPROFILE') or '.'
  home = home:gsub('\\', '/')
  local local_path = home .. '/.wezterm.local.lua'

  local f = io.open(local_path, 'r')
  if f ~= nil then
    f:close()
    local ok, ret = pcall(dofile, local_path)
    if ok then
      if type(ret) == 'table' then
        merge_config(ret)
      elseif type(ret) == 'function' then
        pcall(ret, config, wezterm, merge_config)
      end
    end
  end
end

return config
