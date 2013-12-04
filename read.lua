ngx.req.read_body();

local test = ngx.shared.iswaf;

ids = test:get_keys();


ngx.header.content_type = "text/plain";

for id,val in pairs(ids) do
	ngx.say(val);
	ngx.say(test:get(val))
end