{lib}: {
  username = "fs";
  userfullname = "Fabrice Semti";
  useremail = "fabrice@fabricesemti.com";
  networking = import ./networking.nix {inherit lib;};
}
