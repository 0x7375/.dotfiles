if not noctalia.commandExists("mmsg") then
    noctalia.notifyError("Mango Layout", "Cannot find mango in PATH")
    return
end

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

barWidget.setGlyph("question-mark")
barWidget.setText("")

function onClick()
    noctalia.runAsync("mmsg dispatch switch_layout")
end

noctalia.runStream("mmsg watch all-monitors", function(line)
  local data = noctalia.json.decode(line)

  local state

  for _, mon in ipairs(data.monitors) do
    if mon.active then
      local clients = 0
      for _, tag in ipairs(mon.tags or {}) do
        if tag.is_active then
          clients = tag.client_count or 0
          break
        end
      end
      
      state = {
        layout = mon.layout_symbol,
        clients = clients
      }
      break
    end
  end

  if not state then return end

  barWidget.setGlyph(layout_icons[state.layout] or "question-mark")
  
  local name = layout_names[state.layout] or state.layout
  if state.layout == "M" and state.clients > 0 then
    barWidget.setText(name .. " - " .. state.clients .. " ")
  else
    barWidget.setText(name .. " ")
  end
end)
