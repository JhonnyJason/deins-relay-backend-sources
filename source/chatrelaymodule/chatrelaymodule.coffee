############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("chatrelaymodule")
#endregion

############################################################
import OpenAI from "openai"
############################################################
import * as bs from "./bugsnitch.js"

############################################################
openAIClient = null
promptId = null
usage = 0

############################################################
usageLimit = 30

############################################################
export initialize = (c) ->
    log "initialize"
    promptId = c.deins_prompt_1_id
    openAIClient = new OpenAI( { apiKey: c.openAIKey } )
    
    if c.apiUsageLimit? then usageLimit = c.apiUsageLimit
    
    if c.apiUsageResetMS? then usageResetMS = c.apiUsageResetMS
    else usageResetMS = 18_000_000 # ~5h
    
    setInterval(usageReset, usageResetMS)
    return

############################################################
usageReset = -> usage = 0

############################################################
export generateStreamResponse = (msgs, conn) ->
    log "generateStreamResponse"
    log "currentUsage "+usage

    if usage == usageLimit 
        conn.noticeApiUsageLimitReached()
        bs.report("@generateStreamResponse API usage Limit reached! (#{usage})")
        return

    options = {
        input: msgs,
        stream: true,
        prompt: { id: promptId }
    }

    try
        usage++
        stream = await openAIClient.responses.create(options)

        conn.aiResponseStart()
        ## Use async Iterator
        for await evnt from stream then processEvent(evnt, conn)

        conn.aiResponseEnd()
    catch err then console.error(err)
    return

############################################################
processEvent = (evnt, sk) ->
    switch evnt.type
        when "response.output_text.delta"
            sk.aiResponseStream(evnt.delta)
        else olog evnt.type
    return
