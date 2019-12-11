
GAME_PLAYER				=3			--游戏人数

BOTTOM_CARD				=3			--底牌数目
INIT_CARD				=20
FARM_HAND_CARD			=17
LORD_HAND_CARD			=20

CARD_DATA				=2			

FULL_COUNT				=52			--全牌数目

MAX_COUNT				=5			--最大数目
MAX_CENTERCOUNT			=5			--最大数目

CARD_MASK_COLOR			=0xF0		--花色掩码
CARD_MASK_VALUE			=0x0F		--数值掩码

INVALID_ITEM			=0xFFFF		--无效子项

MY_VIEWID				=1
R_VIEWID				=2
L_VIEWID				=3

FIRST_POS				= cc.p(137.33,92.0)
SENCOND_POS				= cc.p(192.15,92.0)
TENTH_POS				= cc.p(630.65,92.0)
ELEVENTH_POS			= cc.p(685.47,92.0)

CARD_SPACE  			= 58.56		--间隔
SPACE_COUNT 			= 15
CARD_SPACE2 			= 90		--间隔
CARD_UP     			= 28		--弹起高度

C_FIRST_POS				= cc.p(50.90 ,52.57)
C_ELEVENTH_POS			= cc.p(338.07,52.57)
C_TENTH_POS				= cc.p(309.33,52.57)
C_SPACE 				= 28.74

O_FIRST_POS				= cc.p( 36.60, 109.68)
O_SECOND_POS			= cc.p( 61.83, 109.68)
O_TENTH_POS				= cc.p(263.80, 109.68)
O_ELEVENTH_POS			= cc.p( 36.60, 51.30)
O_FOURTEENTH_POS		= cc.p( 112.32,51.30)
O_FIFTEENTH_POS			= cc.p(137.58, 51.30)
O_SIXTEENTH_POS			= cc.p(162.81, 51.30)
O_TWENTIETH_POS			= cc.p(263.80, 51.30)
O_SPACE					= 25.23

CARD_SIZE				= cc.size(150 , 208)
CARD_SIZE2				= cc.size(75  , 104)

---------------------------------------------------------------------------------
POKER_STYLE_DIAMONDS = 0
POKER_STYLE_CLUBS	 = 1
POKER_STYLE_HEARTS	 = 2
POKER_STYLE_SPADES	 = 3
POKER_STYLE_EX		 = 4

POKER_VALUE_A		= 1
POKER_VALUE_2		= 2
POKER_VALUE_3		= 3
POKER_VALUE_4		= 4
POKER_VALUE_5		= 5
POKER_VALUE_6		= 6
POKER_VALUE_7		= 7
POKER_VALUE_8		= 8
POKER_VALUE_9		= 9
POKER_VALUE_10		= 10
POKER_VALUE_J		= 11
POKER_VALUE_Q		= 12
POKER_VALUE_K		= 13

PV_A 	= POKER_VALUE_K + 1
PV_2   	= PV_A + 1
PV_S 	= PV_2 + 1
PV_L  	= PV_S + 1

POKER_VALUE_JOKER_SMALL	= 1
POKER_VALUE_JOKER_LARGE	= 2
POKER_VALUE_BACK_0		= 3


function _fixpv( value,color )
	if color == POKER_STYLE_EX then
		if value == POKER_VALUE_JOKER_SMALL then
			return PV_S
		elseif value == POKER_VALUE_JOKER_LARGE then
			return PV_L
		end
	end
	if value == POKER_VALUE_A then
		return PV_A
	elseif value == POKER_VALUE_2 then
		return PV_2
	end
	return value
end

function _fixlogicpv(data)
	return _fixpv(data[1],data[2])
end

function _findSameValue( value,data )
	local len = #data
	local count = 0
	for i=1,len do
		if value == _fixlogicpv(data[i]) then
			count = count + 1
		end
	end
	return count
end

function _sortfunc( data1,data2 )
	
	if _fixlogicpv(data1) == _fixlogicpv(data2) then
		return data1[2] > data2[2]
	end

	return _fixlogicpv(data1) > _fixlogicpv(data2)

end

function _removefunc( tab,data )
	if tab==nil then 
		return nil
	end
	for i=1,#tab do
		if tab[i][1]==data[1] and tab[i][2]==data[2] then
		--	print("_removefunc",data[1],data[2],#tab)
			table.remove(tab,i)
		--	print(#tab,i)
			return i
		end
	end
	return nil
end

function _equalfunc( tab1 , tab2 )
	if type(tab1) ~= "table" or type(tab2) ~= "table" then
		return false
	end
    
    local len1 = #tab1
    local len2 = #tab2
    if len1 ~= len2 then
        return false
    end
    for i=1,len1 do
        if tab1[i][1]==tab2[i][1] and tab1[i][2]==tab2[i][2] then
        	
        else

            return false
        end
    end
    return true
end

function _getnext( nViewID )
    local nexter = nViewID + 1
    if nexter > GAME_PLAYER then
        nexter = 1
    end
    return nexter
end

function _getprevious( nViewID )
	local pre = nViewID - 1
	if pre <= 0 then
		pre = GAME_PLAYER
	end
	return pre
end
