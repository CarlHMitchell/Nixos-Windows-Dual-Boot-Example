{ config, lib, pkgs, ... }:
{
  programs.git = {
    enable = true;
    userName = "NAME"; # TODO: Add your name
    userEmail = "EMAIL"; # TODO: Add your email
    signing.key = "KEY ID HERE"; # TODO: Add your GPG Key ID here
    signing.signByDefault = true;
    aliases = {
      # Mostly from [Humane Git Aliases](https://gggritso.com/human-git-aliases). 
      unstage = "reset -q HEAD --";
      discard = "checkout --";
      nevermind = "!f() { git reset --hard HEAD^ && git clean -d -f; }; f";
      uncommit = "reset --mixed HEAD~";
      summary = "status -u -s";
      graph = "log --graph -10 --branches --remotes --tags  --format=format:'%Cgreen%h %Creset• %<(75,trunc)%s (%cN, %ar) %Cred%d' --date-order";
      history = "log -10 --format=format:'%Cgreen%h %Creset%s (%aN, %ar)'";
      log-all = "log --all --graph --oneline --decorate";
      new-branch = "checkout -b";
      rename-branch = "branch -m";
      delete-branch = "branch -D";
      branches = "branch";
      recent-branches = "branch -a --sort=committerdate";
      merge-from = "merge";
      rebase-to = "rebase";
      tags = "tag";
      stashes = "stash list";
      remotes = "remote -v";
      unmerged = "branch --no-merged";
      untrack = "rm -r --cached";
      amend = "commit --amend --no-edit";
      amend-message = "commit --amend";
      current-branch = "rev-parse --abbrev-ref HEAD";
      aliases = "!git config --get-regexp ^alias\\. | sed -e s/^alias\\.// -e s/\\ /\\:\\ /";
      axe = "log --reverse -p -w -S";
      clean-untracked = "clean -d -f -x";
      force-pull-master = "!f() { git fetch && git reset --hard origin/master; }; f";
      force-pull-main = "!f() { git fetch && git reset --hard origin/main; }; f";
      sha = "rev-parse HEAD";
      ssha = "rev-parse --short HEAD";
      diff-staged = "!f() { git diff --cached --diff-algorithm=minimal -w; }; f";
    };
    difftastic = { # TODO: Remove this if you're not installing difftastic
      enable = true;
      background = "dark";
    };
    extraConfig = {
      core = {
        autoclrf = "input";
      };
      rerere = {
        enabled = true;
      };
      init.defaultBranch = "main";
    };
    lfs.enable = true;
    ignores = [
      # TODO: Add or remove global .gitignore entries here
      # OS generated files
      ".DS_Store"
      ".DS_Store?"
      "._*"
      ".Spotlight-V100"
      ".Trashes"
      "ehthumbs.db"
      "Thumbs.db"
      ".directory"

      # IDE files #
      ".idea/"
      ".vscode/"
      ".settings/"

      # CMake outputs #
      "CMakeFiles/"
      #*.cmake
      "progress.marks"
      "*.dir"
      "*.cbp"
      "Makefile"
      "CMakeCache.txt"
      "compile_commands.json"

      # Compiled source #
      "*.com"
      "*.class"
      "*.dll"
      "*.exe"
      "*.o"
      "*.so"
      "*.a"

      "~/.cache/*"
    ];
  };
}
