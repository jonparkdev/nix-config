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
    brews = [
      "beads"
    ];

    casks = [
      "hammerspoon"
      "protonvpn"
    ];
  };
}
