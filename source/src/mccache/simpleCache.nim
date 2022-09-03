#
#                 mconnect solutions
#        (c) Copyright 2020 Abi Akindele (mconnect.biz)
#
#    See the file "LICENSE.md", included in this
#    distribution, for details about the copyright / license.
# 
#            Simple In-Memory Cache - Table/Dictionary
#

import json, tables, times

## Type definition for the cache value and response
type
    CacheValue* = ref object
        value*: JsonNode
        expire*: int64
    CacheResponse* = object
        ok*: bool
        message*: string
        value*: JsonNode

# Initialise cache table/object
var mcCache* = initTable[string, CacheValue]()

# secret keyCode for added security
const keyCode = "mcconnect_20200320_myjoy"

proc setCache*(key: string; value: JsonNode; expire: Positive = 300): CacheResponse = 
    try:
        if key == "" or value == nil:
            return CacheResponse(ok: false, message: "cache key and value are required", value: nil)
        
        let cacheKey = key & keyCode

        mcCache[cacheKey] = CacheValue(value: value, expire: toUnix(getTime()) + expire)
        
        return CacheResponse(ok: true, message: "task completed successfully", value: value)
    except:
            return CacheResponse(ok: false, message: getCurrentExceptionMsg() & " | error creating/setting cache information", value: nil)

proc getCache*(key: string;): CacheResponse = 
    try:
        if key == "":
            return CacheResponse(ok: false, message: "cache key is required", value: nil)

        let cacheKey = key & keyCode

        if mcCache.hasKey(cacheKey) and mcCache[cacheKey].expire > toUnix(getTime()):
            return CacheResponse(ok: true, message: "task completed successfully", value: mcCache[cacheKey].value)
        elif mcCache.hasKey(cacheKey):
            mcCache.del(cacheKey)
            return CacheResponse(ok: false, message: "cache expired and deleted", value: nil)
        else:
            return CacheResponse(ok: false, message: "cache info does not exist", value: nil)
    except:
        return CacheResponse(ok: false,
                            message: getCurrentExceptionMsg() & " | error fetching cache information",
                            value: nil)

proc deleteCache*(key: string;): CacheResponse = 
    try:
        if key == "":
            return CacheResponse(ok: false, message: "key is required", value: nil)

        let cacheKey = key & keyCode
        
        if mcCache.hasKey(cacheKey):
            mcCache.del(cacheKey)
            return CacheResponse( ok: true, message: "task completed successfully", value: nil)
        else:
            return CacheResponse(ok: false, message: "task not completed, cache-key not found", value: nil)
    except:
        return CacheResponse(ok: false, 
                            message: getCurrentExceptionMsg() & " | error deleting cache information",
                            value: nil)

proc clearCache*() : CacheResponse = 
    try:
        # clear the cache (table)
        mcCache.clear()
        
        return CacheResponse(ok: true, message: "task completed successfully", value: nil)
    except:
        return CacheResponse(ok: false, 
                            message: getCurrentExceptionMsg() & " | error clearing cache", 
                            value: nil)
