if not RxBridge.VRP.IsEnabled() then return end

--- Server-side vRP bridge uses explicit handlers in server/main.lua only.
--- No automatic RX <-> vRP event bouncing (prevents invalid PlayerLoaded args).
