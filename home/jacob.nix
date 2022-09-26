{
  config,
  pkgs,
  ...
}: {
  imports = [
    ({lib, ...}: {
      nixpkgs.config.allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
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
      options = ["caps:swapescape" "ctrl:ralt_rctrl"];
    };

    packages = with pkgs; [
      age
      bitwarden
      chromium
      fd
      feh
      file
      #freecad
      fzf
      #gnumake
      hack-font
      jq
      inconsolata
      libreoffice
      logseq
      mupdf
      #nyxt
      #openscad
      #pandoc
      pavucontrol
      ripgrep
      scli
      scrot
      signal-desktop
      sops
      speedcrunch
      spotify-tui
      sxiv
      #texlive.combined.scheme-full
      xclip
      zathura
      zoom-us
    ];

    sessionVariables = {
      QT_ENABLE_HIGHDPI_SCALING = 1;
    };

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

  xdg = {
    enable = true;
    mimeApps = {
      enable = true;
      associations.added = {
        "application/pdf" = ["zathura.desktop"];
      };
      defaultApplications = {
        "application/pdf" = ["zathura.desktop"];
      };
    };
  };

  accounts.email.accounts = {
    gmail = {
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
    jhink = {
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
    bat.enable = true;
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
      difftastic = {
        enable = true;
        background = "dark";
      };
      aliases = {
        ci = "commit";
        lg = "log --pretty=format:\"%C(magenta)%h%Creset -%C(red)%d%Creset %s %C(dim green)(%cr) [%an]\" --abbrev-commit -30";
        s = "status";
      };
    };
    htop.enable = true;
    kitty = {
      enable = true;
      font = {
        name = "Hack";
        size = 24;
      };
    };
    lazygit.enable = true;
    mbsync.enable = true;
    neovim = {
      enable = true;
      extraConfig = ''
        set tabstop=4
        set softtabstop=4 " enables backspacing, etc
        set shiftwidth=4
        set expandtab
        set tw=80

        set bs=2		" allow backspacing over everything in insert mode
        set ai			" always set autoindenting on

        set number relativenumber
        set colorcolumn=100
      '';
      plugins = with pkgs.vimPlugins; [
        #context-vim
        #ctrlp
        #fzf
        #gundo
        python-mode
        #telescope-nvim
        #telescope-fzf-native-nvim
        #nvim-treesitter
        vim-nix
      ];
      vimAlias = true;
    };
    #notmuch.enable = true;
    qutebrowser = import ./qutebrowser.nix;
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
    xmobar = {
      enable = true;
      extraConfig = builtins.readFile ./xmobarrc;
    };
    zsh = {
      enable = true;
      enableSyntaxHighlighting = true;
      shellAliases = {
        lg = "lazygit";
        vim = "nvim";
      };
      sessionVariables = {
        EDITOR = "nvim";
        FZF_DEFAULT_OPTS = "--layout=reverse --inline-info --height=40% --border";
      };
      oh-my-zsh = {
        enable = true;
        plugins = [
          "direnv"
          "git"
          "sudo"
          "vi-mode"
          "fzf"
        ];
        theme = "michelebologna"; # nice clean theme that shows jobs
      };
      initExtra = ''
        # michelebologna theme doesn't have an RPROMPT, but I like the one from
        # the clean theme
        RPROMPT='[%*]'

        # wrap the fzf command with some killable helpers
        function vif() {
            local fname
            fname=$(fzf) || return
            vim "$fname"
        }

        function fcd() {
            local dirname
            dirname=$(find -type d | fzf) || return
            cd "$dirname"
        }
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
      enable = false;
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
    windowManager = {
      i3 = {
        enable = false;
        config = import ./i3.nix pkgs;
      };
      xmonad = {
        enable = true;
        enableContribAndExtras = true;
        extraPackages = haskellPackages:
          with haskellPackages; [
            #dbus
            #List
            #monad-logger
            xmonad
            xmonad-contrib
          ];
        config = ./xmonad.hs;
      };
    };
  };
}
