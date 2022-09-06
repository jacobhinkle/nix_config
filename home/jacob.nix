{ config, pkgs, ... }:
{
  imports = [
    ({ lib, ...}: {
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "zoom"
      ];
    })
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    username = "jacob";
    homeDirectory = "/home/jacob";

    keyboard = {
      layout = "us";
      options = [ "caps:swapescape" "ctrl:ralt_rctrl" ];
    };

    packages = with pkgs; [
      age
      bitwarden
      chromium
      feh
      file
      #freecad
      #gnumake
      hack-font
      inconsolata
      libreoffice
      logseq
      mupdf
      #nyxt
      #openscad
      #pandoc
      pavucontrol
      scli
      scrot
      signal-desktop
      sops
      spotify-tui
      sxiv
      #texlive.combined.scheme-full
      xclip
      zoom-us
    ];

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "22.05";
  };

  accounts.email = {
    accounts.gmail = {
      address = "jacob.hinkle@gmail.com";
      passwordCommand = "${pkgs.coreutils}/bin/cat /run/secrets/email/gmail/password";
      flavor = "gmail.com";
      mbsync = {
        enable = false;
        create = "maildir";
      };
      notmuch.enable = false;
      primary = true;
      realName = "Jacob Hinkle";
    };
    accounts.jhink = {
      address = "jacob.hinkle@jhink.org";
      imap.host = "mail.privateemail.com";
      smtp.host = "mail.privateemail.com";
      flavor = "plain";
      userName = "jacob.hinkle@jhink.org";
      passwordCommand = "${pkgs.coreutils}/bin/cat /run/secrets/email/jhink/password";
      mbsync = {
        enable = true;
        create = "maildir";
      };
      notmuch.enable = true;
      realName = "Jacob Hinkle";
    };
  };

  programs = {
    bat = {
      enable = true;
    };
    direnv = {
      enable = true;
      enableZshIntegration = true;
    };
    firefox = {
      enable = true;
      package = pkgs.firefox.override {
        cfg = {
          enableTridactylNative = true;
        };
      };
    };
    git = {
      enable = true;
      userName = "Jacob Hinkle";
      userEmail = "jacob.hinkle@jhink.org";
      lfs.enable = true;
      delta.enable = true;
    };
    htop = {
      enable = true;
    };
    kitty = {
      enable = true;
      font = {
        name = "Hack";
        size = 16;
      };
    };
    mbsync = {
      enable = true;
    };
    neovim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [
        vim-nix
      ];
    };
    qutebrowser = {
      enable = true;
      extraConfig = ''
        config.pdfjs = True
        c.colors.webpage.preferred_color_scheme = 'dark'

        # Redirect to old.reddit.com
        # from: https://www.reddit.com/r/qutebrowser/comments/n90y93/a_simple_script_to_convert_reddit_links_to/
        import qutebrowser.api.interceptor

        def rewrite(request: qutebrowser.api.interceptor.Request):
          if request.request_url.host() == 'www.reddit.com':
              request.request_url.setHost('old.reddit.com')
              try:
                  request.redirect(request.request_url)
              except:
                  pass

        qutebrowser.api.interceptor.register(rewrite)
      '';
      keyBindings = {
        normal = {
          "<Shift-J>" = "tab-prev";
          "<Shift-K>" = "tab-next";
        };
      };
    };
    rbw = {
      enable = true;
      settings.email = "jacob.hinkle@gmail.com";
    };
    ssh = {
      enable = true;
      matchBlocks = {
        login1 = {
          hostname = "login1.ornl.gov";
          user = "4jh";
        };
        lucky = {
          hostname = "lucky.ornl.gov";
          user = "4jh";
          proxyJump = "login1";
        };
        murdock = {
          hostname = "murdock.ornl.gov";
          user = "4jh";
          proxyJump = "login1";
        };
      };
    };
    tmux = import ./tmux.nix;
    zsh = {
      enable = true;
      enableSyntaxHighlighting = true;
      shellAliases = {
        vim = "nvim";
      };
      sessionVariables = {
        EDITOR = "nvim";
      };
      oh-my-zsh = {
        enable = true;
        plugins = [
         "direnv"
         "git"
         "sudo"
         "vi-mode"
        ];
        theme = "michelebologna";  # nice clean theme that shows jobs
      };
      # michelebologna theme doesn't have an RPROMPT, but I like the one from the clean theme
      initExtra = ''
        RPROMPT='[%*]'
      '';
    };
  };

  services = {
    spotifyd = {
      enable = true;
      settings = {
        global = {
          username_cmd = "${pkgs.coreutils}/bin/cat /run/secrets/spotify/username";
          password_cmd = "${pkgs.coreutils}/bin/cat /run/secrets/spotify/password";
          backend = "pulseaudio";
          device = "pipewire";
          device_name = "pedro";
          device_type = "computer";
        };
      };
    };
    syncthing = {
      enable = true;
      # cause the tray command to wait for the service and tray manager to start
      #extraOptions = [ "--wait" ];
      tray.enable = false;
    };
    unclutter = {
      enable = true;
    };
  };

  xsession = {
    enable = true;
    windowManager.i3 = {
      enable = true;
      config = import ./i3.nix pkgs;
    };
  };
}
