# To update system.

Run `nixos-rebuild switch --flake .#`

You can specify the name of the system to use if you don't have it set up yet, for example:

```
nixos-rebuild switch --flake .#buck
```

# Secrets

We use [sops-nix](https://github.com/Mic92/sops-nix). All secrets are in `secrets.yaml`. Follow the instructions to add new machines in order to edit secrets, then use `sops secrets.yaml` to view and change the secrets (from an existing machine/user that is already a recipient of the file). Note that you can use the `--add-age` or `--add-pgp` arguments to sops to add more recipients to an existing file, and that _you must do this for both your editing user and the host machine_ if you are setting up a new machine.
