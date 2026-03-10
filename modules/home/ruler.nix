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

  mcpServerAttrs = lib.mapAttrs (_: s:
    lib.optionalAttrs (s.url != null) { inherit (s) url; }
    // lib.optionalAttrs (s.command != null) { inherit (s) command; }
    // lib.optionalAttrs (s.args != []) { inherit (s) args; }
    // lib.optionalAttrs (s.headers != {}) { inherit (s) headers; }
    // lib.optionalAttrs (s.env != {}) { inherit (s) env; }
  ) cfg.mcp.servers;

  rulerToml = tomlFormat.generate "ruler.toml" ({
    agents = lib.mapAttrs (_: a: {
      enabled = a.enable;
      output_path = a.outputPath;
    }) cfg.agents;
  } // lib.optionalAttrs (cfg.mcp.enable && cfg.mcp.servers != {}) {
    mcp_servers = mcpServerAttrs;
  });
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

    mcp = {
      enable = lib.mkEnableOption "MCP server configuration via ruler";

      servers = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options = {
            url = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Remote MCP server URL (for HTTP/SSE servers).";
            };
            command = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Command to run (for stdio servers).";
            };
            args = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [];
              description = "Arguments for the stdio command.";
            };
            headers = lib.mkOption {
              type = lib.types.attrsOf lib.types.str;
              default = {};
              description = "HTTP headers (for remote servers).";
            };
            env = lib.mkOption {
              type = lib.types.attrsOf lib.types.str;
              default = {};
              description = "Environment variables (for stdio servers).";
            };
          };
        });
        default = {};
        description = "MCP servers to distribute to all configured agents.";
      };
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
