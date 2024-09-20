--Lawn Mowing Next Door
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
	--discard deck
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.distarget)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
end
function s.distarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
    Duel.SetPossibleOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,5)

end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
    local val=1
    local p=tp
    local continue=true
	while continue do
        if Duel.DiscardDeck(p,val,REASON_EFFECT) and Duel.IsPlayerCanDiscardDeck(1-p,val*2) and Duel.SelectYesNo(1-p, aux.Stringid(id, 0)) then
            p=1-p
            val=val*2
        else
            continue=false
        end

    end
end
