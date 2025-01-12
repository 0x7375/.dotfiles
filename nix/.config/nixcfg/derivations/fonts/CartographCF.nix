{ stdenv, fetchFromSourcehut, ... }:

stdenv.mkDerivation rec {
  pname = "CartographCF";
  version = "main";

  src = fetchFromSourcehut {
    owner = "~ayko";
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
    homepage = "https://git.sr.ht/~ayko/fonts";
  };
}
