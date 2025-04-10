--Collection of Memories
local s,id=GetID()
function s.initial_effect(c)
	--Activate Skill
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)

end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)



	end
	e:SetLabel(1)
end

local numbers={26556950, 51543904, 49032236, 58820923, 1992816, 97403510, 73445448, 31801517, 89516305, 48995978, 
2978414, 28400508, 63767246, 75433814, 8165596, 23085002, 66547759, 88120966, 95474755, 16037007, 92015800, 80117527,
 53701457, 82308875, 10389142, 64554883, 9161357, 75253697, 93713837, 57707471, 21313376, 29669359, 19333131, 39139935,
  36076683, 62070231, 35772782, 55067058, 23998625, 90126061, 42421606, 65676461, 37279508, 2407234, 76067258, 11411223,
   84417082, 47387961, 46871387, 80796456, 71921856, 23649496, 8387138, 51735257, 50260683, 55470553, 31437713, 80764541,
    66011101, 93108839, 53244294, 7194917, 93568288, 81330115, 56292140, 31320433, 69610924, 47805931, 1426714, 39622156,
     16259549, 32003338, 59479050, 29208536, 54191698, 3790062, 39972129, 55727845, 56051086, 55935416, 48928529, 69058960,
      95442074, 54366836, 89642993, 29085954}

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,0),nil)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	Duel.SendtoDeck(e:GetHandler(), tp, -2, REASON_EFFECT)
	if e:GetHandler():GetPreviousLocation()==LOCATION_HAND then
		Duel.Draw(tp, 1, REASON_EFFECT)
	end

    local subnumbers={}
    while #subnumbers < 5 do
        local num=Duel.GetRandomNumber(1, #numbers)
        if not s.contains(subnumbers, numbers[num]) then
            table.insert(subnumbers, numbers[num])
        end
    end
    local val=Duel.SelectCardsFromCodes(tp,1,1,false,false,subnumbers)
    local token=Duel.CreateToken(tp, val)
    Duel.SendtoDeck(token, tp, SEQ_DECKSHUFFLE, REASON_RULE)
    Duel.ConfirmCards(1-tp, token)
end

function s.contains(tbl, val)
    for _, v in ipairs(tbl) do
        if v == val then
            return true
        end
    end
    return false
end