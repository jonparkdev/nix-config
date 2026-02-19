{
  ...
}:
{
  home.file.".claude/settings.json".text = builtins.toJSON {
    statusLine = {
      type = "command";
      command = "input=$(cat); cwd=$(echo \"$input\" | jq -r '.workspace.current_dir'); model=$(echo \"$input\" | jq -r '.model.display_name'); remaining=$(echo \"$input\" | jq -r '.context_window.remaining_percentage // empty'); if [[ \"$(uname -s)\" == \"Darwin\" ]]; then ICON=\"\"; else ICON=\"\"; fi; git_branch=\"\"; if git -C \"$cwd\" rev-parse --git-dir > /dev/null 2>&1; then branch=$(git -C \"$cwd\" -c core.useBuiltinFSMonitor=false symbolic-ref --short HEAD 2>/dev/null || git -C \"$cwd\" -c core.useBuiltinFSMonitor=false rev-parse --short HEAD 2>/dev/null); [ -n \"$branch\" ] && git_branch=\" on  $branch\"; fi; dir_name=$(basename \"$cwd\"); context_info=\"\"; [ -n \"$remaining\" ] && context_info=\" | \${remaining}% remaining\"; printf \"%s in %s%s | %s%s\" \"$ICON\" \"$dir_name\" \"$git_branch\" \"$model\" \"$context_info\"";
    };
  };
}
