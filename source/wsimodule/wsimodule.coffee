############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("wsimodule")
#endregion

############################################################
import {
    authorizationProcess, interferenceProcess, resetHistoryProcess
} from "./commandprocessing.js"

############################################################
clientIdCount = 0

############################################################
class SocketConnection
    constructor: (@socket, @clientId) ->
        # preseve that "this" is this class
        self = this
        @socket.onmessage = (evnt) -> self.onMessage(evnt)
        @socket.onclose = (evnt) -> self.onDisconnect(evnt)
        log "#{@clientId} connected!"

    onMessage: (evnt) =>
        log "onMessage"
        try
            message = evnt.data
            log "#{message}"

            # separate command from potential argument            
            commandEnd = message.indexOf(" ")
            if commandEnd < 0 then command = message # no argument
            else
                command = message.substring(0, commandEnd)
                arg = message.substring(commandEnd).trim()

            switch command
                when "ping" then @socket.send("pong")
                when "authorizeMe" then authorizationProcess(this, arg)
                when "interference" then interferenceProcess(this, arg)
                when "resetHistory" then resetHistoryProcess(this, arg)
                when "sendState" then sendSessionState(this)
                else throw new Error("unknown command: #{command}")

        catch err then log err
        return

    onDisconnect: (evnt) ->
        log "onDisconnect: #{@clientId}"
        try
            #TODO implment some unsubscribing  
        catch err then log err
        return

    aiResponseStart: -> @socket.send("ai:")
    aiResponseStream: (fragment) -> @socket.send("ai+ "+fragment)
    aiResponseEnd: -> @socket.send("ai/")

    setSession: (key) ->
        @key = key
        @socket.send("key "+key)
        return

    noticeInvalidKey: -> @socket.send("err InvalidKey")
    noticeMessageLimitReached: -> @socket.send("err MessageLimit")
    noticeTooFast: -> @socket.send("err TooFast")

    noticeState: (stateString) -> @socket.send("stt "+stateString)

############################################################
export onConnect = (socket, req) ->
    olog req.body 
    conn = new SocketConnection(socket, "#{clientIdCount}")
    clientIdCount++
    ## TODO 
    return


