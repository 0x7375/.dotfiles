{ pkgs, ... }:

pkgs.rustPlatform.buildRustPackage rec {
  pname = "pass-secret-service";
  version = "0.6.0";

  src = pkgs.fetchFromGitHub {
    owner = "grimsteel";
    repo = "pass-secret-service";
    tag = "v${version}";
    hash = "sha256-EThnD2vqrUhyFaSEkwNY5SarL3RQb95eA3joIN2KkAY=";
  };

  cargoHash = "sha256-VLXPwDf2WRnCYEr3VeZFrJR29rrKIbBXEA7e14CUkdw=";

  postInstall = ''
    install -Dm644 systemd/org.freedesktop.secrets.service \
    $out/share/dbus-1/services/org.freedesktop.secrets.service
    install -Dm644 systemd/pass-secret-service.service \
    $out/lib/systemd/user/pass-secret-service.service
    substituteInPlace $out/share/dbus-1/services/org.freedesktop.secrets.service \
    $out/lib/systemd/user/pass-secret-service.service \
    --replace-fail "/usr/bin" "$out/bin"
  '';

  meta = {
    description = "Implementation of org.freedesktop.secrets using pass";
    homepage = "https://github.com/grimsteel/pass-secret-service";
    license = pkgs.lib.licenses.gpl3Only;
    maintainers = [ ];
    mainProgram = "pass-secret-service";
  };
}
