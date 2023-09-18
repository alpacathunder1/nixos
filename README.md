# nixos-Desktop

My Desktop NixOS config

Running on an Intel NUC8BEB.

I'm currently using [nixfmt](https://github.com/serokell/nixfmt) to format my code.  I tried integrating it into a git pre-commit hook, but git seemed to use the version *before* the script was ran for the commit.

Instead--I'm just going to try and call the included `nix-format.sh` script before committing, and find a more elegant solution later (famous last words, lol.)
