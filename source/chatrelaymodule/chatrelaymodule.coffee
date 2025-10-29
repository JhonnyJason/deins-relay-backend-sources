############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("chatrelaymodule")
#endregion

############################################################
import * as cfg from "./configmodule.js"

############################################################
import OpenAI from "openai"

############################################################
openAIClient = null

############################################################
export initialize = ->
    log "initialize"
    #Implement or Remove :-)
    openAIClient = new OpenAI( { apiKey: cfg.openAIKey } )
    return

############################################################
export singleCompletion = (msg, authCode) ->
    log "singleCompletion"

    oldMessages
    options = {
        prompt: {
            id: cfg.deins_prompt_1_id
        }
        
    }

    log "Sending starting request..."
    olog {options}

    response = await openAIClient.responses.create(options)
    log "Successfully retrieved Response!"
    return response.output_text