gpc = {};
tmp = ngx.req.get_uri_args();
if tmp ~= nil then
    gpc['get'] = tmp;
end

tmp = ngx.req.get_post_args();
if tmp ~= nil then
    gpc['post'] = tmp;
end

get  = gpc['get'];


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

if ruler['response'] ~= nil and ngx.arg[1] ~= nil then
	if ngx.re.find(ngx.arg[1],table.concat(ruler['response'], "|"),'isjo') then
		ips = '';
        add = '|';
        for headerip in pairs({'X-Real-IP','CLIENT-IP','X-FORWARDED-FOR'}) do
            tmp = ngx.req.get_headers()[headerip];
            if tmp ~= nil then
                ips = ips..tmp..add;
            end
        end

		data = {};
		for key,val in pairs(gpc) do
			data[key] =  ngx.encode_args(gpc[key]);
		end
		data['type'] = 'response';
        data['key'] = key;
        data['value'] = value;
        data['filename'] = ngx.var.uri;
        data['remote_addr'] = ngx.var.remote_addr..ips;
        data['response'] = ngx.arg[1];
        log(logpath,data);

        if get ~= nil and get['replace'] ~= nil then
        	ngx.arg[1] = ngx.re.gsub(ngx.arg[1],table.concat(ruler['response'], "|"),'******')
        end
    end
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