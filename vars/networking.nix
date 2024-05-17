{lib}: rec {
  mainGateway = "10.0.20.1"; # main router
  # use suzi as the default gateway
  # it's a subrouter with a transparent proxy #TODO: in my setup gw = router
  defaultGateway = "10.0.20.1";
  nameservers = [
    "208.67.220.220" # OpenDNS 1
    "208.67.222.222" # OpenDNS 2
    "1.1.1.1" # Cloudflare
  ];
  prefixLength = 24;

  hostsAddr = {
    # # ============================================
    # # Homelab's Physical Machines (KubeVirt Nodes)
    # # ============================================
    # kubevirt-shoryu = {
    #   iface = "eno1";
    #   ipv4 = "192.168.5.181";
    # };
    # kubevirt-shushou = {
    #   iface = "eno1";
    #   ipv4 = "192.168.5.182";
    # };
    # kubevirt-youko = {
    #   iface = "eno1";
    #   ipv4 = "192.168.5.183";
    # };

    # ============================================
    # Other VMs and Physical Machines
    # ============================================
    # ai = {
    #   # Desktop PC
    #   iface = "enp5s0";
    #   ipv4 = "192.168.5.100";
    # };
    magnus = {
      # VM
      iface = "ens18";
      ipv4 = "10.0.20.201";
    };
    fulgrim = {
      # VM
      iface = "ens18";
      ipv4 = "10.0.20.202";
    };
    corax = {
      # VM
      iface = "ens18";
      ipv4 = "10.0.20.203";
    };
    # kana = {
    #   # VM
    #   iface = "enp2s0";
    #   ipv4 = "192.168.5.103";
    # };
    # nozomi = {
    #   # LicheePi 4A's wireless interface - RISC-V
    #   iface = "wlan0";
    #   ipv4 = "192.168.5.104";
    # };
    # yukina = {
    #   # LicheePi 4A's wireless interface - RISC-V
    #   iface = "wlan0";
    #   ipv4 = "192.168.5.105";
    # };
    # chiaya = {
    #   # VM
    #   iface = "enp2s0";
    #   ipv4 = "192.168.5.106";
    # };
    # suzu = {
    #   # Orange Pi 5 - ARM
    #   iface = "end1";
    #   ipv4 = "192.168.5.107";
    # };
    # rakushun = {
    #   # Orange Pi 5 - ARM
    #   # RJ45 port 1 - enP4p65s0
    #   # RJ45 port 2 - enP3p49s0
    #   iface = "enP4p65s0";
    #   ipv4 = "192.168.5.179";
    # };
    # suzi = {
    #   iface = "enp2s0"; # fake iface, it's not used by the host
    #   ipv4 = "192.168.5.178";
    # };
    # mitsuha = {
    #   iface = "enp2s0"; # fake iface, it's not used by the host
    #   ipv4 = "192.168.5.177";
    # };

    #   # ============================================
    #   # Kubernetes Clusters
    #   # ============================================
    #   k3s-prod-1-master-1 = {
    #     # VM
    #     iface = "enp2s0";
    #     ipv4 = "192.168.5.108";
    #   };
    #   k3s-prod-1-master-2 = {
    #     # VM
    #     iface = "enp2s0";
    #     ipv4 = "192.168.5.109";
    #   };
    #   k3s-prod-1-master-3 = {
    #     # VM
    #     iface = "enp2s0";
    #     ipv4 = "192.168.5.110";
    #   };
    #   k3s-prod-1-worker-1 = {
    #     # VM
    #     iface = "enp2s0";
    #     ipv4 = "192.168.5.111";
    #   };
    #   k3s-prod-1-worker-2 = {
    #     # VM
    #     iface = "enp2s0";
    #     ipv4 = "192.168.5.112";
    #   };
    #   k3s-prod-1-worker-3 = {
    #     # VM
    #     iface = "enp2s0";
    #     ipv4 = "192.168.5.113";
    #   };

    #   k3s-test-1-master-1 = {
    #     # KubeVirt VM
    #     iface = "enp2s0";
    #     ipv4 = "192.168.5.114";
    #   };
    #   k3s-test-1-master-2 = {
    #     # KubeVirt VM
    #     iface = "enp2s0";
    #     ipv4 = "192.168.5.115";
    #   };
    #   k3s-test-1-master-3 = {
    #     # KubeVirt VM
    #     iface = "enp2s0";
    #     ipv4 = "192.168.5.116";
    #   };
  };

  hostsInterface =
    lib.attrsets.mapAttrs
    (
      key: val: {
        interfaces."${val.iface}" = {
          useDHCP = false;
          ipv4.addresses = [
            {
              inherit prefixLength;
              address = val.ipv4;
            }
          ];
        };
      }
    )
    hostsAddr;

  ssh = {
    # define the host alias for remote builders
    # this config will be written to /etc/ssh/ssh_config
    # ''
    #   Host ruby
    #     HostName 192.168.5.102
    #     Port 22
    #
    #   Host kana
    #     HostName 192.168.5.103
    #     Port 22
    #   ...
    # '';
    extraConfig =
      lib.attrsets.foldlAttrs
      (acc: host: val:
        acc
        + ''
          Host ${host}
            HostName ${val.ipv4}
            Port 22
        '')
      ""
      hostsAddr;

    # define the host key for remote builders so that nix can verify all the remote builders
    # this config will be written to /etc/ssh/ssh_known_hosts
    knownHosts =
      # Update only the values of the given attribute set.
      #
      #   mapAttrs
      #   (name: value: ("bar-" + value))
      #   { x = "a"; y = "b"; }
      #     => { x = "bar-a"; y = "bar-b"; }
      lib.attrsets.mapAttrs
      (host: value: {
        hostNames = [host hostsAddr.${host}.ipv4];
        publicKey = value.publicKey;
      })
      {
        corax.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIETObXOI0LG+w5LilczO0eNLfzrWa6+XGVJgliP9PBNc root@corax";
        fulgrim.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPyY4dTn8hxAyeEdhppTRpM3NX2rJAqaeu8IZBXPi/3t root@fulgrim";
        magnus.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMsfCPvjBLmDj6JJp/1m6dpBeMfunCIZwsQTBO3Hjc7 root@magnus";
      };
  };
}
