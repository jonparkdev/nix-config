{
  user,
  ...
}:
{
  imports = [
    ../../../modules/shared
    ../../../modules/darwin
    ../../../home
  ];

  networking.hostName = "personal-macbook";
  system.primaryUser = user;
}
