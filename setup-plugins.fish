#!/usr/bin/env fish
# Claude Code プラグイン・MCP 一括セットアップスクリプト
# 複数 PC 間で設定を共有するために GitHub リポジトリで管理する

set REPO_DIR (dirname (realpath (status --current-filename)))

# ---------- 設定 ----------

# 公式マーケットプレイス
set marketplace "anthropics/claude-plugins-official"

# インストールするプラグイン（公式マーケットプレイスから）
set plugins \
    feature-dev \
    code-review \
    commit-commands \
    frontend-design \
    security-guidance

# サードパーティマーケットプレイス（追加する場合はここに）
# set third_party_marketplaces \
#     "owner/repo"

# サードパーティプラグイン: {marketplace} {plugin}（追加する場合はここに）
# set third_party_plugins \
#     "owner/repo" "plugin-name"

# MCP サーバー設定ファイル
set MCP_CONFIG "$REPO_DIR/mcp-servers.json"

# ---------- 前提チェック ----------

if not command -q claude
    echo "Error: claude CLI not found." >&2
    echo "  Install: https://docs.anthropic.com/en/docs/claude-code" >&2
    exit 1
end

echo "Claude Code" (claude --version 2>/dev/null)
echo "Repo: $REPO_DIR"
echo ""

set errors 0

# ---------- マーケットプレイス登録 ----------

echo "=== Marketplaces ==="
printf "  %-40s ... " $marketplace
set existing (claude plugin marketplace list 2>&1)
if string match -q "*$marketplace*" -- $existing
    echo "already added"
else
    set output (claude plugin marketplace add $marketplace 2>&1)
    if test $status -eq 0
        echo "ok"
    else
        echo "FAILED"
        echo "    $output"
        set errors (math $errors + 1)
    end
end

# サードパーティマーケットプレイス
# if set -q third_party_marketplaces
#     set i 1
#     while test $i -le (count $third_party_marketplaces)
#         set mp $third_party_marketplaces[$i]
#         printf "  %-40s ... " $mp
#         set existing (claude plugin marketplace list 2>&1)
#         if string match -q "*$mp*" -- $existing
#             echo "already added"
#         else
#             set output (claude plugin marketplace add $mp 2>&1)
#             if test $status -eq 0
#                 echo "ok"
#             else
#                 echo "FAILED"
#                 echo "    $output"
#                 set errors (math $errors + 1)
#             end
#         end
#         set i (math $i + 1)
#     end
# end
echo ""

# ---------- プラグインインストール ----------

echo "=== Plugins (official) ==="
for plugin in $plugins
    printf "  %-36s ... " $plugin
    set installed (claude plugin list 2>&1)
    if string match -q "*$plugin@*" -- $installed
        echo "already installed"
    else
        set output (claude plugin install $plugin 2>&1)
        if test $status -eq 0
            echo "ok"
        else
            echo "FAILED"
            echo "    $output"
            set errors (math $errors + 1)
        end
    end
end
echo ""

# サードパーティプラグイン
# echo "=== Plugins (third-party) ==="
# if set -q third_party_plugins
#     set i 1
#     while test $i -le (count $third_party_plugins)
#         set mp $third_party_plugins[$i]
#         set plugin $third_party_plugins[(math $i + 1)]
#         printf "  %-36s ... " "$plugin@$mp"
#         set installed (claude plugin list 2>&1)
#         if string match -q "*$plugin@*" -- $installed
#             echo "already installed"
#         else
#             set output (claude plugin install "$plugin@$mp" 2>&1)
#             if test $status -eq 0
#                 echo "ok"
#             else
#                 echo "FAILED"
#                 echo "    $output"
#                 set errors (math $errors + 1)
#             end
#         end
#         set i (math $i + 2)
#     end
#     echo ""
# end

# ---------- MCP サーバー設定 ----------

if test -f $MCP_CONFIG
    echo "=== MCP Servers ==="
    set target "$HOME/.claude/mcp_servers.json"

    if test -f $target
        # 既存の設定とマージ（既存キーは上書きしない）
        if command -q jq
            set merged (jq -s '.[0] * .[1]' $target $MCP_CONFIG 2>&1)
            if test $status -eq 0
                echo $merged > $target
                echo "  Merged MCP config into $target"
            else
                echo "  FAILED to merge MCP config: $merged"
                set errors (math $errors + 1)
            end
        else
            echo "  Warning: jq not found, skipping MCP merge"
            echo "  Copy manually: cp $MCP_CONFIG $target"
        end
    else
        cp $MCP_CONFIG $target
        echo "  Installed MCP config to $target"
    end
    echo ""
end

# ---------- プラグイン更新 ----------

echo "=== Updating all plugins ==="
for plugin in $plugins
    set full_name "$plugin@claude-plugins-official"
    printf "  %-36s ... " $plugin
    set output (claude plugin update $full_name 2>&1)
    if test $status -eq 0
        if string match -q "*latest*" -- $output
            echo "up to date"
        else
            echo "updated"
        end
    else
        echo "FAILED"
        echo "    $output"
        set errors (math $errors + 1)
    end
end
echo ""

# ---------- 結果表示 ----------

echo "=== Installed Plugins ==="
claude plugin list 2>&1
echo ""

if test $errors -gt 0
    echo "Completed with $errors error(s)." >&2
    exit 1
else
    echo "All plugins set up successfully."
end
