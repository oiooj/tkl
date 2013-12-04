local iswaf = ngx.shared.iswaf;
local gpc = {};

tmp = ngx.req.get_uri_args();
if tmp ~= nil then
	gpc['get'] = tmp;
end

tmp = ngx.req.get_post_args();
if tmp ~= nil then
	gpc['post'] = tmp;
end


for key,val in pairs(gpc) do
	safe_check(gpc[key],ruler[key]);
	get_string = arg2string(gpc[key]);
	if get_string ~= '' then
        mem_key = ngx.var.uri..'|'..key..'|'..get_string;
        try = iswaf:get(mem_key);
        if try ~= nil then
        	iswaf:replace(mem_key,try+1);
        else
        	iswaf:safe_set(mem_key,1);
        end
    end
end