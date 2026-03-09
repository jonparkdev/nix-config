{ lib, pkgs, config, ... }:
let
  cfg = config.programs.ruler;

  rulerPkg = pkgs.buildNpmPackage rec {
    pname = "ruler";
    version = "0.3.35";
    src = pkgs.fetchFromGitHub {
      owner = "intellectronica";
      repo = "ruler";
      rev = "v${version}";
      hash = "sha256-RKIGTWMjj9vKc6zEeShpP6PiirAR5t2YBAcGxsWUPfE=";
    };
    npmDepsHash = "sha256-JeQeRdMtjKsp4xOE0NcKazBR2dfCwsNfVmIqmRRNNmw=";
    nativeBuildInputs = [ pkgs.makeWrapper ];
    buildPhase = "npm run build";
    installPhase = ''
      mkdir -p $out/bin $out/lib/ruler
      cp -r dist node_modules package.json $out/lib/ruler/
      makeWrapper ${pkgs.nodejs}/bin/node $out/bin/ruler \
        --add-flags "$out/lib/ruler/dist/cli/index.js"
    '';
  };

  tomlFormat = pkgs.formats.toml { };

  rulerToml = tomlFormat.generate "ruler.toml" {
    agents = lib.mapAttrs (_: a: {
      enabled = a.enable;
      output_path = a.outputPath;
    }) cfg.agents;
  };
in
{
  options.programs.ruler = {
    enable = lib.mkEnableOption "ruler AI config fan-out tool";

    package = lib.mkOption {
      type = lib.types.package;
      default = rulerPkg;
      description = "The ruler package to use.";
    };

    projectRoot = lib.mkOption {
      type = lib.types.str;
      default = config.home.homeDirectory;
      description = "Root directory passed to ruler apply. Output paths in agents are relative to this.";
    };

    rules = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = { };
      description = "Rule source files. Attrset of name → path; written to ~/.config/ruler/<name>.md.";
      example = lib.literalExpression ''
        { global = ./rules/global.md; claude = ./rules/claude.md; }
      '';
    };

    agents = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
          };
          outputPath = lib.mkOption {
            type = lib.types.str;
            description = "Output path relative to projectRoot.";
          };
        };
      });
      default = { };
      description = "Target agents and where to write their configs.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.file = lib.mapAttrs' (name: src:
      lib.nameValuePair ".config/ruler/${name}.md" { source = src; }
    ) cfg.rules // {
      ".config/ruler/ruler.toml".source = rulerToml;
    };

    home.activation.rulerApply = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $VERBOSE_ECHO "Applying ruler config to AI agents"
      ${lib.getExe cfg.package} apply \
        --project-root ${lib.escapeShellArg cfg.projectRoot} \
        --config ${config.home.homeDirectory}/.config/ruler/ruler.toml \
        --no-backup \
        --no-gitignore
    '';
  };
}
