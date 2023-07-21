{ config, lib, pkgs, ... }:
{
  programs.git = {
    enable = true;
    userName = "Carl Mitchell";
    userEmail = "carl.mitchell@gomotive.com";
    signing.key = "113CCD2515E94ACBF1EE6760B689787BCAB5EF29";
    signing.signByDefault = true;
    aliases = {
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
      precommit = "!f() { git diff --cached --diff-algorithm=minimal -w; }; f";
      fpm = "!f() { git checkout master && git fetch && git pull --ff-only; }; f";
      fp = "!f() { git fetch && git pull --ff-only; }; f";
      prune-branches = ''!f() { git fetch -p && git checkout -q master && git for-each-ref refs/heads/ "--format=%(refname:short)" | while read branch; do mergeBase=$(git merge-base master $branch) && [[ $(git cherry master $(git commit-tree $(git rev-parse "$branch^{tree}") -p $mergeBase -m _)) == "-"* ]] && git branch -D $branch; done }; f'';
    };
    difftastic = {
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
