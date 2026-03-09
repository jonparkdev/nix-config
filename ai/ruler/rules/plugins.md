# Claude Code Plugins

Plugins are managed declaratively in `~/nix-config/home/features/ai.nix` under the `marketplaces` attrset.

When adding a plugin:

1. Find the marketplace git URL and plugin name. The marketplace key must match the git repo name (e.g., `compound-engineering-plugin` from the repo URL).
2. Add or update the entry in `marketplaces`:
   ```nix
   marketplaces = {
     compound-engineering-plugin = {
       url = "https://github.com/EveryInc/compound-engineering-plugin.git";
       plugins = [ "compound-engineering" "new-plugin" ];
     };
   };
   ```
3. Rebuild: `sudo darwin-rebuild switch --flake ~/nix-config#$(scutil --get LocalHostName)`
