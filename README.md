# ai-plugin

Claude Code のプラグイン・MCP サーバーを一括管理するリポジトリ。
複数 PC 間で `claude plugin` の設定を共有する。

## セットアップ

```fish
git clone https://github.com/sanoakr/ai-plugin.git ~/ai-plugin
cd ~/ai-plugin
./setup-plugins.fish
```

## 使い方

```fish
# 全プラグインをインストール・更新
./setup-plugins.fish

# プラグインを追加（インストール → コミット → プッシュまで自動）
./setup-plugins.fish add <plugin-name>
./setup-plugins.fish add <plugin-name>@<owner/marketplace-repo>

# プラグインを削除（アンインストール → コミット → プッシュまで自動）
./setup-plugins.fish remove <plugin-name>

# 設定済みプラグインの一覧
./setup-plugins.fish list

# リモートから pull して全プラグインを同期（別 PC での初回同期に）
./setup-plugins.fish sync
```

## 管理対象

### プラグイン

`plugins.conf` で管理。現在のプラグイン：

| プラグイン | 用途 |
|-----------|------|
| `feature-dev` | 機能開発を 7 フェーズに構造化（Discovery → Summary） |
| `code-review` | 4 専門エージェントによる並列コードレビュー |
| `commit-commands` | コミット・プッシュ・PR 作成の自動化 |
| `frontend-design` | 個性的な UI 生成、タイポグラフィ・アニメーション品質向上 |
| `security-guidance` | ファイル編集時のセキュリティリスク自動警告 |

### MCP サーバー

`mcp-servers.json` に定義。セットアップ時に `~/.claude/mcp_servers.json` へマージされる。

## ファイル構成

```
ai-plugin/
├── setup-plugins.fish   # セットアップスクリプト
├── plugins.conf         # プラグインリスト（これを編集して共有）
├── mcp-servers.json     # MCP サーバー設定（共有用）
├── README.md
└── .gitignore
```

## 関連リポジトリ

- [sanoakr/ai-skills](https://github.com/sanoakr/ai-skills) — Claude Code スキル管理
