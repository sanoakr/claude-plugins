# claude-plugins

![version](https://img.shields.io/badge/version-v0.9.0-blue)
![license](https://img.shields.io/badge/license-MIT-green)

[日本語](./README.ja.md) | English

Centralized management of Claude Code plugins and MCP servers, shared across multiple PCs via `plugins.conf`.

## Setup

```fish
git clone https://github.com/sanoakr/claude-plugins.git ~/claude-plugins
cd ~/claude-plugins
./setup-plugins.fish
```

## Usage

```fish
# Install / update all plugins
./setup-plugins.fish

# List plugins with descriptions
./setup-plugins.fish list

# Add a plugin (installs, commits, and pushes)
./setup-plugins.fish add <plugin-name>
./setup-plugins.fish add <plugin-name>@<owner/marketplace-repo>

# Remove a plugin (uninstalls, commits, and pushes)
./setup-plugins.fish remove <plugin-name>

# Pull and sync all plugins from remote (initial sync on another PC)
./setup-plugins.fish sync
```

## Plugin List

Managed via `plugins.conf`. Run `./setup-plugins.fish list` to view with descriptions.

### Anthropic Official

| Plugin | Description |
|--------|-------------|
| `feature-dev` | Structures feature development into 7 phases with specialized agents |
| `code-review` | Automated code review by multiple specialized agents with confidence scoring |
| `commit-commands` | Git workflow automation for commits, pushes, and PR creation |
| `frontend-design` | Generates high-quality, distinctive frontend UI |
| `security-guidance` | Auto-warns about security risks (command injection, XSS, etc.) on file edits |
| `code-simplifier` | Refactors recently changed code for clarity, consistency, and maintainability |
| `superpowers` | Enhances brainstorming, subagent-driven development, debugging, and TDD |

### OpenAI

| Plugin | Description |
|--------|-------------|
| `codex` | Code review and task delegation via OpenAI Codex |

### Third-party / MCP

| Plugin | Description |
|--------|-------------|
| `context7` | Fetches up-to-date versioned docs and code examples directly from source |
| `playwright` | Microsoft's browser automation MCP (screenshots, forms, E2E testing) |
| `github` | Official GitHub MCP (issues, PRs, reviews, repo search, API) |
| `cloudflare` | Cloudflare dev platform skills (Workers, Durable Objects, Wrangler) |
| `notion` | Notion workspace integration (search, create, update pages & databases) |

## File Structure

```
claude-plugins/
├── setup-plugins.fish   # Setup script
├── plugins.conf         # Plugin list (edit and share this)
├── plugins.desc         # Japanese plugin descriptions
├── mcp-servers.json     # MCP server config (shared)
└── README.md
```

## Related

- [sanoakr/ai-skills](https://github.com/sanoakr/ai-skills) — AI skill management for Claude Code

## Changelog

### v0.9.0 (2026-05-28)

- 7 Anthropic official plugins, 1 OpenAI plugin, 5 third-party/MCP plugins
- Bulk plugin management via `plugins.conf`
- `add` / `remove` / `sync` / `list` subcommands
- Japanese descriptions via `plugins.desc`
- MCP server config sharing via `mcp-servers.json`

## License

MIT
