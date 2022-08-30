# Edit this configuration file to define what should be installed on your system.  Help is available in the configuration.nix(5) man page and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, options, sops, ... }:

{ imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration-zfs.nix
    ];

  sops = {
    # This will add secrets.yml to the nix store
    # You can avoid this by adding a string to the full path instead, i.e.
    # sops.defaultSopsFile = "/root/.sops/secrets/example.yaml";
    defaultSopsFile = ../../secrets.yaml;
    # This will automatically import SSH keys as age keys
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
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
  };

  boot = {
    # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
    loader = {
        # Enables the generation of /extlinux/extlinux.conf grub.enable = true;
	#grub.version = 2; grub.device = "/dev/sda"; grub.efiSupport = true;
	systemd-boot.enable = true;
    };
  
    # ZFS settings
    initrd.availableKernelModules = [ "usbhid" "usb_storage" ]; initrd.supportedFilesystems = [ "zfs" ]; # boot from zfs supportedFilesystems = [ "zfs" ]; zfs.devNodes = "/dev/";
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  networking = {
    hostName = "pedro"; # Define your hostname.
    # networking.hostId is required for ZFS
    hostId = "d9aef7b3";

    # The global useDHCP flag is deprecated, therefore explicitly set to false here. Per-interface useDHCP will be mandatory in the future, so this generated config replicates the default behaviour.
    useDHCP = false;
    interfaces.eth0.useDHCP = true;
    interfaces.wlan0.useDHCP = true;
    wireless = {
      enable = true;
      userControlled.enable = true;
      environmentFile = "/run/secrets/wifi.env";
      networks = {
        "@SSID_HOME@" = {
          pskRaw = "@PSKRAW_HOME@";
        };
      };
    };
    firewall = {
      allowedTCPPorts = [
        8384 22000  # syncthing
        8080 8443 6789 8880 8843 27117  # unifi controller: https://help.ui.com/hc/en-us/articles/218506997-UniFi-Network-Required-Ports-Reference
        53 8088  # pihole
        3000  # gitea
      ];
      allowedUDPPorts = [
        22000 21027  # syncthing
        3478 5514 10001 1900 123 # unifi
        53  # pihole
      ];
      allowedUDPPortRanges = [
        { from = 5656; to = 5699; }  # unifi
      ];
    };
    timeServers = [ "192.168.88.1" ] ++ options.networking.timeServers.default;
  };

  hardware.video.hidpi.enable = false;
  hardware.enableRedistributableFirmware = true;
  #hardware.pulseaudio = {
    #enable = true;
    #extraModules = [ pkgs.pulseaudio-modules-bt ];
    #package = pkgs.pulseaudioFull;
  #};
  hardware.bluetooth.enable = false;
  services.blueman.enable = false;
  

  # Enable CUPS to print documents.
  services.printing.enable = false;

  # Enable sound.
  sound.enable = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jacob = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
  };

  # List packages installed in system profile. To search, run: $ nix search wget
  environment.systemPackages = with pkgs; [ vim git wget ];

  #environment.variables = {
    #GDK_SCALE = "2";
    #GDK_DPI_SCALE = "0.5";
    #_JAVA_OPTIONS = "-Dsun.java2d.uiScale=2";
  #};

  # Some programs need SUID wrappers, can be configured further or are started in user sessions. programs.mtr.enable = true; programs.gnupg.agent = {
  #   enable = true; enableSSHSupport = true;
  # };

  security.rtkit.enable = true;  # recommended for pipewire

  virtualisation.oci-containers.containers = let
    serverIP = "192.168.88.21";
  in {
    pihole = {
      image = "pihole/pihole:2022.07.1";
      ports = [
        "${serverIP}:53:53/tcp"
        "${serverIP}:53:53/udp"
        "8088:80"
        "4438:443"
      ];
      environment = {
        TZ = "America/New_York";
        ServerIP = serverIP;
        WEBPASSWORD_FILE = "/run/secrets/pihole/webpassword";
      };
      #extraDockerOptions = [
        ##"--cap-add=NET_ADMIN"
        #"--dns=127.0.0.1"
        #"--dns=1.1.1.1"
      #];
      volumes = [
        "/serverdata/pihole/etc/pihole:/etc/pihole"
        "/serverdata/pihole/etc/dnsmasq.d:/etc/dnsmasq.d"
        "/run/secrets/pihole:/run/secrets/pihole"
      ];
      #workdir = "/serverdata/pihole/etc/pihole";
    };
  };

  # List services that you want to enable:
  services = {
    chrony.enable = true;

    gitea = {
      enable = true;
      lfs = {
        enable = true;
        contentDir = "/serverdata/gitea/lfs_content";
      };
      stateDir = "/serverdata/gitea";
    };

    # Enable the OpenSSH daemon.
    openssh.enable = true;

    paperless = {
      enable = true;
    };

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

    unifi = {
      enable = true;
      openFirewall = true;
      unifiPackage = pkgs.unifiStable;
    };

    # Enable the X11 windowing system.
    xserver = {
      enable = true;
      dpi = 180;
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
      layout = "us";
      libinput.enable = true;
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

    # ZFS services
    zfs = {
      trim.enable = true;
      autoScrub = {
        enable = true;
        pools = [ "rpool" ];
      };
      autoSnapshot = {
        enable = true;
        frequent = 8;
        monthly = 1;
      };
    };
  };
  
  # Due to bug in home assistant, this workaround is suggested temporarily as of May 6, 2022
  # https://github.com/nix-community/home-manager/issues/2942#issuecomment-1119760100
  #nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = ( pkg: true );
  
  powerManagement.cpuFreqGovernor = "ondemand";

  # This value determines the NixOS release from which the default settings for stateful data, like file locations and database versions on your system were taken. It‘s perfectly fine and recommended to leave this value at the 
  # release version of the first install of this system. Before changing this value read the documentation for this option (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}

