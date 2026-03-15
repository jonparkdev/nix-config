{ pkgs, lib, claude-code-nix, codex-cli-nix, gemini-cli-nix, ... }:
let
  claude = claude-code-nix.packages.${pkgs.system}.default;
  codex = codex-cli-nix.packages.${pkgs.system}.default;
  gemini = gemini-cli-nix.packages.${pkgs.system}.default;
  bin = "${claude}/bin/claude";

  marketplaces = {
    compound-engineering-plugin = {
      url = "https://github.com/EveryInc/compound-engineering-plugin.git";
      plugins = [ "compound-engineering" ];
    };
  };
in
{
  home.packages = [ claude codex gemini ];

  programs.ruler = {
    enable = true;
    rules = {
      general  = ../../ai/ruler/rules/AGENTS.md;
      commits  = ../../ai/ruler/rules/commits.md;
      planning = ../../ai/ruler/rules/planning.md;
      nix-package-management = ../../ai/ruler/rules/nix-package-management.md;
      skills = ../../ai/ruler/rules/skills.md;
      plugins = ../../ai/ruler/rules/plugins.md;
    };
    skillsDir = ../../ai/skills;
    agents = {
      claude = { enable = true; outputPath = ".claude/CLAUDE.md"; };
      codex  = { enable = true; outputPath = ".codex/AGENTS.md"; };
      gemini = { enable = true; outputPath = ".gemini/GEMINI.md"; };
    };
    mcp = {
      enable = true;
      servers = {
        clickup = { url = "https://mcp.clickup.com/mcp"; };
      };
    };
  };

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
