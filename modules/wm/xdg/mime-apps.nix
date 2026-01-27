{
  mkNixos,
  lib,
  config,
  ...
}:

lib.mkIf config.me.wm.enable (mkNixos {
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
      defaultApplications = {
        "application/x-gaphor" = "gaphor.desktop";
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
        "image/svg+xml"
      ] "pqiv")

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
        "application/bzip2"
        "application/gzip"
        "application/zip"
        "application/vnd.rar"
        "application/x-7z-compressed-tar"
        "application/x-bzip"
        "application/x-bzip2"
        "application/x-bzip2-compressed-tar"
        "application/x-bzip-compressed-tar"
        "application/x-compress"
        "application/x-compressed-tar"
        "application/x-cpio"
        "application/x-lha"
        "application/x-lzip"
        "application/x-lzip-compressed-tar"
        "application/x-lzma"
        "application/x-lzma-compressed-tar"
        "application/x-rar-compressed"
        "application/x-tarz"
        "application/x-xar"
        "application/x-xz"
        "application/x-xz-compressed-tar"
        "application/x-zstd-compressed-tar"
        "application/zstd"
      ] "file-roller")

      // (mapEntries [
        "audio/vnd.wave"
        "audio/midi"
        "audio/x-wav"
        "audio/x-flac"
        "audio/flac"
        "audio/mpeg"
        "audio/ogg"
        "audio/x-musepack"
        "audio/x-monkeysaudio"
        "audio/aac"
        "audio/x-aac"
      ] "mpv")

      // (mapEntries [
        "video/mp4"
        "video/x-matroska"
      ] "mpv");
      # ] "io.github.celluloid_player.Celluloid");

      associations.added = {
        "image/png" = "imv-dir.desktop";
      }
      // (mapEntries [
        "x-scheme-handler/http"
        "x-scheme-handler/https"
        "x-scheme-handler/chrome"
      ] config.me.browser);
    };

  hj.xdg.data.files."mime/packages/gaphor.xml".text = # xml
    ''
      <?xml version="1.0" encoding="UTF-8"?>
      <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
        <mime-type type="application/x-gaphor">
          <comment>Gaphor UML diagram</comment>
          <glob pattern="*.gaphor"/>
          <sub-class-of type="application/xml"/>
        </mime-type>
      </mime-info>
    '';
})
