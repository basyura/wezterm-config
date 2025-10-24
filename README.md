# README

## wezterm.local.lua

`~/.wezterm.local.lua` に置くと読み込まれる。

```lua
local wezterm = require 'wezterm'

return {
  font_size = 14,
  font = wezterm.font_with_fallback({
    'UD Digi Kyokasho N-R',
    "Cascadia Code PL",
    "Meiryo",
    "MS Gothic",
    "Segoe UI Emoji",
    "Segoe UI Symbol",
  }),
}
```


