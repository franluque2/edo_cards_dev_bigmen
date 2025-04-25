--Snared Crystal Beast Sapphire Pegasus (CT)
local s,id=GetID()
function s.initial_effect(c)

	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.pltg)
	e1:SetOperation(s.plop)
	c:RegisterEffect(e1)
    --Declare 1 Type to make this card that Type
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,{id,1})
	e4:SetTarget(s.changetypetg)
	e4:SetOperation(s.changetypeop)
	c:RegisterEffect(e4)

end

function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		if Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
        e:GetHandler():AddCounter(0x1107,1)
        local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
        if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
            Duel.BreakEffect()
            local g2=g:Select(tp,1,1,nil)
            if #g2>0 then
                Duel.SendtoHand(g2,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,g2)
            end
        end
	end
end
end
function s.thfilter(c)
	return c:IsCode(81632872, 511004337, 511004339, 511004327, 511004336, 511004328) and c:IsAbleToHand()
end

function s.changetypetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:SetLabel(e:GetHandler():AnnounceAnotherRace(tp))
end
function s.changetypeop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		--This card becomes that Type until the end of your opponent's turn
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESETS_STANDARD_DISABLE_PHASE_END|RESET_OPPO_TURN)
		c:RegisterEffect(e1)
	end
end