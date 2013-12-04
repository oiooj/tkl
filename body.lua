get  = ngx.req.get_uri_args();

local test = ngx.shared.iswaf;
key = ngx.var.uri..'|status|'..ngx.status;
ngx.req.clear_header('X-Powered-By');
past = test:get(key)
if past == nil then
	test:safe_set(key,1)
else
	test:safe_set(key,past+1)
end

if get['status'] == 'yes' then
    ngx.arg[1] = string.upper(ngx.status);
    ngx.arg[2] = true;
end