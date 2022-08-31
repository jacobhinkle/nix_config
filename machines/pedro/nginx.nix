{
  enable = true;
  recommendedProxySettings = true;
  virtualHosts = let
    simpleProxy ip {
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        proxy_buffering off;
      '';
      locations."/" = {
        proxyPass = "http://[::1]:${ip}";
        proxyWebsockets = true;
      };
    }
  in {
    "home.jhink.org" = simpleProxy 8123;
    "git.jhink.org" = simpleProxy 3000;
    "paperless.jhink.org" = simpleProxy 8000;
    "vault.jhink.org" = simpleProxy 8081;
  };
}
