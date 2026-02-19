{
  pkgs,
  config,
  lib,
  ...
}:

lib.mkIf config.me.wm.enable {
  packages = with pkgs; [
    sioyek
  ];

  tinted.files.".config/sioyek/prefs_user.config".text =
    p:
    let
      copy = if pkgs.stdenv.isDarwin then "pbcopy" else "xclip -sel clip";
    in
    ''
      startup_commands toggle_status_bar;toggle_titlebar
      background_color           ${p.bg0}
      status_bar_color           ${p.bg2}
      status_bar_text_color      ${p.fg0}
      ui_text_color              ${p.fg0}
      ui_background_color        ${p.bg0}
      ui_selected_text_color     ${p.bg2}
      ui_selected_background_color ${p.blue}

      custom_background_color    ${p.bg0}
      custom_text_color          ${p.fg0}

      text_highlight_color       ${p.yellow}
      search_highlight_color     ${p.blue}
      link_highlight_color       ${p.blue}

      should_launch_new_window 1
      page_separator_width 2
      scroll_past_document_ends 0
      show_statusbar_only_when_hovered 1

      new_command _ocr_copy sh -c "pdftotext \"%1\" - | ${copy}"
    '';

  hj.xdg.config.files."sioyek/keys_user.config".text = ''
    move_down_smooth j
    move_up_smooth k
    move_left l
    move_right h

    goto_beginning go

    next_page <C-j>
    previous_page <C-k>
    next_page <right>
    previous_page <left>
    next_page f
    previous_page b

    screen_down d
    screen_up u

    fit_to_page_width s
    fit_to_page_height a

    zoom_out J
    zoom_in K
    toggle_two_page_view D
    toggle_custom_color i
    rotate_clockwise <C-r>
    reload r

    new_window <C-n>
    _ocr_copy <C-P>

    goto_toc t
  '';
}
