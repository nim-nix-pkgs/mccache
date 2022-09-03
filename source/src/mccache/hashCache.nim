#
#                       mconnect solutions
#        (c) Copyright 2020 Abi Akindele (mconnect.biz)
#
#    See the file "LICENSE.md", included in this
#    distribution, for details about the copyright / license.
# 
#             Hash In-Memory Cache - Hash Table/Dictionary
#

import json, tables, times

## Type definition for the hash / cache values and response
type
    CacheValue* = ref object
        value*: JsonNode
        expire*: int64
    HashCacheValue* = Table[string, CacheValue]
    HashCacheResponse* = object
        ok*: bool
        message*: string
        value*: JsonNode

# Initialise hash-cache tables/objects
# var cacheRecord* = initTable[string, CacheValue]()
var mcCache* = initTable[string, HashCacheValue]()

# hash format
# const abc = {
#     key: {hashkey: {value: 1, expire: 2}}
# }

# secret keyCode for added security
const keyCode = "mcconnect_20200320_myjoy"

proc setHashCache*(key: string; hash: string, value: JsonNode; expire: int64 = 300): HashCacheResponse = 
    try:
        if key == "" or hash == "" or value == nil:
            return HashCacheResponse(ok: false, message: "cache key, hash and value are required", value: nil)
        
        let cacheKey = key & keyCode
        let hashKey = hash & keyCode
        
        if not mcCache.hasKey(hashKey):
            mcCache[hashKey] = HashCacheValue()
        
        if not mcCache[hashKey].hasKey(cacheKey):
            mcCache[hashKey][cacheKey] = CacheValue()
        
        mcCache[hashKey][cacheKey] = CacheValue(value: value, expire: toUnix(getTime()) + expire)
        return HashCacheResponse(
                ok: true,
                message: "task completed successfully",
                value: mcCache[hashKey][cacheKey].value)
    except:
        return HashCacheResponse(ok: false, 
                                message: getCurrentExceptionMsg() & " | error creating/setting cache information", 
                                value: nil)

proc getHashCache*(key, hash: string;): HashCacheResponse = 
    try:
        # Ensure valid cache-key and hash-key
        if key == "" or hash == "":
            return HashCacheResponse(ok: false, message: "cache key and hash are required")
        
        let cacheKey = key & keyCode
        let hashKey = hash & keyCode

        # get active (non-expired) cache content
        if mcCache.hasKey(hashKey) and (mcCache[hashKey]).hasKey(cacheKey) and mcCache[hashKey][cacheKey].expire > toUnix(getTime()):   
            return HashCacheResponse(
                ok: true,
                message: "task completed successfully",
                value: mcCache[hashKey][cacheKey].value )
        # Remove expired cache content by hash-key
        elif mcCache.hasKey(hashKey) and (mcCache[hashKey]).hasKey(cacheKey):
            mcCache[hashKey].del(cacheKey)
            return HashCacheResponse(ok: false, message: "cache expired and deleted", value: nil)
        else:
            return HashCacheResponse(ok: false, message: "cache info does not exist", value: nil)
    except:
        return HashCacheResponse(ok: false, 
                                message: getCurrentExceptionMsg() & " | error fetching cache information",
                                value: nil)

proc deleteHashCache*(key, hash: string; by: string = "hash"): HashCacheResponse = 
    try:
        if by == "key" and (hash == "" or key == ""):
            return HashCacheResponse(ok: false, message: "hash and cache keys are required", value: nil)
        
        if by == "hash" and hash == "":
            return HashCacheResponse(ok: false, message: "hash key is required", value: nil)

        let cacheKey = key & keyCode
        let hashKey = hash & keyCode

        if by == "hash" and mcCache.hasKey(hashKey):
            mcCache.del(hashKey)
            return HashCacheResponse(
                ok: true,
                message: "task completed successfully",
                value: nil)
        elif by == "key" and mcCache.hasKey(hashKey) and mcCache[hashKey].hasKey(cacheKey):
            mcCache[hashKey].del(cacheKey)
            return HashCacheResponse(
                ok: true,
                message: "task completed successfully",
                value: nil)
        else:
            return HashCacheResponse(ok: false, 
                                    message: "cache-record-value not found", 
                                    value: nil)
    except:
        return HashCacheResponse(ok: false, 
                                message: getCurrentExceptionMsg() & " | error deleting cache information", 
                                value: nil)

proc clearHashCache*() : HashCacheResponse = 
    try:
        # clear the cache (hash-table)
        mcCache.clear()
        
        return HashCacheResponse(ok: true, message: "task completed successfully", value: nil)
    except:
        return HashCacheResponse(ok: false, 
                                message: getCurrentExceptionMsg() & " | error clearing cache", 
                                value: nil)
