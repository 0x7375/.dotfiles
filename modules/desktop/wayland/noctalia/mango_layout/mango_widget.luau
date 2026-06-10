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

noctalia.state.watch("layout_info", function(value)
    barWidget.setGlyph(layout_icons[value.layout] or "question-mark")

    local name = layout_names[value.layout] or value.layout
    if value.layout == "M" then
      barWidget.setText(name .. " - " .. value.clients .. " ")
    else
      barWidget.setText(name .. " ")
    end
end)
