{ pkgs, claude-code-nix, ... }:
{
  home.packages = [ claude-code-nix.packages.${pkgs.system}.default ];

  programs.ruler = {
    enable = true;
    rules = {
      general  = ../../ai/ruler/rules/AGENTS.md;
      commits  = ../../ai/ruler/rules/commits.md;
      planning = ../../ai/ruler/rules/planning.md;
      nix-package-management = ../../ai/ruler/rules/nix-package-management.md;
      skills = ../../ai/ruler/rules/skills.md;
    };
    agents = {
      claude = { enable = true; outputPath = ".claude/CLAUDE.md"; };
      codex  = { enable = true; outputPath = ".codex/AGENTS.md"; };
      gemini = { enable = true; outputPath = ".gemini/GEMINI.md"; };
    };
  };
}
