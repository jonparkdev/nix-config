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

  networking.hostName = "work-macbook";
  system.primaryUser = user;
}
