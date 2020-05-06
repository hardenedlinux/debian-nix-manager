{ config, lib, pkgs, ... }:
let

  harbian-audit-git = pkgs.fetchFromGitHub {
     owner = "hardenedlinux";
     repo = "harbian-audit";
     rev = "7bee47fbf1be9024595c2783fc2a5becfc692394";
     sha256 = "0v0ypja37g0q2qp9pp6c66wgb2bk5v7s5gvjfhic7p99vfkz2klf";
  };

  harbian-audit = pkgs.writeScriptBin "hardening.sh" ''
    /usr/bin/sudo  cp ${harbian-audit-git}/etc/default.cfg /etc/default/cis-hardening
   /usr/bin/sudo sed -i "s#CIS_ROOT_DIR=.*#CIS_ROOT_DIR='${harbian-audit-git}'#" /etc/default/cis-hardening
   /usr/bin/sudo ${harbian-audit-git}/bin/hardening.sh --audit-all
  '';

in

{
  home.packages = with pkgs;[ harbian-audit
                            ];
}
