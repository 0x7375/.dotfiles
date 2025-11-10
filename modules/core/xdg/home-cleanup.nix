{
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
