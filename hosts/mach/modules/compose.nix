{
  activation = ''
    mkdir -p ~/Library/KeyBindings
  '';

  hj.files."Library/KeyBindings/DefaultKeyBinding.dict".text = ''
    {
      "\Uf710" = {
        "w" = ("insertText:", "è");
        "W" = ("insertText:", "È");
        "e" = ("insertText:", "ê");
        "E" = ("insertText:", "ë");
        "r" = ("insertText:", "é");
        "R" = ("insertText:", "É");
        "a" = ("insertText:", "à");
        "A" = ("insertText:", "â");
        "o" = ("insertText:", "ô");
        "O" = ("insertText:", "ö");
        "i" = ("insertText:", "î");
        "I" = ("insertText:", "ï");
        "u" = ("insertText:", "û");
        "U" = ("insertText:", "μ");
        "y" = ("insertText:", "ù");
        "c" = ("insertText:", "ç");
        "C" = ("insertText:", "Ç");
        "?" = ("insertText:", "»");
        "<" = ("insertText:", "«");
        "x" = ("insertText:", "×");
        "0" = {
          "0" = ("insertText:", "°");
          "c" = ("insertText:", "©");
          "e" = ("insertText:", "œ");
          "E" = ("insertText:", "Œ");
        };
        "8" = {
          "8" = ("insertText:", "∞");
        };
        "=" = {
          "l" = ("insertText:", "£");
          "y" = ("insertText:", "¥");
          "e" = ("insertText:", "€");
        };
      };
    }
  '';
}
