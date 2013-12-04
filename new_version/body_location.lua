get  = ngx.req.get_uri_args();
local iswaf = ngx.shared.iswaf;
key = ngx.var.uri..'|status|'..ngx.status;
past = iswaf:get(key)
if past == nil then
	iswaf:safe_set(key,1)
else
	iswaf:safe_set(key,past+1)
end

if get['status'] == 'yes' then
    ngx.arg[1] = string.upper(ngx.status);
    ngx.arg[2] = true;
end

if get['tkl'] == 'debug' then
	local iswaf = ngx.shared.iswaf;

	ids = iswaf:get_keys();
	ngx.header.content_type = "text/plain";

	data = '';
	for id,val in pairs(ids) do
		data = data.."\n"..val.."\n"..iswaf:get(val).."\n";
	end
	ngx.arg[1] = data;
	ngx.arg[2] = true;
end