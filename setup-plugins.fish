#!/usr/bin/env fish
# Claude Code プラグイン・MCP 一括セットアップスクリプト
# 複数 PC 間で設定を共有するために GitHub リポジトリで管理する
#
# 使い方:
#   ./setup-plugins.fish              全プラグインをインストール・更新
#   ./setup-plugins.fish add <name>   プラグインを追加してコミット・プッシュ
#   ./setup-plugins.fish remove <name> プラグインを削除してコミット・プッシュ
#   ./setup-plugins.fish list         plugins.conf の内容を表示
#   ./setup-plugins.fish sync         リモートから pull して全プラグインを同期

set REPO_DIR (dirname (realpath (status --current-filename)))
set CONF "$REPO_DIR/plugins.conf"
set MCP_CONFIG "$REPO_DIR/mcp-servers.json"

# 公式マーケットプレイス
set DEFAULT_MARKETPLACE "anthropics/claude-plugins-official"

# ---------- ヘルパー関数 ----------

function read_plugins
    if not test -f $CONF
        echo "Error: $CONF not found" >&2
        return 1
    end
    grep -v '^\s*#' $CONF | grep -v '^\s*$' | string trim
end

function parse_plugin --argument-names entry
    if string match -q '*@*' -- $entry
        set -l parts (string split '@' -- $entry)
        echo $parts[1]
        echo $parts[2]
    else
        echo $entry
        echo $DEFAULT_MARKETPLACE
    end
end

function marketplace_short --argument-names mp
    # known_marketplaces.json から owner/repo → 登録名を解決
    set -l known "$HOME/.claude/plugins/known_marketplaces.json"
    if test -f $known; and command -q python3
        set -l resolved (python3 -c "
import json
data = json.load(open('$known'))
for name, info in data.items():
    if info.get('source', {}).get('repo') == '$mp':
        print(name)
        break
" 2>/dev/null)
        if test -n "$resolved"
            echo $resolved
            return
        end
    end
    # フォールバック: repo 名の末尾部分
    string replace -r '.+/' '' -- $mp
end

function ensure_marketplace --argument-names mp
    set -l existing (claude plugin marketplace list 2>&1)
    if not string match -q "*$mp*" -- $existing
        claude plugin marketplace add $mp 2>&1 >/dev/null
    end
end

function install_plugin --argument-names name mp
    set -l mp_short (marketplace_short $mp)
    set -l full "$name@$mp_short"
    set -l installed (claude plugin list 2>&1)
    if string match -q "*$name@*" -- $installed
        echo "already installed"
        return 0
    end
    set -l output (claude plugin install $full 2>&1)
    if test $status -eq 0
        echo "ok"
        return 0
    else
        echo "FAILED: $output"
        return 1
    end
end

function get_plugin_description --argument-names name mp
    set -l desc_file "$REPO_DIR/plugins.desc"
    # 日本語説明ファイルから取得
    if test -f $desc_file
        set -l ja (grep "^$name=" $desc_file | head -1 | sed "s/^$name=//")
        if test -n "$ja"
            echo $ja
            return
        end
    end
    # フォールバック: キャッシュの plugin.json から英語説明を取得
    set -l mp_short (marketplace_short $mp)
    for json in $HOME/.claude/plugins/cache/$mp_short/$name/*/.
        set -l pjson (dirname $json)/.claude-plugin/plugin.json
        if test -f $pjson; and command -q python3
            set -l desc (python3 -c "import json; print(json.load(open('$pjson')).get('description',''))" 2>/dev/null)
            if test -n "$desc"
                echo $desc
                return
            end
        end
    end
    # フォールバック: マーケットプレイスから英語説明を取得
    set -l mkt "$HOME/.claude/plugins/marketplaces/$mp_short/.claude-plugin/marketplace.json"
    if test -f $mkt; and command -q python3
        set -l desc (python3 -c "
import json, sys
data = json.load(open('$mkt'))
for p in data.get('plugins', []):
    if p.get('name') == '$name':
        print(p.get('description', ''))
        break
" 2>/dev/null)
        if test -n "$desc"
            echo $desc
            return
        end
    end
    echo ""
end

function git_commit_and_push --argument-names msg
    git -C $REPO_DIR add plugins.conf plugins.desc mcp-servers.json 2>/dev/null
    if git -C $REPO_DIR diff --cached --quiet
        echo "  No changes to commit."
        return 0
    end
    git -C $REPO_DIR commit -m "$msg" 2>&1 | string replace -ra '^' '  '
    echo ""
    if git -C $REPO_DIR remote get-url origin &>/dev/null
        echo "  Pushing..."
        git -C $REPO_DIR push 2>&1 | string replace -ra '^' '  '
    else
        echo "  No remote configured, skipping push."
    end
end

# ---------- 前提チェック ----------

if not command -q claude
    echo "Error: claude CLI not found." >&2
    exit 1
end

# ---------- サブコマンド ----------

set subcmd $argv[1]

switch "$subcmd"

    case add
        if test (count $argv) -lt 2
            echo "Usage: $_ add <plugin-name>[@owner/marketplace-repo]" >&2
            exit 1
        end
        set entry $argv[2]
        set -l parsed (parse_plugin $entry)
        set -l name $parsed[1]
        set -l mp $parsed[2]

        # 重複チェック
        set -l existing_plugins (read_plugins)
        for p in $existing_plugins
            set -l pname (parse_plugin $p)[1]
            if test "$pname" = "$name"
                echo "Plugin '$name' is already in plugins.conf"
                exit 0
            end
        end

        # plugins.conf に追記
        echo $entry >> $CONF
        echo "Added '$entry' to plugins.conf"

        # インストール
        ensure_marketplace $mp
        printf "  Installing %-30s ... " $name
        install_plugin $name $mp
        if test $status -ne 0
            exit 1
        end

        # コミット・プッシュ
        echo ""
        git_commit_and_push "Add plugin: $name"

    case remove
        if test (count $argv) -lt 2
            echo "Usage: $_ remove <plugin-name>" >&2
            exit 1
        end
        set name $argv[2]

        # plugins.conf から削除
        if not grep -q "^$name\b" $CONF
            echo "Plugin '$name' not found in plugins.conf" >&2
            exit 1
        end
        sed -i '' "/^$name\$/d; /^$name@/d" $CONF
        echo "Removed '$name' from plugins.conf"

        # アンインストール
        set -l installed (claude plugin list 2>&1)
        if string match -q "*$name@*" -- $installed
            printf "  Uninstalling %-28s ... " $name
            set output (claude plugin uninstall $name 2>&1)
            if test $status -eq 0
                echo "ok"
            else
                echo "FAILED: $output"
            end
        end

        # コミット・プッシュ
        echo ""
        git_commit_and_push "Remove plugin: $name"

    case list
        echo "Plugins in $CONF:"
        echo ""
        set -l entries (read_plugins)
        set -l installed (claude plugin list 2>&1)
        for entry in $entries
            set -l parsed (parse_plugin $entry)
            set -l name $parsed[1]
            set -l mp $parsed[2]
            set -l mark " "
            if string match -q "*$name@*" -- $installed
                set mark "✔"
            end
            set -l desc (get_plugin_description $name $mp)
            printf "  %s %-24s  %s\n" $mark $name "$desc"
        end

    case sync
        echo "=== Pulling latest ==="
        if git -C $REPO_DIR remote get-url origin &>/dev/null
            git -C $REPO_DIR pull --ff-only 2>&1 | string replace -ra '^' '  '
        else
            echo "  No remote configured, skipping pull."
        end
        echo ""
        # fall through to default install
        set subcmd ""

    case help -h --help
        echo "Usage: $_ [command]"
        echo ""
        echo "Commands:"
        echo "  (none)          Install/update all plugins from plugins.conf"
        echo "  add <plugin>    Add plugin, install, commit & push"
        echo "  remove <plugin> Remove plugin, uninstall, commit & push"
        echo "  list            Show plugins with descriptions"
        echo "  sync            Pull from remote and install all plugins"
        echo "  help            Show this help"
        echo ""
        echo "Plugin format:"
        echo "  plugin-name                  Official marketplace"
        echo "  plugin-name@owner/repo       Specific marketplace"
        exit 0

    case ''
        # デフォルト: 全プラグインインストール（下で処理）

    case '*'
        echo "Unknown command: $subcmd" >&2
        echo "Run '$_ help' for usage." >&2
        exit 1
end

# ---------- 全プラグインインストール（デフォルト / sync 後） ----------

if test "$subcmd" = "" -o "$subcmd" = "sync"
    echo "Claude Code" (claude --version 2>/dev/null)
    echo ""

    set errors 0
    set -l entries (read_plugins)

    # マーケットプレイス登録
    echo "=== Marketplaces ==="
    set -l marketplaces
    for entry in $entries
        set -l mp (parse_plugin $entry)[2]
        if not contains $mp $marketplaces
            set marketplaces $marketplaces $mp
        end
    end
    for mp in $marketplaces
        printf "  %-40s ... " $mp
        ensure_marketplace $mp
        echo "ok"
    end
    echo ""

    # インストール
    echo "=== Plugins ==="
    for entry in $entries
        set -l parsed (parse_plugin $entry)
        set -l name $parsed[1]
        set -l mp $parsed[2]
        printf "  %-36s ... " $name
        install_plugin $name $mp
        or set errors (math $errors + 1)
    end
    echo ""

    # 更新
    echo "=== Updating ==="
    for entry in $entries
        set -l parsed (parse_plugin $entry)
        set -l name $parsed[1]
        set -l mp $parsed[2]
        set -l full "$name@"(marketplace_short $mp)
        printf "  %-36s ... " $name
        set output (claude plugin update $full 2>&1)
        if test $status -eq 0
            if string match -q "*latest*" -- $output
                echo "up to date"
            else
                echo "updated"
            end
        else
            echo "FAILED"
            set errors (math $errors + 1)
        end
    end
    echo ""

    # MCP サーバー設定
    if test -f $MCP_CONFIG
        set -l mcp_content (cat $MCP_CONFIG | string trim)
        if test "$mcp_content" != "{}" -a "$mcp_content" != "{ }" -a "$mcp_content" != ""
            echo "=== MCP Servers ==="
            set target "$HOME/.claude/mcp_servers.json"
            if test -f $target
                if command -q jq
                    set merged (jq -s '.[0] * .[1]' $target $MCP_CONFIG 2>&1)
                    if test $status -eq 0
                        echo $merged > $target
                        echo "  Merged into $target"
                    else
                        echo "  FAILED to merge: $merged"
                        set errors (math $errors + 1)
                    end
                else
                    echo "  Warning: jq not found, skipping MCP merge"
                end
            else
                cp $MCP_CONFIG $target
                echo "  Installed to $target"
            end
            echo ""
        end
    end

    # 結果
    echo "=== Result ==="
    claude plugin list 2>&1
    echo ""

    if test $errors -gt 0
        echo "Completed with $errors error(s)." >&2
        exit 1
    else
        echo "All plugins set up successfully."
    end
end
