# claude-plugins

Claude Code のプラグイン・MCP サーバーを一括管理するリポジトリ。
複数 PC 間で `plugins.conf` を通じてプラグイン設定を共有する。

## セットアップ

```fish
git clone https://github.com/sanoakr/claude-plugins.git ~/claude-plugins
cd ~/claude-plugins
./setup-plugins.fish
```

## 使い方

```fish
# 全プラグインをインストール・更新
./setup-plugins.fish

# プラグイン一覧（日本語説明付き）
./setup-plugins.fish list

# プラグインを追加（インストール → コミット → プッシュまで自動）
./setup-plugins.fish add <plugin-name>
./setup-plugins.fish add <plugin-name>@<owner/marketplace-repo>

# プラグインを削除（アンインストール → コミット → プッシュまで自動）
./setup-plugins.fish remove <plugin-name>

# リモートから pull して全プラグインを同期（別 PC での初回同期に）
./setup-plugins.fish sync
```

## プラグイン一覧

`plugins.conf` で管理。`./setup-plugins.fish list` で日本語説明付きの一覧を表示できる。

### Anthropic 公式

| プラグイン | 用途 |
|-----------|------|
| `feature-dev` | 機能開発を 7 フェーズに構造化し、専門エージェントで探索・設計・レビューを実行 |
| `code-review` | 複数の専門エージェントによる自動コードレビュー（信頼度スコアで誤検出を抑制） |
| `commit-commands` | コミット・プッシュ・PR 作成を自動化する Git ワークフローコマンド |
| `frontend-design` | AI っぽくない個性的で高品質なフロントエンド UI を生成 |
| `security-guidance` | ファイル編集時にコマンドインジェクション・XSS 等のセキュリティリスクを自動警告 |
| `code-simplifier` | 最近変更されたコードを対象に、明瞭性・一貫性・保守性を向上させるリファクタリング |
| `superpowers` | ブレインストーミング・サブエージェント駆動開発・体系的デバッグ・TDD を強化 |

### OpenAI

| プラグイン | 用途 |
|-----------|------|
| `codex` | OpenAI Codex を使ったコードレビューやタスク委任 |

### サードパーティ / MCP

| プラグイン | 用途 |
|-----------|------|
| `context7` | 最新のバージョン別ドキュメントとコード例をソースから直接取得する MCP サーバー |
| `playwright` | Microsoft のブラウザ自動化 MCP サーバー（スクリーンショット・フォーム入力・E2E テスト） |
| `github` | GitHub 公式 MCP サーバー（Issue・PR・レビュー・リポジトリ検索・API 連携） |
| `cloudflare` | Cloudflare 開発プラットフォーム向けスキル（Workers・Durable Objects・Wrangler 等） |
| `notion` | Notion ワークスペース連携（ページ検索・作成・更新・データベース管理） |

### MCP サーバー

`mcp-servers.json` に定義。セットアップ時に `~/.claude/mcp_servers.json` へマージされる。

## ファイル構成

```
claude-plugins/
├── setup-plugins.fish   # セットアップスクリプト
├── plugins.conf         # プラグインリスト（これを編集して共有）
├── plugins.desc         # 日本語説明ファイル
├── mcp-servers.json     # MCP サーバー設定（共有用）
├── README.md
└── .gitignore
```

## 関連リポジトリ

- [sanoakr/ai-skills](https://github.com/sanoakr/ai-skills) — Claude Code スキル管理
