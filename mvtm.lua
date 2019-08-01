local function close_redis(red)  
    if not red then  
        return  
    end  
    local ok, err = red:close()  
    if not ok then  
        ngx.say("close redis error : ", err)  
    end  
end  

local function getKey(p_ch, p_app, p_t1, p_t2)

    t1,t2 = math.modf((p_t1 - p_t2)/5);
    t1 = t1 * 5
    redkey = p_ch.."_"..p_app.."_"..t1
    return redkey
end
  
local args = ngx.req.get_uri_args()

local app= args["app"]
local ch= args["ch"]
local time2 = os.time()
local mvtm = args["mvtm"]

--t1,t2 = math.modf((time2-mvtm)/5);
--t1 = t1 * 5
--key = ch.."_"..app.."_"..t1

--local key = getKey(ch, app, time2, mvtm)

local redis = require("resty.redis")  
  
--创建实例  
local red = redis:new()  
--设置超时（毫秒）  
red:set_timeout(1000)  
--建立连接  
local ip = "127.0.0.1"  
local port = 6379  
local ok, err = red:connect(ip, port)  
if not ok then  
    ngx.say("connect to redis error : ", err)  
    ngx.exit(404)
    return close_redis(red)  
end 

ngx.header.content_type = "text/plain"

--调用API获取数据  
local resp, err = red:get(getKey(ch, app, time2, mvtm))  
if not resp then  
    ngx.say("get msg error : ", err)  
    ngx.exit(404)
    return close_redis(red)  
end  
--得到的数据为空处理,则再重试二次;  
if resp == ngx.null then  

    resp, err = red:get(getKey(ch, app, time2-5, mvtm))

    if resp == ngx.null then 
        resp, err = red:get(getKey(ch, app, time2-10, mvtm))
    end
end

close_redis(red)

if resp == ngx.null then  
    
    ngx.say("")  
    ngx.exit(404)

else
    ngx.say(resp)  
    ngx.exit(200)
end
