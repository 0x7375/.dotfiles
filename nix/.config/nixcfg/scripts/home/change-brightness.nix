{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "change-brightness";
  runtimeInputs = with pkgs; [ brillo ];
  text = ''
    fade=150000

    case $1 in
    up)
        brillo -u $fade -q -A 10
        ;;
    down)
        brillo -u $fade -q -U 10
        ;;
    esac
  '';
}
