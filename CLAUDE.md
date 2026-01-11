# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要
このリポジトリは WezTerm (https://wezterm.org/) の設定ファイルを管理しています。
メイン設定ファイルは `wezterm.lua` で、Windows と macOS の両方に対応しています。

## 設定の検証コマンド
```bash
# 設定ファイルの健全性確認
wezterm ls-fonts > /dev/null

# 設定を指定して起動
wezterm start --config-file wezterm.lua

# キーバインド確認
wezterm show-keys

# 詳細ログ付きで起動
WEZTERM_LOG=info wezterm start --config-file wezterm.lua
```

## アーキテクチャ
### merge_config 関数
- `wezterm.config_builder()` で作成した `config` オブジェクトに対して、既存キーのみを再帰的に上書きする
- 新規キーは追加せず、既存の設定値を保持しながら特定のサブキーだけを変更できる仕組み

### プラットフォーム対応
- `wezterm.target_triple:find("windows")` で Windows を判定
- Windows では複数の候補パスから zsh を検索し、最初に見つかったものを `default_prog` に設定
- フォントサイズ・フォールバックはプラットフォームごとに分岐

### ローカル設定の上書き
- `~/.wezterm.local.lua` が存在する場合、最後に読み込まれる
- テーブルまたは関数を返すことで、マシン固有の設定を上書き可能

### スマートペースト機能
- `is_vim_like()` で vim/nvim を判定し、Ctrl+V の挙動を切り替える
- vim 実行中は `^V` をそのまま送信、それ以外ではクリップボードから貼り付け

## コーディング規約
- Lua を使用、インデントはスペース2、UTF-8、LF
- 変数・テーブルは `snake_case`、定数風は `UPPER_SNAKE_CASE`
- グローバル変数を避け `local` を使用
- 拡張時は `lua/` ディレクトリに分割し、各モジュールは `return { ... }` を返す構成を推奨

## Git 作業環境
- Git Bash を使用（`cmd.exe`/`powershell.exe` は使用しない）
- 既存ファイルの改行コードを変更しない
