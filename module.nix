{ config, lib, pkgs, ... }:

let cfg = config.services.interception-tools.dual-function-keys;
in with lib; {
  options.services.interception-tools.dual-function-keys = with types; {
    enable = mkEnableOption "Dual Function Keys Plugin";
    package = mkOption {
      type = package;
      default = pkgs.interception-tools-plugins.dual-function-keys;
    };

    timing = {
      tap = mkOption {
        type = ints.positive;
        default = 200;
      };

      doubleTap = mkOption {
        type = ints.positive;
        default = 150;
      };
    };

    mappings = mkOption {
      type = attrsOf (submodule ({ name, ... }: {
        options = {
          key = mkOption {
            type = str;
            default = "KEY_${toUpper name}";
          };

          tap = mkOption { type = str; };

          hold = mkOption { type = str; };
        };
      }));
      default = { };
    };

    dfkConfig = mkOption {
      type = attrsOf (either (attrsOf ints.positive) (listOf (attrsOf str)));
      internal = true;
      visible = false;
    };

    dfkConfigJSON = mkOption {
      type = package;
      internal = true;
      visible = false;
    };
  };

  config = mkIf cfg.enable {
    services.interception-tools = {
      enable = true;
      dual-function-keys = {
        dfkConfig = {
          TIMING = with cfg.timing; {
            TAP_MILLISEC = tap;
            DOUBLE_TAP_MILLISEC = doubleTap;
          };

          MAPPINGS = let
            capitalizeAttrs =
              mapAttrs' (n: v: nameValuePair (toUpper n) (toUpper v));
          in pipe cfg.mappings [ attrValues (map capitalizeAttrs) ];
        };

        dfkConfigJSON = pkgs.writeText "dual-function-keys.json"
          (builtins.toJSON cfg.dfkConfig);
      };

      plugins = [ cfg.package ];
      udevmonConfig = let
        dual-function-keys = "${cfg.package}/bin/dual-function-keys";
        intercept = "${pkgs.interception-tools}/bin/intercept";
        uinput = "${pkgs.interception-tools}/bin/uinput";
      in ''
        - JOB: "${intercept} -g $DEVNODE | ${dual-function-keys} -c ${cfg.dfkConfigJSON} | ${uinput} -d $DEVNODE"
          DEVICE:
            EVENTS:
              EV_KEY: [ ${
                concatMapStringsSep ", " ({ KEY, ... }: KEY)
                cfg.dfkConfig.MAPPINGS
              } ]
      '';
    };
  };
}
