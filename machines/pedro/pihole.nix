serverIP :
{
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
    FTLCONF_LOCAL_IPV4 = serverIP;
    WEBPASSWORD_FILE = "/run/secrets/pihole/webpassword";
    TEMPERATUREUNIT = "f";
    REPLY_ADDR4 = serverIP;
  };
  volumes = [
    "/serverdata/pihole/etc/pihole:/etc/pihole"
    "/serverdata/pihole/etc/dnsmasq.d:/etc/dnsmasq.d"
    "/run/secrets/pihole:/run/secrets/pihole"
  ];
  extraOptions = [
    "--no-hosts"  # do not populate internal /etc/hosts with container host's
  ];
}
