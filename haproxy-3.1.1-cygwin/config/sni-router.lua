core.register_action("set_dyn_server", { "tcp-req" }, function(txn)
    local sni = txn.f:req_ssl_sni()
    if not sni then return end

    -- Match pattern like 192-168-0-10-8443.example.com
    local ip1, ip2, ip3, ip4, port = sni:match("^(%d+)%-(%d+)%-(%d+)%-(%d+)%-(%d+)%..+$")
    if not (ip1 and ip2 and ip3 and ip4 and port) then
        core.Debug("Invalid SNI: " .. (sni or "nil"))
        return
    end

    local ip = string.format("%d.%d.%d.%d", ip1, ip2, ip3, ip4)
    local server = txn.sf:server()
    if server then
        core.Debug("Routing to " .. ip .. ":" .. port)
        server:set_addr(ip, tonumber(port))
    end
end)