
function matchMostElements(matList)    
  if matList and #matList > 0 then
    local result = {}
    for i = 1, #matList do
      if type(matList[i]) == "table" then
        table.insert(result, {})
        
        for j = 1, #matList[i] do
          if matList[i] ~= nil and matList[i][j] ~= nil then
            table.insert(result[i], matList[i][j])
          end
        end
      end
    end
    
    local compare = function(a, b)         
      if type(a) == "table" and type(b) == "table" then
        if a[1] > b[1] then
          return false
        elseif a[1] == b[1] then  
          
          if #a > #b then          
            return true
            
          elseif #a == #b then            
            for i = 2, #a do
              if a[i] < b[i] then                
                return true
              elseif a[i] == b[i] then  
                return true
              else
                -- a[i] > b[i]
                return false
              end
            end
            return true
          else
            -- #a < #b
            return false
          end
        else
          -- a[1] < b[1]
          return true
        end
      end
      return false
    end
  
--    table.sort(result, compare)
    
    local function compare2(a, b)
      if #a > #b then
        return true
      else
        return false
      end
    end
    
    table.sort(result, compare2)
    
    local newMatList = {}
    local checked
    -- select matched most element in line
    for i = 1, #result do
      checked = true
      
      for j = 1, #newMatList do
        if type(newMatList[j]) == "table" and type(result[i]) == "table" then                
          local num = 0
          
          for pos = 1, #result[i] do
            if newMatList[j][pos] ~= nil and result[i][pos] == newMatList[j][pos] then
              num = num + 1
            end              
          end
          
          if num == #result[i] then
            checked = false
          end          
        end
      end -- for
      
      if checked then
        table.insert(newMatList, result[i])
      end
    end
    
    return newMatList
  end
  
  return nil
end


function main()
--  local list = {1,3,3,4,2,3}
--  table.sort(list, function(a, b) 
--    if b >= a then
--      return false
--    else
--      return true
--    end
--  end)
--  print(list)

  
  local list = {
    {2,3,1},
    {1,1,2},    
    {1,2,2,1},    
    {2,3,3},
    {1,2,2},
    {1,2,3,1},
    {2,3,1,3,3},
  }
  
  print(#list)
  
  local result = matchMostElements(list)
  
  print("")
end

main()