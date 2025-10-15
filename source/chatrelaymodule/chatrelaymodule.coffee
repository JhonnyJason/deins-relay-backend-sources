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
export singleCompletion = (msg) ->
    log "singleCompletion"

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

# #openai sample code
#     // Send a new message to a thread
# export async function POST(request, { params: { threadId } }) {
#   const { content } = await request.json();

#   await openai.beta.threads.messages.create(threadId, {
#     role: "user",
#     content: content,
#   });

#   const stream = openai.beta.threads.runs.stream(threadId, {
#     assistant_id: assistantId,
#   });

#   return new Response(stream.toReadableStream());
# }