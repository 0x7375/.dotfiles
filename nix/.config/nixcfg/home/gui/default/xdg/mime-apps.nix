{ lib, config, ... }:

lib.mkIf config.me.gui.enable {
  xdg.mimeApps =
    let
      editor = "nvim.desktop";
      video = "io.github.celluloid_player.Celluloid.desktop";
      image = "feh.desktop";
      browser = "firefox.desktop";
      file-manager = "lf.desktop";
      archive-manager = "file-roller.desktop";
    in
    {
      enable = true;
      defaultApplications = {
        "application/pdf" = "org.pwmt.zathura.desktop";
        "application/x-ipynb+json" = "codium.desktop";

        "image/apng" = image;
        "image/vnd.microsoft.icon" = image;
        "image/jpeg" = image;
        "image/webp" = image;

        "video/mp4" = video;
        "video/x-matroska" = video;

        "inode/directory" = file-manager;
        "application/x-directory" = file-manager;

        "text/plain" = editor;
        "text/markdown" = editor;
        "text/x-java" = editor;
        "text/x-haskell" = editor;
        "text/x-chdr" = editor;
        "text/x-csrc" = editor;
        "text/x-makefile" = editor;
        "text/x-python" = editor;
        "text/x-log" = editor;
        "text/x-readme" = editor;
        "text/x-patch" = editor;
        "text/css" = editor;
        "application/x-php" = editor;
        "application/x-desktop" = editor;
        "application/json" = editor;
        "application/xml" = editor;
        "application/x-shellscript" = editor;

        "x-scheme-handler/http" = browser;
        "x-scheme-handler/https" = browser;
        "x-scheme-handler/chrome" = browser;
        "x-scheme-handler/mailto" = browser;

        "application/zip" = archive-manager;
        "application/x-rar-compressed" = archive-manager;
        "application/x-7z-compressed" = archive-manager;
        "application/x-tar" = archive-manager;
        "application/x-gzip" = archive-manager;
      };
      associations.added = {
        "x-scheme-handler/http" = browser;
        "x-scheme-handler/https" = browser;
        "x-scheme-handler/chrome" = browser;
        "image/png" = "imv-dir.desktop";
      };
    };
}
