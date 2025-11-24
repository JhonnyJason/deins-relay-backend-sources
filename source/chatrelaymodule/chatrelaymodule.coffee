############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("chatrelaymodule")
#endregion

############################################################
import OpenAI from "openai"

############################################################
openAIClient = null
promptId = null

############################################################
export initialize = (c) ->
    log "initialize"
    promptId = c.deins_prompt_1_id
    openAIClient = new OpenAI( { apiKey: c.openAIKey } )
    # log c.openAIKey
    return

############################################################
export generateStreamResponse = (msgs, conn) ->
    log "generateStreamResponse"

    options = {
        input: msgs,
        stream: true,
        prompt: { id: promptId }
    }

    stream = await openAIClient.responses.create(options)

    conn.aiResponseStart()
    ## Use async Iterator
    for await evnt from stream then processEvent(evnt, conn)

    conn.aiResponseEnd()
    return

############################################################
processEvent = (evnt, sk) ->
    switch evnt.type
        when "response.output_text.delta"
            sk.aiResponseStream(evnt.delta)
        else olog evnt.type
    return
