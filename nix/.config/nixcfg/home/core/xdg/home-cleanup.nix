{
  xdg.configFile."vim/vimrc".text = # vim
    ''
      set viminfo+=n~/.local/state/viminfo
    '';

  xdg.configFile."python/pythonrc".text = # python
    ''
      def is_vanilla() -> bool:
          import sys
          return not hasattr(__builtins__, '__IPYTHON__') and 'bpython' not in sys.argv[0]

      def setup_history():
          import os
          import atexit
          import readline
          from pathlib import Path

          if state_home := os.environ.get('XDG_STATE_HOME'):
              state_home = Path(state_home)
          else:
              state_home = Path.home() / '.local' / 'state'

          history: Path = state_home / 'python_history'

          if not history.exists():
              history.touch()
          readline.read_history_file(str(history))
          atexit.register(readline.write_history_file, str(history))

      if is_vanilla():
          setup_history()
    '';

  xdg.configFile."npm/npmrc".text = ''
    prefix=''${XDG_DATA_HOME}/npm
    cache=''${XDG_CACHE_HOME}/npm
    init-module=''${XDG_CONFIG_HOME}/npm/config/npm-init.js
    tmp=''${XDG_RUNTIME_DIR}/npm
  '';
}
