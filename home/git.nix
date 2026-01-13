{
  ...
}:
let
  name = "Jonathan Park";
  email = "accounts@jonpark.dev";
in
{
  programs = {
    git = {
      enable = true;

      settings = {
        user.name = name;
        user.email = email;

        gpg.format = "ssh";
        gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
        init.defaultBranch = "main";
        core = {
          editor = "vim";
          autocrlf = "input";
        };
        pull.rebase = true;
        rebase.autoStash = true;
      };

      ignores = [ "*.swp" ];

      lfs = {
        enable = true;
      };

      signing = {
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICE/pXGITxyPntwU0eIxLlleA0OhtGikNx5T+b6fiVRg";
        signByDefault = true;
      };
    };
  };
}
