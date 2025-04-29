{ lib, config, ... }:

lib.mkIf config.me.gui.enable {
  xdg.mimeApps =
    let
      mapEntries =
        list: desktopEntry:
        builtins.listToAttrs (
          map (mimetype: {
            name = mimetype;
            value = desktopEntry + ".desktop";
          }) list
        );
    in
    {
      enable = true;
      defaultApplications =
        {
          "application/pdf" = "org.pwmt.zathura.desktop";
          "application/x-ipynb+json" = "codium.desktop";
        }
        // (mapEntries [
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
          "application/vnd.openxmlformats-officedocument.presentationml.presentation"
          "application/msword"
          "application/vnd.ms-excel"
          "application/vnd.ms-powerpoint"
          "application/vnd.oasis.opendocument.text"
          "application/vnd.oasis.opendocument.spreadsheet"
          "application/vnd.oasis.opendocument.presentation"
          "text/rtf"
          "text/csv"
        ] "zaread")

        // (mapEntries [
          "image/png"
          "image/apng"
          "image/vnd.microsoft.icon"
          "image/jpeg"
          "image/webp"
        ] "feh")

        // (mapEntries [
          "text/plain"
          "text/markdown"
          "text/x-java"
          "text/x-haskell"
          "text/x-chdr"
          "text/x-csrc"
          "text/x-makefile"
          "text/x-python"
          "text/x-log"
          "text/x-readme"
          "text/x-patch"
          "text/css"
          "application/x-php"
          "application/x-desktop"
          "application/json"
          "application/xml"
          "application/x-shellscript"
        ] "nvim")

        // (mapEntries [
          "inode/directory"
          "application/x-directory"
        ] "lf")

        // (mapEntries [
          "x-scheme-handler/http"
          "x-scheme-handler/https"
          "x-scheme-handler/chrome"
          "x-scheme-handler/mailto"
        ] config.me.browser)

        // (mapEntries [
          "application/zip"
          "application/x-rar-compressed"
          "application/x-7z-compressed"
          "application/x-tar"
          "application/x-gzip"
        ] "file-roller")

        // (mapEntries [
          "video/mp4"
          "video/x-matroska"
        ] "io.github.celluloid_player.Celluloid");
      associations.added =
        {
          "image/png" = "imv-dir.desktop";
        }
        // (mapEntries [
          "x-scheme-handler/http"
          "x-scheme-handler/https"
          "x-scheme-handler/chrome"
        ] config.me.browser);
    };
}
