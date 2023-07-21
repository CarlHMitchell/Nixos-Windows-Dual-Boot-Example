{ config, lib, pkgs, ... }:
{
    programs.zellij = {
    enable = true;
    # The "Integration" options start zellij when their type of shell is started.
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    settings = {
      copy_command = "wl-copy";
      # TODO: pick your default shell, zellij starts with this, not what it was launched from
      default_shell = "fish";
    };
  };
}
