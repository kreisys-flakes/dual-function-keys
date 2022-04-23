{ stdenv, lib, libevdev, libyamlcpp, src }:

stdenv.mkDerivation rec {
  pname = "dual-function-keys";
  version = "1.2.0";

  inherit src;

  buildInputs = [ libevdev libyamlcpp ];
  makeFlags = [
    "PREFIX=$(out)"
    "INCS=-I${libevdev}/include/libevdev-1.0"
  ];
  meta = with lib; {
    homepage = "https://gitlab.com/interception/linux/plugins/dual-function-keys";
    description = "Tap for one key, hold for another";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
