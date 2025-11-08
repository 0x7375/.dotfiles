{
  pkgs,
  lib,
  config,
  ...
}:

lib.mkIf config.me.gui.enable {
  packages = with pkgs; [
    # codium
    (vscode-with-extensions.override {
      vscode = vscodium;
      vscodeExtensions =
        with vscode-extensions;
        [
          jnoortheen.nix-ide
          haskell.haskell
          justusadam.language-haskell
          asvetliakov.vscode-neovim
          ms-python.python
          redhat.java
          mkhl.direnv
          golang.go
          llvm-vs-code-extensions.vscode-clangd
        ]
        ++ vscode-utils.extensionsFromVscodeMarketplace [
          # {
          #   name = "everforest";
          #   publisher = "sainnhe";
          #   version = "0.3.0";
          #   sha256 = "nZirzVvM160ZTpBLTimL2X35sIGy5j2LQOok7a2Yc7U=";
          # }
          {
            name = "debug";
            publisher = "webfreak";
            version = "0.27.0";
            sha256 = "p/k5UcXldXKFKbPbnW603Jsut53n01azeDhWMDSd4nw=";
          }
        ]
        ++ [
          (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
            mktplcRef = {
              name = "monochromator";
              publisher = "beem";
              version = "0.28.0";
            };
            vsix = pkgs.fetchurl {
              name = "beem.monochromator-0.28.0.vsix.zip";
              url = "https://open-vsx.org/api/beem/monochromator/0.28.0/file/beem.monochromator-0.28.0.vsix";
              sha256 = "sha256-UaH7+qc9ytvEW9WjjN2lRbHMuzwxEDF4lh+SRn7lesY=";
            };
          })
        ];
    })
  ];

  hj.xdg.config.files."VSCodium/User/keybindings.json" = {
    type = "copy";
    permissions = "0644";
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

  hj.xdg.config.files."VSCodium/User/settings.json" = {
    type = "copy";
    permissions = "0644";
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
            "editor.fontFamily": "'${config.me.gui.font} Nerd Font', 'serif'",
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
            "workbench.activityBar.location": "hidden",
            "terminal.external.linuxExec": "${config.me.gui.terminal} -e tmux",
            "explorer.confirmDelete": false,
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
            "editor.lightbulb.enabled": "off",
            "nix.enableLanguageServer": true,
            "nix.serverPath": "nixd",
            "editor.fontWeight": "bold",
            "editor.hover.enabled": false,
            "editor.wordWrap": "on",
            "editor.inlayHints.enabled": "on",
            "redhat.telemetry.enabled": false,
            "window.autoDetectColorScheme": true,
            "workbench.preferredDarkColorTheme": "Monochromator Dark Amber",
            "workbench.preferredHighContrastColorTheme": "Monochromator Light Amber",
            "workbench.preferredLightColorTheme": "Monochromator Light Amber"
        }
      '';
  };
}
