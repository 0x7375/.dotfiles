{
  config,
  mkBundle,
  ...
}:

mkBundle {
  nixos = {
    systemd.tmpfiles.rules = [
      "d ${config.me.home}/.local 0755 ${config.me.user} users -"
      "d ${config.me.home}/.local/share 0755 ${config.me.user} users -"
      "d ${config.me.home}/.local/share/gnupg 0700 ${config.me.user} users -"
      "d ${config.me.home}/.local/share/android 0755 ${config.me.user} users -"
    ];

    vars = rec {
      XDG_RUNTIME_DIR = "/run/user/$UID";
      XAUTHORITY = "${XDG_RUNTIME_DIR}/Xauthority";
    };
  };

  vars = rec {
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
    XDG_BIN_HOME = "$HOME/.local/bin";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
    PATH = [ "${XDG_BIN_HOME}" ];
    HISTFILE = "${XDG_STATE_HOME}/bash/history";
    PYTHON_HISTORY = "${XDG_STATE_HOME}/python_history";
    GOPATH = "${XDG_DATA_HOME}/go";
    PGPASSFILE = "${XDG_CONFIG_HOME}/pg/pgpass";
    MYSQL_HISTFILE = "${XDG_DATA_HOME}/mysql_history";
    PSQL_HISTORY = "${XDG_DATA_HOME}/psql_history";
    _Z_DATA = "${XDG_DATA_HOME}/z";
    ANSIBLE_HOME = "${XDG_DATA_HOME}/ansible";
    CARGO_HOME = "${XDG_DATA_HOME}/cargo";
    CUDA_CACHE_PATH = "${XDG_CACHE_HOME}/nv";
    GRADLE_USER_HOME = "${XDG_DATA_HOME}/gradle";
    NIMBLE_DIR = "${XDG_DATA_HOME}/nimble";
    STACK_ROOT = "${XDG_DATA_HOME}/stack";
    TEXMFVAR = "${XDG_CACHE_HOME}/texlive/texmf-var";
    WINEPREFIX = "${XDG_DATA_HOME}/wine";
    GNUPGHOME = "${XDG_DATA_HOME}/gnupg";
    CABAL_DIR = "${XDG_DATA_HOME}/cabel";
    CABAL_CONFIG = "${XDG_CONFIG_HOME}/cabal/config";
    ZDOTDIR = "${XDG_CONFIG_HOME}/zsh";
    NPM_CONFIG_USERCONFIG = "${XDG_CONFIG_HOME}/npm/npmrc";
    RUSTUP_HOME = "${XDG_DATA_HOME}/rustup";
    ERRFILE = "${XDG_CACHE_HOME}/X11/xsession-errors";
  };

  hj.xdg.config.files."vim/vimrc".text = # vim
    ''
      set viminfo+=n~/.local/state/viminfo
    '';

  hj.xdg.config.files."npm/npmrc".text = ''
    prefix=''${XDG_DATA_HOME}/npm
    cache=''${XDG_CACHE_HOME}/npm
    init-module=''${XDG_CONFIG_HOME}/npm/config/npm-init.js
    tmp=''${XDG_RUNTIME_DIR}/npm
  '';
}
