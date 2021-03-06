{ pkgs ? import <nixpkgs> { }
}:
{
  emacs_26_2 = pkgs.callPackage ./emacs.nix { version = "26.2"; sha256 = "1sxl0bqwl9b62nswxaiqh1xa61f3hng4fmyc69lmadx770mfb6ag"; withAutoReconf = true; };
  emacs_26_3 = pkgs.callPackage ./emacs.nix { version = "26.3"; sha256 = "14bm73758w6ydxlvckfy9nby015p20lh2yvl6pnrjz0k93h4giq9"; withAutoReconf = true; };
  emacs_28_0 = pkgs.callPackage ./emacs.nix { version = "28"; sha256 = "0idd8k1lsk4qsh6jywm72rrdpcbdirsg5d1wdvsqfv1b336gyb3r"; withAutoReconf = true; };
  # TODO: HEAD
}
