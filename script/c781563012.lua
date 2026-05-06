--Heroic Utility Pouch
local s, id = GetID()
function s.initial_effect(c)
    --Normal Spell
    	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)

end

local EHERO_SPARKMAN = 20721928
local EHERO_CLAYMAN = 84327329
local EHERO_BURST = 58932615
local EHERO_AVIAN = 21844576
local EHERO_BLADEDGE = 59793705
local EHERO_WILDHEART = 86188410
local EHERO_BUBBLEMAN = 79979666
local EHERO_NEOS = 89943723

s.cardsperhero = {}
s.cardsperhero[0]={}
s.cardsperhero[1]={}


s.cardsperhero[EHERO_SPARKMAN] = { 97362768 }
s.cardsperhero[EHERO_CLAYMAN] = { 511000484, 511000998, 22479888 }
s.cardsperhero[EHERO_BURST] = { 27191436 } --511000021 Burst Impact, disabled for balance reasons
s.cardsperhero[EHERO_AVIAN] = { 19394153, 511000488, 71060915 }
s.cardsperhero[EHERO_BLADEDGE] = { 84361420 }
s.cardsperhero[EHERO_WILDHEART] = { 29612557, 511001353 }
s.cardsperhero[EHERO_BUBBLEMAN] = { 61968753, 80075749, 53586134, 511002154}
s.cardsperhero[EHERO_NEOS] = { 10186633,14088859,16169772,35255456,41933425,52098461,80170678,18302224,46570372,52553471,73239437,89058026,11913700,47274077,42015635,74414885,75047173 }


function s.filter(c)
	return c:IsFaceup() and c:IsCode(EHERO_SPARKMAN, EHERO_CLAYMAN, EHERO_BURST, EHERO_AVIAN, EHERO_BLADEDGE, EHERO_WILDHEART, EHERO_BUBBLEMAN, EHERO_NEOS)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
    s.announce_filter={}
    local code=g:GetFirst():GetCode()
    local hero_cards = s.cardsperhero[code]
    for _, cardcode in ipairs(hero_cards) do
        if #s.announce_filter==0 then
            table.insert(s.announce_filter,cardcode)
            table.insert(s.announce_filter,OPCODE_ISCODE)
        else
            table.insert(s.announce_filter,cardcode)
            table.insert(s.announce_filter,OPCODE_ISCODE)
            table.insert(s.announce_filter,OPCODE_OR)
        end
    end
    local ac=Duel.AnnounceCard(tp,table.unpack(s.announce_filter))
	Duel.SetTargetParam(ac)
    Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_CARD_FILTER)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local code=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
    local c=e:GetHandler()
    Card.Recreate(c, code, nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
    	if c:IsRelateToEffect(e) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		if c:IsHasEffect(EFFECT_CANNOT_TO_HAND) then return end
		c:CancelToGrave()
		Duel.SendtoHand(c, tp, REASON_EFFECT)
        Duel.ConfirmCards(1-tp, c)
	end

end