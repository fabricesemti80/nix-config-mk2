{
  # NOTE: the args not used in this file CAN NOT be removed!
  # because haumea pass argument lazily,
  # and these arguments are used in the functions like `mylib.nixosSystem`, `mylib.colmenaSystem`, etc.
  inputs,
  lib,
  mylib,
  myvars,
  system,
  genSpecialArgs,
  ...
} @ args: let
  # CORAX
  name = "corax";
  tags = ["corax" "homelab-network"];
  ssh-user = "root";

  modules = {
    nixos-modules =
      (map mylib.relativeToRoot [
        # common
        "secrets/nixos.nix"
        "modules/nixos/server/server.nix"
        # "modules/nixos/server/kubevirt-hardware-configuration.nix" # FIXME: VM is not on kubervirt
        "modules/nixos/server/proxmox-hardware-configuration.nix" # NOTE: VM is on proxmox
        # host specific
        "hosts/${name}"
      ])
      ++ [
      ];
  };

  systemArgs = modules // args;
in {
  nixosConfigurations.${name} = mylib.nixosSystem systemArgs;

  colmena.${name} =
    mylib.colmenaSystem (systemArgs // {inherit tags ssh-user;});

  packages.${name} = inputs.self.nixosConfigurations.${name}.config.formats.kubevirt;
}
