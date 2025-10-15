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
import { passphrase } from "./configmodule.js"

import * as chatRelay from "./chatrelaymodule.js"

#endregion

############################################################
returnCurrentState = (req, res) ->
    res.send(getState())
    return

############################################################
relaySingleCompletion = (req, res) ->
    try
        msg = req.body.message

        completion = await chatRelay.singleCompletion(msg)
        res.send(completion)
    catch err then res.status(500).send(err.message)
    return

############################################################
relayChat = (req, res) ->
    try
        msg = req.body.message
        chatId = req.body.chatId

        completion = await chatRelay.chatCompletion(msg)
        res.send(completion)
    catch err then res.status(500).send(err.message)
    return

############################################################
export prepareAndExpose = ->
    log "prepareAndExpose"

    sciBase.prepareAndExpose(null, 
        { 
            "getState": returnCurrentState,
            "relaySingle": relaySingleCompletion,
            "relayChat": relayChat
        }
    )

    sciBase.onWebsocketConnect("/", onConnect)
    log "Server listening!"
    log "passphrase is: #{passphrase}"
    return
