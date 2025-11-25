############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("scimodule")
#endregion

############################################################
#region modules from the Environment
import { WebSocketServer } from "ws"

############################################################
import * as bs from "./bugsnitch.js"

############################################################
import * as scicore from "./scicoremodule.js"

############################################################
import { onConnect } from "./wsimodule.js"
import { isBlocked } from "./earlyblockermodule.js"

#endregion


############################################################
wsS = new WebSocketServer({noServer: true})
wsS.on("connection", onConnect)

############################################################
wsUpgradeHandler = (req, sock, head) ->
    if isBlocked(req)
        sock.write('HTTP/1.1 403 Forbidden\r\n\r\n')
        sock.destroy()
        return
    wsS.handleUpgrade(req, sock, head, ((ws) -> wsS.emit("connection", ws, req)))
    return

############################################################
export prepareAndExpose = ->
    log "prepareAndExpose"
    scicore.setUpgradeHandler(wsUpgradeHandler)
    await scicore.sciStartServer()
    return
