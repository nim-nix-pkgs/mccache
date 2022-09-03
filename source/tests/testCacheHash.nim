#
#                      mconnect solutions
#        (c) Copyright 2020 Abi Akindele (mconnect.biz)
#
#    See the file "LICENSE.md", included in this
#    distribution, for details about the copyright / license.
# 
#     Testing for Hash In-Memory Cache - Hash Table/Dictionary
#

import mccache/hashCache, json, unittest, os

# types and test-values
var
    cacheValue: JsonNode = parseJson("""{"firstName": "Abi", "lastName": "Akindele", "location": "Toronto-Canada"}""")
    cacheKey: string = """{"name": "Tab1", "location": "Toronto"}"""
    expiryTime: Positive = 5 # in seconds
    hashKey: string = """{"hash1": "Hash1", "hash2": "Hash2"}"""

test "should set and return valid cacheValue":
    # expiryTime = 5
    let setCache = setHashCache(cacheKey, hashKey, cacheValue, expiryTime )
    if setCache.ok:
        # get cache content
        let res = getHashCache(cacheKey, hashKey)
        echo "get-cache-response: ", res
        check res.ok == true
        check res.value == cacheValue
        check res.message == "task completed successfully" # cache task (delete) completed successfully
    else:
        check setCache.ok == false

test "should clear the cache and return nil/empty value":
    let cache = clearHashCache()
    if cache.ok:
        # get cache content
        let res = getHashCache(cacheKey, hashKey)
        echo "get-cache-response: ", res
        check cache.message == "task completed successfully"
        check res.ok == false
        check res.value == nil
        check res.message == "cache info does not exist"
    else:
        check cache.ok == false

test "should set and return valid cacheValue -> before timeout/expiration)":
    # change the expiry time to 2 seconds
    expiryTime = 2
    let setCache = setHashCache(cacheKey, hashKey, cacheValue, expiryTime )
    if setCache.ok:
        # get cache content
        let res = getHashCache(cacheKey, hashKey)
        echo "get-cache-response: ", res
        check res.ok == true
        check res.value == cacheValue
        check res.message == "task completed successfully"

test "should return nil value after timeout/expiration":
    # sleep for 3 seconds to ensure cache expired
    sleep(3000)
    # get cache content
    let res = getHashCache(cacheKey, hashKey)
    echo "get-cache-response: ", res
    check res.ok == false
    check res.value == nil
    check res.message == "cache expired and deleted"

test "should set and return valid cacheValue (repeat prior to deleteCache testing)":
    expiryTime = 10
    let setCache = setHashCache(cacheKey, hashKey, cacheValue, expiryTime )
    if setCache.ok:
        # get cache content
        let res = getHashCache(cacheKey, hashKey)
        echo "get-cache-response: ", res
        check res.ok == true
        check res.value == cacheValue
        check res.message == "task completed successfully"
    else:
        check setCache.ok == false

test "should delete the cache, by hash(default),  and return nil/empty value":
    let cache = deleteHashCache(cacheKey, hashKey)
    if cache.ok:
        # get cache content
        let res = getHashCache(cacheKey, hashKey)
        echo "get-cache-response: ", res
        check cache.message == "task completed successfully"
        check res.ok == false
        check res.value == nil
        check res.message == "cache info does not exist"
    else:
        check cache.ok == false

test "should set and return valid cacheValue (repeat prior to deleteCache testing)":
    expiryTime = 10
    let setCache = setHashCache(cacheKey, hashKey, cacheValue, expiryTime )
    if setCache.ok:
        # get cache content
        let res = getHashCache(cacheKey, hashKey)
        echo "get-cache-response: ", res
        check res.ok == true
        check res.value == cacheValue
        check res.message == "task completed successfully"
    else:
        check setCache.ok == false

test "should delete the cache, by key,  and return nil/empty value":
    let cache = deleteHashCache(cacheKey, hashKey, "key")
    if cache.ok:
        # get cache content
        let res = getHashCache(cacheKey, hashKey)
        echo "get-cache-response: ", res
        check cache.message == "task completed successfully"
        check res.ok == false
        check res.value == nil
        check res.message == "cache info does not exist"
    else:
        check cache.ok == false
