############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("commandprocessing")
#endregion

############################################################
import * as bs from "./bugsnitch.js"
############################################################
import * as chat from "./chatrelaymodule.js"
import * as sess from "./sessionmodule.js"
import * as cfg from "./configmodule.js"

############################################################
export sendSessionState = (conn) ->
    log "endSessionState"
    key = conn.key
    if !sess.isValid(key) then return conn.noticeState("InvalidKey")
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
        
        state = sess.getState(key)
        if state != "Idle"
            conn.noticeTooFast()
            console.error("Attempt to request new Interference while not idle!")
            return

        if msg.length  > cfg.userMessageSizeLimit
            conn.noticeMessageTooLarge()
            console.error("Message from user exceeded size Limit! (#{msg.length})")
            return

        sess.addUserMessage(key, msg)
        sess.setState(key, "Processing")
        await chat.generateStreamResponse(sess.getMessages(key), conn)
        sess.setState(key, "Idle")
        return
    catch err then console.error(err)
    return 

export resetHistoryProcess = (conn) ->
    log "resetHistoryProcess"
    key = conn.key
    state = sess.getState(key)
    if state != "Idle"
        conn.noticeTooFast()
        console.error("Attempt to resetHistory while not idle!")
        return
    
    sess.clearSession(key)
    return
