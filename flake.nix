{
  description = "NixOS configurations for my machines";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-22.05;
    nixos-hardware = {
      url = github:nixos/nixos-hardware/master;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "https://github.com/nix-community/home-manager/archive/release-22.05.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = github:Mic92/sops-nix;
      # sops-nix uses both -22.05 and -unstable in their flake.
      # As far as I can tell, 22.05 is only used for testing, whereas unstable
      # is used for the tooling. So here, I let both of these follow our
      # nixpkgs input. Note that after NixOS releases, this might break since
      # they may do away with 22.05 at that point.
      # https://github.com/Mic92/sops-nix/blob/master/flake.nix
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-22_05.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixos-hardware,
    home-manager,
    sops-nix,
    ...
  }: let
    system = "x86_64-linux";
    homeManagerConfFor = config: {...}: {
      #nixpkgs.overlays = [ nur.overlay ];
      imports = [config];
    };
    jacobHome = homeManagerConfFor ./home/jacob.nix;
    jacobHomeMod = {
      home-manager.useUserPackages = true;
      home-manager.users.jacob = jacobHome;
    };
  in rec {
    homeManagerConfigurations = {
      jacob = jacobHome;
    };
    nixosConfigurations = {
      # Thinkpad T470 laptop
      buck = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          nixos-hardware.nixosModules.lenovo-thinkpad-t470s
          ./machines/buck/configuration.nix
          home-manager.nixosModules.home-manager
          jacobHomeMod
          sops-nix.nixosModules.sops
        ];
      };
      # ThinkCentre M700 mini-pc (server)
      pedro = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          nixos-hardware.nixosModules.common-pc-hdd
          nixos-hardware.nixosModules.common-cpu-intel-cpu-only
          ./machines/pedro/configuration.nix
          home-manager.nixosModules.home-manager
          jacobHomeMod
          sops-nix.nixosModules.sops
        ];
      };
    };
  };
}
