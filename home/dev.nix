{
  ...
}:
{
  programs.granted = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;
    profiles.default.userSettings = {
      "editor.fontFamily" = "'JetbrainsMono Nerd Font' , Menlo, Monaco, 'Courier New', monospace";
      "editor.fontLigatures" = true;
    };
  };
}
