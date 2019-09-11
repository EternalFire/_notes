
function uniqueInsert(t, v)
    if not table.indexof(t, v) then
        table.insert(t, v)
    end
end
