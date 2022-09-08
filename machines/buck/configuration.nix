# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  sops,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  sops = {
    # This will add secrets.yml to the nix store
    # You can avoid this by adding a string to the full path instead, i.e.
    # sops.defaultSopsFile = "/root/.sops/secrets/example.yaml";
    defaultSopsFile = ../../secrets.yaml;
    # This will automatically import SSH keys as age keys
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    # This is using an age key that is expected to already be in the filesystem
    #age.keyFile = "/var/lib/sops-nix/key.txt";
    # This will generate a new key if the key specified above does not exist
    #age.generateKey = true;
    # This is the actual specification of the secrets.
    secrets."pihole/webpassword" = {};
    secrets."spotify/username".owner = "jacob";
    secrets."spotify/password".owner = "jacob";
    secrets."email/gmail/password".owner = "jacob";
    secrets."email/jhink/password".owner = "jacob";
    secrets."wifi/env" = {};
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "buck"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.wireless = {
    enable = true;
    userControlled.enable = true;
    environmentFile = "/run/secrets/wifi/env";
    networks = {
      "@SSID_HOME@" = {
        pskRaw = "@PSKRAW_HOME@";
      };
    };
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  #networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  # List services that you want to enable:
  # Enable sound.
  sound.enable = true;

  #hardware.raspberry-pi."4".fkms-3d.enable = true;

  # Enable touchpad support (enabled default in most desktopManager). services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jacob = {
    isNormalUser = true;
    extraGroups = ["wheel"]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
  };

  security.rtkit.enable = true; # recommended for pipewire

  # List services that you want to enable:
  services = {
    # Enable the OpenSSH daemon.
    openssh.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    syncthing = import ./syncthing.nix;

    # Enable the X11 windowing system. services.xserver.enable = true;
    xserver = {
      enable = true;
      #dpi = 180;
      displayManager = {
        defaultSession = "none+i3";
        autoLogin = {
          enable = true;
          user = "jacob";
        };
        lightdm = {
          enable = true;
          greeter.enable = false;
        };
      };
      libinput = {
        enable = true;
        touchpad = {
          naturalScrolling = true;
          disableWhileTyping = true;
        };
      };
      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
          dmenu #application launcher most people use
          i3status # gives you the default i3 status bar
          i3lock #default i3 screen locker
          i3blocks #if you are planning on using i3blocks over i3status
        ];
      };
    };
  };

  services.acpid.enable = true;
  services.thermald.enable = true;
  services.fwupd.enable = true;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

  nix = {
    maxJobs = 8;
    gc = {
      automatic = true;
    };
    settings.experimental-features = ["nix-command" "flakes"];
  };
}
