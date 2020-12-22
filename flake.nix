{
  description = "A very basic flake";

  inputs = {
    src = {
      url =
        "https://gitlab.com/interception/linux/plugins/dual-function-keys/-/archive/1.2.0/dual-function-keys-1.2.0.tar.gz";
      flake = false;
    };
    utils.url = "github:kreisys/flake-utils";
  };

  outputs = { self, nixpkgs, src, utils }:
    utils.lib.simpleFlake {
      inherit nixpkgs;
      name = "dual-function-keys";
      systems = [ "x86_64-linux" ];
      overlay = final: prev: {
        interception-tools-plugins = prev.interception-tools-plugins // {
          dual-function-keys = final.callPackage ./package.nix { inherit src; };
        };
      };

      packages = { interception-tools-plugins }: rec {
        inherit (interception-tools-plugins) dual-function-keys;
        defaultPackage = dual-function-keys;
      };

      nixosModule = { pkgs, ... }: {
        imports = [ ./module.nix ];
        nixpkgs.overlays = [ self.overlay ];
      };

      nixosModules = {
        caps-to-ctrl-or-esc = {
          imports = [ self.nixosModule ];
          services.interception-tools.dual-function-keys = {
            enable = true;
            mappings.capslock = {
              tap = "KEY_ESC";
              hold = "KEY_LEFTCTRL";
            };
          };
        };

        enter-to-ctrl-or-enter = {
          imports = [ self.nixosModule ];
          services.interception-tools.dual-function-keys = {
            enable = true;
            mappings.enter = {
              tap = "KEY_ENTER";
              hold = "KEY_RIGHTCTRL";
            };
          };
        };
      };
    };
}
