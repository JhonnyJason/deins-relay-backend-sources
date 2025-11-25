############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("earlyblockermodule")
#endregion

############################################################
import * as cfg from "./configmodule.js"

############################################################
legalHostnames = new Set()
blockedIPs = new Set()
probationIPs = new Set()

############################################################
export initialize = (c) ->
    log "initialize"
    if c.legalHostnames? 
        legalHostnames.add(o) for o in c.legalHostnames
    
    if c.probationPeriodMS? then probationPeriodMS = c.probationPeriodMS
    else probationPeriodMS = 7_200_000

    content = new Array(...legalHostnames)
    log "legalHostnames: #{content}"
    setInterval(reorderBlocked, probationPeriodMS)
    return


############################################################
reorderBlocked = ->
    log "reorderBlocked"
    toFree = Array.from(probationIPs)
    blockedIPs.delete(ip) for ip in toFree

    probationIPs = new Set(blockedIPs)
    return

############################################################
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
export isBlocked = (req) ->
    log "isBlocked"
    meta = extractMetaData(req)
    req.meta = meta
    olog meta
    # return false

    if blockedIPs.has(meta.ip)
        log "blocked request with IP: #{meta.ip}"
        return "IP blocked!"
    
    if !legalHostnames.has(meta.host)
        log "blocked request with origin: #{meta.host}"
        blockedIPs.add(meta.ip)
        # console.error("Request failed due to blocked Hostname!")
        # console.error("Hostname: #{meta.host}, IP:#{meta.ip}")
        return "Illegal Hostname!"
    
    log "passed!"
    return

############################################################
export blockIp = (ip) -> 
    blockedIPs.add(ip)
    probationIPs.delete(ip)
    return