ruler_get = {"select.*from"};
ruler_post = {'im.*test'};
reuler_upload = {};
logpath = '/tmp/';

ngx.header.Server = 'Ifengweb';
ngx.req.read_body()

function arg2string(args) 
    result = '';
    add = '';
    e = {"[(]+.*?[)]+","[']+.*?[']+",'["]+.*?["]+'}
    f = {'..[/]+..[/]+','[/]+[%a]+[/]+'};
    for key,val in pairs (args) do
        if type(val) == 'table' then 
            result = result..add..key..'=[%a:'..arg2string(val)..':]';
        elseif ngx.re.find(val,table.concat( e,'|'),'isjo') then
            result = result..add..key..'=[%e]';
        elseif ngx.re.find(val,'^[0-9]+$') then
            result = result..add..key..'=[%d]';
        elseif ngx.re.find(val,table.concat( f,'|'),'isjo') then
            result = result..add..key..'=[%f]';
        else
            result = result..add..key..'=[%s]';
        end
        add = '&';
    end;
    return result;
end

function safe_check(value,ruler)
    -- ngx.say(table.concat(value,'***')..table.concat(ruler,"|"));

    for key,value in pairs(value) do
        if type(value) == 'table' then
            value = table.concat(value,',');
        end
        if ngx.re.find(key,table.concat(ruler,"|"),'isjo') or ngx.re.find(value,table.concat(ruler,"|"),'isjo') then
            -- ngx.say('it works!')

            ips = '';
            add = '|';
            for headerip in pairs({'X-Real-IP','CLIENT-IP','X-FORWARDED-FOR'}) do
                tmp = ngx.req.get_headers()[headerip];
                if tmp ~= nil then
                    ips = ips..tmp..add;
                end
            end

            data = {};
            data['gpc_path'] = 'get';
            data['key'] = key;
            data['value'] = value;
            data['filename'] = ngx.var.uri;
            data['remote_addr'] = ngx.var.remote_addr..ips;
            log(logpath,data);
            ngx.exit(403);
        end
    end
end


function data_set(db,key,data)
   return db:safe_set(key,data);
end

function data_get(db,key)
    if db:get(key) ~= nil then
        return db:get(key);
    else
        return '';
    end
end


function  log(path,value)
  if type(value) == 'table' then
        logdata = {};
        for key,val in pairs(value) do 
            table.insert(logdata,'{#'..ngx.escape_uri(key)..'#'..ngx.escape_uri(val)..'#}');
        end
        value = table.concat( logdata, " ");
    end;

    local filename = logpath..'/iswaf_'..ngx.var.server_name..'_'..ngx.today()..'.log';
    fp = io.open(filename,'a+');
    if fp ~= nil then
        fp:write(value.."\n");
        fp:close();
    end
end


local test = ngx.shared.iswaf;
local get  = ngx.req.get_uri_args();
local post = ngx.req.get_post_args();


-- ngx.header.content_type = "text/plain";

-- ngx.say(get_string);

if get ~= nil then
    safe_check(get,ruler_get);
    get_string = arg2string(get);
    if get_string ~= '' then
        key = ngx.var.uri..'|get|'..get_string;
        try = data_get(test,key);
        if try ~= '' then
            test:replace(key,try+1);
        else
             data_set(test,key,1);
        end
    end
end


if post ~= nil then
    safe_check(post,ruler_post);
    get_string = arg2string(post);
    if get_string ~= '' then
        key = ngx.var.uri..'|post|'..get_string;
        try = data_get(test,key);
        if try ~= '' then
            test:replace(key,try+1);
        else
             data_set(test,key,1);
        end
    end
end


if post ~= nil then
    safe_check(post,ruler_post);
end
