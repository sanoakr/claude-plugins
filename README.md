# ai-plugin

Claude Code のプラグイン・MCP サーバーを一括管理するリポジトリ。
複数 PC 間で `claude plugin` の設定を共有する。

## セットアップ

```fish
git clone https://github.com/sanoakr/ai-plugin.git ~/ai-plugin
cd ~/ai-plugin
./setup-plugins.fish
```

## 管理対象

### プラグイン（Anthropic 公式）

| プラグイン | 用途 |
|-----------|------|
| `feature-dev` | 機能開発を 7 フェーズに構造化（Discovery → Summary） |
| `code-review` | 4 専門エージェントによる並列コードレビュー |
| `commit-commands` | コミット・プッシュ・PR 作成の自動化 |
| `frontend-design` | 個性的な UI 生成、タイポグラフィ・アニメーション品質向上 |
| `security-guidance` | ファイル編集時のセキュリティリスク自動警告 |

### MCP サーバー

`mcp-servers.json` に定義。セットアップ時に `~/.claude/mcp_servers.json` へマージされる。

## コマンドリファレンス

```fish
# プラグイン操作
claude plugin list                       # 一覧
claude plugin install <name>             # インストール
claude plugin update <name>              # 更新
claude plugin uninstall <name>           # 削除
claude plugin marketplace list           # マーケットプレイス一覧
claude plugin marketplace add owner/repo # マーケットプレイス追加
```

## ファイル構成

```
ai-plugin/
├── setup-plugins.fish   # セットアップスクリプト
├── mcp-servers.json     # MCP サーバー設定（共有用）
├── README.md
└── .gitignore
```

## 関連リポジトリ

- [sanoakr/ai-skills](https://github.com/sanoakr/ai-skills) — Claude Code スキル管理
