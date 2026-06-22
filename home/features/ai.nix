{ pkgs, lib, claude-code-nix, codex-cli-nix, ... }:
let
  claude = claude-code-nix.packages.${pkgs.system}.default;
  codex = codex-cli-nix.packages.${pkgs.system}.default;
  bin = "${claude}/bin/claude";

  marketplaces = {
    addy-agent-skills = {
      url = "https://github.com/addyosmani/agent-skills.git";
      plugins = [ "agent-skills" ];
    };
  };
in
{
  home.packages = [ claude codex ];

  home.activation.claudePlugins = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: mp: ''
      ${bin} plugin marketplace add ${mp.url} 2>/dev/null || true
      ${lib.concatMapStringsSep "\n" (p: ''
        ${bin} plugin install ${p}@${name} 2>/dev/null || true
        ${bin} plugin update ${p}@${name} 2>/dev/null || true
        ${bin} plugin enable ${p}@${name} 2>/dev/null || true
      '') mp.plugins}
    '') marketplaces)}
  '';
}
