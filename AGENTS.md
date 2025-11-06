# Repository Guidelines

このリポジトリは、ターミナルソフトウェア WezTerm (https://wezterm.org/) の設定を管理します。

## プロジェクト構成
- `wezterm.lua`: ルートの主設定ファイル。配色・キーバインド・起動動作を定義。
- 拡張時は `lua/` に分割（例: `lua/colors.lua`, `lua/keymaps.lua`）。各モジュールは `return { ... }` を返す構成を推奨。
- ドキュメントは `README.md`。変更点がユーザー操作に影響する場合は更新してください。

## ビルド・実行・検証
- 設定読み込みの健全性確認: `wezterm ls-fonts > /dev/null`（CLI実行で設定が読めるかを簡易確認）。
- 設定を指定して起動: `wezterm start --config-file wezterm.lua`。
- キーバインド確認: `wezterm show-keys`（定義の衝突や反映状況を確認）。
- 詳細ログ: `WEZTERM_LOG=info wezterm start --config-file wezterm.lua`。

## コーディング規約・命名
- 言語は Lua。インデントはスペース2、UTF-8、LF。グローバルを避け `local` を使用。
- 変数・テーブルは `snake_case`、定数風は `UPPER_SNAKE_CASE` を推奨。
- 大きな設定はテーブルに分割し `require('lua/…')` で読み込み、最終的に `return` で構成を返す。
- 自動整形は可能なら `stylua wezterm.lua lua/` を推奨（導入済みであれば準拠）。

## テスト指針
- 自動テストはありません。以下を手動検証してください。
  - キーバインド（`wezterm show-keys`）、タブ/ペイン操作、色テーマ、フォント/フォールバック。
  - 主要OS（Windows/macOS/Linux）の差異を意識。必要なら条件分岐で切替。
- 回帰防止: 変更前後の `wezterm.lua` と挙動の差分を記録（`README.md` にメモ可）。

## コミット/PR ガイド
- コミットは小さく、説明は短い命令形。例: `feat: add macOS keymaps` / `fix: correct font fallback`。
- PR には目的、影響範囲、確認手順、関連 Issue、必要に応じスクリーンショット/ログを含める。
- OS/WezTerm バージョンを明記するとレビューが容易です。

## セキュリティ/設定 Tips
- 個人情報・APIキーは書かない。環境依存値は環境変数や条件分岐で扱う。
- OS 分岐例: `if wezterm.target_triple:find('windows') then ... end`。

## エージェント向け補足
- 作業シェルは Git Bash を使用。`cmd.exe`/`powershell.exe` は使用しない。
- 既存ファイルの改行コードを変更しない。大規模置換時は差分を必ず確認。
