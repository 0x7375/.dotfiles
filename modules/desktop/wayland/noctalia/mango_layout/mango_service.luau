noctalia.setUpdateInterval(100)

local function get_layout_info()
  noctalia.runAsync(
    [[sh -c 'mon=$(mmsg get focusing-client | jq -r .monitor) && mmsg get monitor "$mon" | jq -r ".layout_symbol,(.tags[]|select(.is_active).client_count)"']],
    function(r)
      local layout, clients = r.stdout:match("(%S+)\n(%d+)")
      if not layout then
        return
      end
      clients = tonumber(clients) or 0

      noctalia.state.set("layout_info", { layout = layout, clients = clients })
    end
  )
end

function update()
    get_layout_info()
end
