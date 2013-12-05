ruler = {};
ruler['get'] = {"select.*from"};
ruler['post'] = {'im.*test'};
ruler['response'] = {'libaokun','yangtong'}
logpath = '/tmp/';


function arg2string(args) 
    result = '';
    add = '';
    e = {"[(]+.*?[)]+","[']+.*?[']+",'["]+.*?["]+'}
    f = {'..[/]+..[/]+','[/]+[%a]+[/]+'};
    for key,val in pairs (args) do

        if type(val) == 'table' then 
            result = result..add..key..'=[%a:'..arg2string(val)..':]';
        elseif val == nil then
            result = result..add..key..'=[%n]';
        elseif type(val) == 'string' and ngx.re.find(val,table.concat( e,'|'),'isjo') then
            result = result..add..key..'=[%e]';
        elseif type(val) == 'string' and ngx.re.find(val,'^[0-9]+$') then
            result = result..add..key..'=[%d]';
        elseif type(val) == 'string' and ngx.re.find(val,table.concat( f,'|'),'isjo') then
            result = result..add..key..'=[%f]';
        else
            result = result..add..key..'=[%s]';
        end
        add = '&';
    end;
    return result;
end


function safe_check(value,ruler,gpcpath)

    if gpcpath == nil then
        gpcpath = 'undefined';
    end
    for key,value in pairs(value) do
        if type(value) == 'table' then
            value = table.concat(value,',');
        end
        if value ~= nil and type(value) == 'string' then
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
                data['gpc_path'] = gpcpath;
                data['key'] = key;
                data['value'] = value;
                data['filename'] = ngx.var.uri;
                data['remote_addr'] = ngx.var.remote_addr..ips;
                log(logpath,data);
                ngx.exit(403);
            end
        end
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
