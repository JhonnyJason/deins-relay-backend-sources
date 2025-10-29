############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("wsimodule")
#endregion

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

    onMessage: (evnt) ->
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
                when "authorizeMe" then authorizationProcess(@socket)
                when "retrieveInterference" then interferenceProcess(@socket, arg)
                when "resetHistory" then resetHistoryProces(@socket), arg
                else throw new Error("unknown command: #{command}")

        catch err then log err
        return

    onDisconnect: (evnt) ->
        log "onDisconnect: #{@clientId}"
        try
            #TODO implment some unsubscribing  
        catch err then log err
        return
    
############################################################
#region started Processes on specific Commands
relayCompletionQuery = (socket) -> 
    log "relayCompletionQuery"
    try
        log "Not yet Inquiring for Completion..."
        response = "We don't do this yet."
        socket.send(response)
    catch err then log err
    return


#


############################################################
export onConnect = (socket, req) ->
    olog req.body 
    conn = new SocketConnection(socket, "#{clientIdCount}")
    clientIdCount++
    ## TODO 
    return
