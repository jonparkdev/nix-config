{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    # Productivity
    obsidian
  ];

  homebrew = {
    casks = [
      "hammerspoon"
      "protonvpn"
    ];
  };
}
