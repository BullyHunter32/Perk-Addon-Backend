net.Receive("bPerks.ImARetard", function()
    local ent = net.ReadEntity()
    local val = net.ReadString()
    local keys = net.ReadUInt(3)
    local key = ent

    local str
    for i = 1, keys do
        str = net.ReadString()
        if not str then
            break
        end
        if i == keys then 
            break 
        end
        key = ent[str]
    end
    if not IsValid(ent) then return end

    local entVal = key[str]
    if isbool(entVal) then
        key[str] = tobool(val)
    elseif isstring(entVal) then
        key[str] = val
    elseif isnumber(entVal) then
        key[str] = tonumber(val)
    end
end)