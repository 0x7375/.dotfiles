{ mkNixos, ... }:

mkNixos {
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
  };

  environment.sessionVariables = {
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
  };

  hj.files.".XCompose".text = # xcompose
    ''
      <Multi_key> <w> : "è"
      <Multi_key> <W> : "È"
      <Multi_key> <E> : "ë"
      <Multi_key> <e> : "ê"
      <Multi_key> <r> : "é"
      <Multi_key> <R> : "É"

      <Multi_key> <A> : "â"
      <Multi_key> <a> : "à"

      <Multi_key> <o> : "ô"
      <Multi_key> <O> : "ö"

      <Multi_key> <i> : "î"
      <Multi_key> <I> : "ï"

      <Multi_key> <u> : "û"
      <Multi_key> <U> : "μ"
      <Multi_key> <y> : "ù"

      <Multi_key> <c> : "ç"
      <Multi_key> <C> : "Ç"

      <Multi_key> <greater> : "»"
      <Multi_key> <less> : "«"

      <Multi_key> <equal> <l>	: "£"
      <Multi_key> <equal> <y>	: "¥"
      <Multi_key> <equal> <e>	: "€"

      <Multi_key> <x> : "×"
      <Multi_key> <0> <0> : "°"

      <Multi_key> <0> <c> : "©"

      <Multi_key> <0> <e> : "œ"
      <Multi_key> <0> <E> : "Œ"

      <Multi_key> <8> <8>	: "∞"	U221e
    '';
}
