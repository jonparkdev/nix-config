{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    # Communication
    slack
  ];

  homebrew = {
    casks = [
      "aws-vpn-client"
    ];
  };
}
