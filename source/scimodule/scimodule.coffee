############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("scimodule")
#endregion

############################################################
#region modules from the Environment
import * as sciBase from "thingy-sci-ws-base"

import { onConnect } from "./wsimodule.js"
import { getState } from "./serverstatemodule.js"

import { checkOrThrow } from "./earlyblockermodule.js"

#endregion

############################################################
returnCurrentState = (req, res) ->
    res.send(getState())
    return

############################################################
rejectForbidden = (req, res, next) ->
    ip = req.ip
    origin = req.origin
    try checkOrThrow(ip, origin)
    catch err then return res.status(403).send('Denied!')

    return next()

############################################################
export prepareAndExpose = ->
    log "prepareAndExpose"

    routes = {
        "getState": returnCurrentState
    }

    sciBase.prepareAndExpose( rejectForbidden, routes )
    sciBase.onWebsocketConnect("/", onConnect)
    log "Server listening!"
    return
