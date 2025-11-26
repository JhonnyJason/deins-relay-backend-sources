############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("sessionmodule")
#endregion

############################################################
import crypto from "node:crypto"
import * as tbut from "thingy-byte-utils"

############################################################
import { makeForgetable } from "memory-decay"

############################################################
keyToSession = Object.create(null)
ttlSessionMS = 7_200_000 # ~2h
ackTimeoutMS = 120_000 # ~2m

############################################################
export initialize = (c) ->
    log "initialize"
    if c.ttlSessionMS? then ttlSessionMS = c.ttlSessionMS

    keyToSession = makeForgetable(keyToSession, ttlSessionMS)
    return

############################################################
createKey = ->
    keyBytes = crypto.randomBytes(32)
    return tbut.bytesToHex(keyBytes)
    
createNewSession = ->
    log "createNewSession"
    key = createKey()
    key = createKey() while keyToSession[key]? 
        
    sessionObj = Object.create(null)
    sessionObj.msgs = []
    sessionObj.lastInteraction = Date.now()
    sessionObj.state = "Idle"
    ## TODO add all important parameters to notice abuse

    # log key
    # olog sessionObj

    keyToSession[key] = sessionObj
    keyToSession.letForget(key)
    return key

removeLastAssMessage = (sessObj) ->
    log "removeLastAssMessage"
    msg = sessObj.msgs[msgs.length - 1]
    if msg? and msg.role == "assistant" then sessObj.msgs.pop()
    # sessObj.state = "Idle"
    sessObj.state = "MissedAck"
    return

############################################################
export clearSession = (k) -> 
    sessionObj = keyToSession[k]
    sessionObj.msgs = []
    sessionObj.lastInteraction = Date.now()
    return

############################################################
export addAssMessage = (k, msg) ->
    log "addAssMessage"
    msgObj = { role: "assistant", content: msg }
    keyToSession[k].msgs.push(msgObj)
    return

export addUserMessage = (k, msg) ->
    log "addUserMessage"
    msgObj = { role: "user", content: msg }
    sessionObj = keyToSession[k]
    sessionObj.msgs.push(msgObj)
    sessionObj.lastInteraction = Date.now()
    return

############################################################
export setAckTimeout = (k) ->
    log "setAckTimeout"
    sessionObj = keyToSession[k]
    onTimeout = -> removeLastAssMessage(sessionObj)
    sessionObj.ackTimeout = setTimeout(onTimeout, ackTimeoutMS)
    return

export clearAckTimeout = (k) ->
    clearTimeout(keyToSession[k].ackTimeout)
    return

############################################################
export getMessages = (k) -> keyToSession[k].msgs

############################################################
export getState = (k) -> keyToSession[k].state
export setState = (k, state) -> keyToSession[k].state = state

############################################################
export isValid = (k) ->
    return typeof k == "string" and k.length == 64 and keyToSession[k]?

############################################################
## takes session key - if it does not exist it creates a new session
## returns a valid key
export checkSession = (key) ->
    if typeof key == "string" and key.length == 64 and keyToSession[key]?
        keyToSession.letForget(key) ## reset memory decay
        keyToSession[key].lastInteraction = Date.now()
        return key
    return createNewSession()
