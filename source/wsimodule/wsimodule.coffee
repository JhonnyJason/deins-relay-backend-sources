############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("wsimodule")
#endregion

############################################################
import * as bs from "./bugsnitch.js"
############################################################
import {
    authorizationProcess, interferenceProcess, resetHistoryProcess
} from "./commandprocessing.js"

############################################################
import { blockIp } from "./earlyblockermodule.js"

############################################################
clientIdCount = 0
keyToConnection = Object.create(null)

############################################################
timeBlockMS = 10_000 # ~10s
usageLimit = 3
usageViolation = 4

############################################################
class SocketConnection
    constructor: (@socket, @clientId, @meta) ->
        # preseve that "this" is this class
        self = this
        @socket.onmessage = (evnt) -> self.onMessage(evnt)
        @socket.onclose = (evnt) -> self.onDisconnect(evnt)
        log "#{@clientId} connected!"
        @usage = 0
        @interval = setInterval(self.usageRelief, timeBlockMS)


    usageRelief: => 
        @usage -= usageLimit
        if @usage < 0 then @usage = 0
        return 

    onMessage: (evnt) =>
        log "onMessage"
        @usage++
        if @usage == usageLimit then return @noticeTooFast()
        if @usage == usageViolation then return @blockThis()
        
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

    onDisconnect: (evnt) =>
        log "onDisconnect: #{@clientId}"
        try
            key = ""+@meta.ip+":"+@meta.host+"("+@meta.userAgent+")"
            delete keyToConnection[key]
            @socket = null
            clearInterval(@interval)
            return
        catch err then log err
        return

    aiResponseStart: => @socket.send("ai:")
    aiResponseStream: (fragment) => @socket.send("ai+ "+fragment)
    aiResponseEnd: => @socket.send("ai/")

    setSession: (key) =>
        @key = key
        @socket.send("key "+key)
        return

    noticeInvalidKey: => @socket.send("err InvalidKey")
    noticeMessageLimitReached: => @socket.send("err MessageLimit")
    noticeTooFast: => @socket.send("err TooFast")
    noticeMessageTooLarge: => @socket.send("err MessageTooLarge")
    noticeApiUsageLimitReached: => @socket.sedn("err ApiUsageLimit")

    noticeState: (stateString) => @socket.send("stt "+stateString)

    blockThis: ->
        log "blockThis"
        bs.report("@wsimodule.blockThis usage violoation occured! (#{@meta.ip})")
        return unless @socket?
        @socket.close()
        @socket = null
        @onDisconnect() ## maybe unnecessary

        log "blockedIP is: "+@meta.ip
        blockIp(@meta.ip)
        return


############################################################
export onConnect = (socket, req) ->
    log "onConnect"
    meta = req.meta
    key = ""+meta.ip+":"+meta.host+"("+meta.userAgent+")"
    conn = new SocketConnection(socket, "#{clientIdCount}", meta)
    clientIdCount++
    ## TODO 
    return


