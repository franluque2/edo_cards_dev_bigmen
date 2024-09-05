--Spindel, Spiderite Matriarch
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    c:SetSPSummonOnce(id)
	Fusion.AddProcMixN(c,true,true,CARD_SPIDERITELING,3)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)

    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_CONJURE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.bancon)
    e1:SetCost(s.bancost)
	e1:SetOperation(s.banop)
	c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_CONJURE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)

end
s.listed_names={CARD_SPIDERITELING}
s.listed_series={SET_SPIDERITE}


function s.thfilter(c)
	return c:IsCode(CARD_SPIDERITELING) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
    Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_ONFIELD)

end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then 
            local dg=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
            if #dg>0 and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
                dg=dg:Select(tp,1,1,nil)
                Duel.HintSelection(dg,true)
                Duel.BreakEffect()
                Duel.Destroy(dg,REASON_EFFECT)
        end
    end
	end
end



function s.bancon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and Duel.IsPlayerCanRemove(tp, e:GetHandler())
end
function s.bancost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Card.IsPublic(e:GetHandler()) end
	Duel.ConfirmCards(1-tp, e:GetHandler())
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
    local Spideriteling=WbAux.GetSpideriteling(tp)
    Duel.Remove(Spideriteling, POS_FACEUP, REASON_EFFECT)

end

function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
end
function s.contactop(g)
	Duel.Remove(g,POS_FACEUP,REASON_COST|REASON_MATERIAL)
end