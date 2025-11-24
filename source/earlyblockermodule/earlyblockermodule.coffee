############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("earlyblockermodule")
#endregion

############################################################
import * as cfg from "./configmodule.js"

############################################################
legalOrigins = new Set()
blockedIPs = new Set()

############################################################
export initialize = ->
    log "initialize"
    legalOrigins.add(o) for o in cfg.legalOrigins
    content = new Array(...legalOrigins)
    log "legalOrigins: #{content}"   
    return


extractMetaData = (req) ->
    meta = Object.create(null)

    ## remote ip address
    forwardedFor = req.headers['x-forwarded-for']
    ## usually forwarded -> first entry in the list
    if typeof forwardedFor == "string" and forwardedFor.length > 6
        meta.ip = forwardedFor.split(",")[0]
    else meta.ip = req.socket.remoteAddress

    ## used hostname and user agent
    meta.host = req.headers['host']
    meta.userAgent = req.headers['user-agent']
    return meta

############################################################
export isBlocked = (ip, origin) ->
    log "isBlocked"
    ##TODO reimplement to analyse req instead of get ip and origin directly
    return false

    
    if blockedIPs.has(ip)
        log "blocked request with IP: #{ip}"
        return "IP blocked!"
    
    if !legalOrigins.has(origin)
        log "blocked request with origin: #{origin}"
        blockedIPs.add(ip)
        # console.error("Request failed due to blocked origin!")
        # console.error("Origin: #{origin}, IP:#{ip}")
        return "Illegal Origin!"
    
    log "passed!"
    return


############################################################
export blockIp = (ip) -> blockedIPs.add(ip)