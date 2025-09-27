{
  myLib,
  lib,
  config,
  ...
}:

let
  palette = myLib.palette;
in
lib.mkIf config.me.gui.enable {
  home.file.".config/VSCodium/User/keybindings.json" = {
    enable = true;
    force = true;
    mutable = true;
    text = # jsonc
      ''
        [
          {
            "key": "ctrl+y",
            "command": "acceptSelectedCodeAction",
            "when": "codeActionMenuVisible"
          },
          {
            "command": "vscode-neovim.send",
            "key": "ctrl+u",
            "when": "editorTextFocus",
            "args": "<C-u>"
          },
          {
            "command": "vscode-neovim.send",
            "key": "ctrl+d",
            "when": "editorTextFocus",
            "args": "<C-d>"
          },
          {
            "key": "shift+escape",
            "command": "workbench.action.closePanel"
          },
          {
            "key": "tab",
            "command": "-acceptSelectedSuggestion",
            "when": "suggestWidgetHasFocusedSuggestion && suggestWidgetVisible && textInputFocus"
          },
          {
            "key": "tab",
            "command": "acceptSelectedSuggestion",
            "when": "suggestWidgetHasFocusedSuggestion && suggestWidgetVisible && textInputFocus && !neovim.init"
          },
          {
            "key": "enter",
            "command": "-acceptSelectedSuggestion",
            "when": "acceptSuggestionOnEnter && suggestWidgetHasFocusedSuggestion && suggestWidgetVisible && suggestionMakesTextEdit && textInputFocus"
          },
          {
            "key": "enter",
              "command": "acceptSelectedSuggestion",
              "when": "acceptSuggestionOnEnter && suggestWidgetHasFocusedSuggestion && suggestWidgetVisible && suggestionMakesTextEdit && textInputFocus && !neovim.init"
          },
          {
            "key": "ctrl+shift+r",
            "command": "vscode-neovim.restart"
          },
          {
            "key": "ctrl+y",
            "command": "acceptSelectedSuggestion",
            "when": "acceptSuggestionOnEnter && suggestWidgetHasFocusedSuggestion && suggestWidgetVisible && suggestionMakesTextEdit && textInputFocus"
          }
        ]
      '';
  };

  home.file.".config/VSCodium/User/settings.json" = {
    enable = true;
    force = true;
    mutable = true;
    text = # json
      ''
        {
            "vim.normalModeKeyBindingsNonRecursive": [
                {
                    "before": ["u"],
                    "after": [],
                    "commands": [
                        {
                            "command": "undo",
                            "args": []
                        }
                    ]
                },
                {
                    "before": ["<S-u>"],
                    "after": [],
                    "commands": [
                        {
                            "command": "redo",
                            "args": []
                        }
                    ]
                },
            ],
            "vim.normalModeKeyBindings": [
                {
                    "before": ["s"],
                    "after": ["V"]
                }
            ],
            "vim.visualModeKeyBindings": [
                {
                    "before": ["s"],
                    "after": ["V"]
                }
            ],
            "vim.cursorStylePerMode.visualline": "block",
            "vim.highlightedyank.enable": true,
            "vim.replaceWithRegister": true,
            "vim.leader": "space",
            "vim.useSystemClipboard": true,
            "editor.lineNumbers": "relative",
            "editor.selectionClipboard": false,
            "notebook.compactView": false,
            "notebook.consolidatedRunButton": true,
            "notebook.dragAndDropEnabled": false,
            "notebook.undoRedoPerCell": false,
            "security.workspace.trust.banner": "never",
            "editor.fontFamily": "'0xproto Nerd Font', 'serif'",
            "editor.wordSeparators": "`~!@#$%^&*()-=+[{]}\\|;:'\",.<>/?_",
            "editor.minimap.enabled": false,
            "notebook.cellToolbarLocation": {
                "default": "right",
                "jupyter-notebook": "hidden"
            },
            "editor.scrollbar.horizontal": "hidden",
            "editor.scrollbar.vertical": "hidden",
            "window.zoomLevel": 3,
            "workbench.startupEditor": "none",
            "editor.matchBrackets": "never",
            "editor.occurrencesHighlight": false,
            "editor.renderLineHighlight": "none",
            "workbench.editor.showTabs": "single",
            "editor.fontSize": 12,
            "editor.padding.top": 10,
            "editor.folding": false,
            "editor.renderWhitespace": "none",
            "window.menuBarVisibility": "toggle",
            "security.workspace.trust.startupPrompt": "never",
            "security.workspace.trust.enabled": false,
            "workbench.colorTheme": "Gruvbox Dark Hard",
            "workbench.activityBar.location": "hidden",
            "terminal.external.linuxExec": "alacritty -e tmux",
            "explorer.confirmDelete": false,
            "workbench.colorCustomizations": {
                "[Gruvbox Dark Hard]": {
                    "editor.background": "${palette.bg0}",
                    "activityBar.background": "${palette.bg0}",
                    "statusBar.background": "${palette.bg0}",
                    "statusBar.noFolderBackground": "${palette.bg0}",
                    "sideBar.background": "${palette.bg0}",
                    "commandCenter.background": "${palette.bg0}",
                    "editorSuggestWidget.background": "${palette.bg0}",
                    "editorSuggestWidget.selectedBackground": "${palette.bg1}",
                    "editorSuggestWidget.selectedForeground": "${palette.fg0}",
                    "terminal.background": "${palette.bg0}",
                    "quickInput.background": "${palette.bg0}",
                    "editorHoverWidget.background": "${palette.bg0}",
                    "editorPane.background": "${palette.bg0}",
                    "editorWidget.background": "${palette.bg0}",
                    "notifications.background": "${palette.bg0}",
                    "editorGroupHeader.noTabsBackground": "${palette.bg0}"
                }
            },
            "breadcrumbs.enabled": false,
            "editor.scrollbar.verticalScrollbarSize": 0,
            "editor.autoClosingBrackets": "never",
            "editor.autoClosingQuotes": "never",
            "haskell.manageHLS": "PATH",
            "extensions.experimental.affinity": {
                "asvetliakov.vscode-neovim": 1
            },
            "editor.lineHeight": 1.1,
            "editor.padding.bottom": 10,
            "[java]": {
                "editor.suggest.snippetsPreventQuickSuggestions": false
            },
            "terminal.integrated.commandsToSkipShell": [
                "-workbench.action.terminal.toggleTerminal"
            ],
            "terminal.integrated.fontSize": 18,
            "editor.cursorSurroundingLines": 8,
            "workbench.tree.renderIndentGuides": "always",
            "workbench.tree.indent": 20,
            "explorer.confirmDragAndDrop": false,
            "terminal.integrated.sendKeybindingsToShell": true,
            "editor.lightbulb.enabled": false,
            "nix.enableLanguageServer": true,
            "nix.serverPath": "nixd",
            "editor.fontWeight": "bold",
            "editor.hover.enabled": false,
            "editor.wordWrap": "on",
            "editor.inlayHints.enabled": "on",
            "redhat.telemetry.enabled": false
        }
      '';
  };
}
