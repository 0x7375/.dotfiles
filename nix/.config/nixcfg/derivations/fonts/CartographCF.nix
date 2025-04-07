{ stdenv, fetchFromGitea, ... }:

stdenv.mkDerivation rec {
  pname = "CartographCF";
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
    cd CartographCF
    mv * $out/usr/share/fonts/ttf/
  '';

  meta = {
    description = "CartographCF";
    homepage = "https://codeberg.org/0xB0F/fonts";
  };
}
