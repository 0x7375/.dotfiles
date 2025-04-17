{ stdenv, fetchFromGitea, ... }:

stdenv.mkDerivation rec {
  pname = "InconsolataNF";
  version = "main";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "0xB0F";
    repo = "fonts";
    rev = version;
    hash = "sha256-j6UudLRVAVZJUon/0AUjZEuFRmj9oA7cCMhD27ooOYI=";
  };

  installPhase = ''
    mkdir -p $out/usr/share/fonts/ttf
    cd InconsolataNF
    mv * $out/usr/share/fonts/ttf/
  '';

  meta = {
    description = "InconsolataNF";
    homepage = "https://codeberg.org/0xB0F/fonts";
  };
}
