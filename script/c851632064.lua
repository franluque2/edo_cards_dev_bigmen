--Lost Kuribot
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_CONJURE+CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end

function s.sumfilter(c)
	return c:IsSummonable(true,nil)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.IsExistingMatchingCard(s.sumfilter, tp, LOCATION_HAND+LOCATION_MZONE,0, 1, nil) or ((Duel.GetMatchingGroupCount(aux.TRUE, tp, LOCATION_MZONE, 0, e:GetHandler())==0) and Duel.CheckLPCost(tp, 500))) end
	local sel=0
	local ac=0
	if ((Duel.GetMatchingGroupCount(aux.TRUE, tp, LOCATION_MZONE, 0, e:GetHandler())==0) and Duel.CheckLPCost(tp, 500)) then sel=sel+1 end
	if Duel.IsExistingMatchingCard(s.sumfilter, tp, LOCATION_HAND+LOCATION_MZONE,0, 1, nil)  then sel=sel+2 end
	if sel==1 then
		ac=Duel.SelectOption(tp,aux.Stringid(id,0))
	elseif sel==2 then
		ac=Duel.SelectOption(tp,aux.Stringid(id,1))+1
	else
		ac=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))
	end
	e:SetLabel(ac)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local ac=e:GetLabel()
	if ac==0 or ac==2 then
        Duel.PayLPCost(tp, 500)
        local Kuribot=Duel.CreateToken(tp, id)
        Duel.SendtoHand(Kuribot, tp, REASON_EFFECT)
        Duel.ConfirmCards(1-tp, Kuribot)
	end
	if ac==1 or ac==2 then
		local sg1=Duel.GetMatchingGroup(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
		if #sg1>0 then
			Duel.BreakEffect()
			Duel.ShuffleHand(tp)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
			local sg2=sg1:Select(tp,1,1,nil):GetFirst()
			Duel.Summon(tp,sg2,true,nil)
		end
	end
end
