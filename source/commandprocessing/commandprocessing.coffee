############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("commandprocessing")
#endregion

############################################################
import * as chat from "./chatrelaymodule.js"
import * as sess from "./sessionmodule.js"
import * as cfg from "./configmodule.js"

############################################################
export sendSessionState = (conn) ->
    log "endSessionState"
    key = conn.key
    if !sess.isValid(key) then return conn.sendState("InvalidKey")
    conn.noticeState(sess.getState(key))
    return

export authorizationProcess = (conn, key) ->
    log "authorizationProcess"
    key = sess.checkSession(key)
    conn.setSession(key)
    return

export interferenceProcess = (conn, msg) ->
    log "interferenceProcess"
    key = conn.key
    try
        if !sess.isValid(key)
            conn.noticeInvalidKey()
            console.error("Invalid session key!")
            return

        oldMessages = sess.getMessages(key)
        if oldMessages.length >= cfg.messageLimit
            conn.noticeMessageLimitReached()
            sess.setState(key, "MessageLimitReached")
            console.error("User reached the messageLimit!")
            return

        sess.addUserMessage(key, msg)
        sess.setState(key, "Processing")
        await chat.generateStreamResponse(sess.getMessages(key), conn)
        sess.setState(key, "Idle")
        return
    catch err then console.error(err)
    return 

export resetHistoryProcess = (conn, arg) ->
    log "resetHistoryProcess"
    log arg
    log "Not implemented!"
    return

