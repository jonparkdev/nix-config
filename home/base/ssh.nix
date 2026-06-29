{
  ...
}:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    extraConfig = ''IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"'';

    matchBlocks."*" = {
      forwardAgent = false;
      addKeysToAgent = "no";
      compression = false;
      serverAliveInterval = 0;
      serverAliveCountMax = 3;
      hashKnownHosts = false;
      userKnownHostsFile = "~/.ssh/known_hosts";
      controlMaster = "no";
      controlPath = "~/.ssh/master-%r@%n:%p";
      controlPersist = "no";
    };

    # theinfra-rc CM4 node on the Turing Pi 2 (node 3). Lets you `ssh cm4`.
    # Auth is the "Turing Pi" key held in 1Password (IdentityAgent above).
    # NOTE: 10.10.255.208 is a DHCP lease — set a reservation on the router (or a
    # static IP on the node) if you want this to stay stable.
    matchBlocks.cm4 = {
      hostname = "10.10.255.208";
      user = "jonpark";
    };
  };
}
