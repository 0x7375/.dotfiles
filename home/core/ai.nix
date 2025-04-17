{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ollama
    aichat
  ];

  xdg.configFile."aichat/roles.yaml".text = # yaml
    "";

  xdg.configFile."aichat/config.yaml".text = # yaml
    ''
      model: ollama
      highlight: false
      clients:
      - type: ollama
        api_base: http://127.0.0.1:11434
        api_auth: Basic xxx
        chat_endpoint: /api/chat
        models:
        - name: llama3
          max_input_tokens: 8192
    '';
}
