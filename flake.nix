{
  description = "NixOS configurations for my machines";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-22.05;
    nixos-hardware.url = github:nixos/nixos-hardware/master;
    home-manager = {
      #url = "github:nix-community/home-manager";
      url = "https://github.com/nix-community/home-manager/archive/release-22.05.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix.url = github:Mic92/sops-nix;
  };

  outputs = inputs @ { self, nixpkgs, nixos-hardware, home-manager, sops-nix, ... }:
  let
    system = "x86_64-linux";
    homeManagerConfFor = config: { ... }: {
        #nixpkgs.overlays = [ nur.overlay ];
        imports = [ config ];
      };
  in {

    nixosConfigurations = {
      # Thinkpad T470 laptop
      buck = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          nixos-hardware.nixosModules.lenovo-thinkpad-t470s
          ./machines/buck/configuration.nix
          home-manager.nixosModules.home-manager {
            home-manager.useUserPackages = true;
            home-manager.users.jacob = homeManagerConfFor ./home/jacob.nix;
          }
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
          home-manager.nixosModules.home-manager {
            home-manager.useUserPackages = true;
            home-manager.users.jacob = homeManagerConfFor ./home/jacob.nix;
          }
          sops-nix.nixosModules.sops
        ];
      };
    };
  };
}
