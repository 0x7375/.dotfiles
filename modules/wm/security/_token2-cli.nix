{ pkgs, src }:

let
  pythonEnv = pkgs.python312.withPackages (
    ps: with ps; [
      pycryptodome
      pyscard
      hidapi
      ecdsa
      pyperclip
    ]
  );
in
pkgs.writeShellApplication {
  name = "token2-cli";
  runtimeInputs = [
    pythonEnv
    pkgs.pcsclite
  ];
  text = ''
    python ${src}/app.py "$@"
  '';
}
