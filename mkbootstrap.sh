#!/usr/bin/env -S ./nix shell nixpkgs#nix-prefetch-git --command bash
# Generate Nix bootstrap package for Zplug
# (c) Karim Vergnes <me@thesola.io>

: ${_ZPLUG_OHMYZSH:=robbyrussell/oh-my-zsh}

first=1

_each_repo() {
    awk 'match($0, /^zplug +"(.*)"/, a) { print a[1] }' < 01-plugins.zsh \
        | grep -Ev '(lib|plugins)/'
    echo $_ZPLUG_OHMYZSH
}

{
  echo "{"
  _each_repo \
  | while IFS= read -r line
    do
      ((first)) || echo ","
      >&2 echo "Prefetching $line..."
      echo "\"$line\":"
      nix-prefetch-git --url https://github.com/$line --leave-dotGit --quiet
      first=0
    done
  echo "}"
} > bootstrap.lock
