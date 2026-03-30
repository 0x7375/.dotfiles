return {
  cmd = { "nixd", "--semantic-tokens=true", "--inlay-hints=true" },
  settings = {
    nixd = (function()
      local flake = os.getenv("FLAKE")
      if not flake then
        return
      end

      flake = '(builtins.getFlake "' .. flake .. '")'

      local uname = io.popen("uname"):read("*l")
      local sys = (uname == "Linux") and "nixos" or "darwin"

      local host = os.getenv("HOSTNAME")

      return {
        nixpkgs = {
          expr = string.format("import %s.inputs.nixpkgs { }", flake),
        },
        options = {
          [sys] = {
            expr = string.format("%s.%sConfigurations.%s.options", flake, sys, host),
          },
        },
      }
    end)(),
  },
}
