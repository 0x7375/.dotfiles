barWidget.setUpdateInterval(100)

local layout_names = {
  S = "Scroller",
  T = "Tile",
  G = "Grid",
  M = "Monocle",
  K = "Deck",
  CT = "Center Tile",
  RT = "Right Tile",
  VS = "Vertical Scroller",
  VT = "Vertical Tile",
  VG = "Vertical Grid",
  VK = "Vertical Deck",
  TG = "Tgmix",
}

local layout_icons = {
  T = "layout-sidebar",
  M = "rectangle",
  S = "carousel-horizontal",
  G = "layout-grid",
  K = "versions",
  RT = "layout-sidebar-right",
  CT = "layout-distribute-vertical",
  TG = "layout-dashboard",
  VT = "layout-rows",
  VS = "carousel-vertical",
  VG = "grid-dots",
  VK = "chart-funnel",
}

local function get_mango_status()
  noctalia.runAsync(
    [[sh -c 'mon=$(mmsg get focusing-client | jq -r .monitor) && mmsg get monitor "$mon" | jq -r ".layout_symbol,(.tags[]|select(.is_active).client_count)"']],
    function(r)
      local layout, clients = r.stdout:match("(%S+)\n(%d+)")
      if not layout then
        return
      end
      clients = tonumber(clients) or 0

      barWidget.setGlyph(layout_icons[layout] or "question-mark")
      local name = layout_names[layout] or layout
      if layout == "M" then
        barWidget.setText(name .. " - " .. clients .. " ")
      else
        barWidget.setText(name .. " ")
      end
    end
  )
end

function update() get_mango_status() end
