--Crafting Fusion
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)	
    local e1=Fusion.CreateSummonEff({handler=c,fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_MINECRAFT),
    extrafil=s.fextra,extraop=s.extraop,extratg=s.extratg})
    e1:SetHintTiming(0,TIMING_MAIN_END)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(s.thtg)
    e2:SetCountLimit(1,id)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)



end
s.listed_series={SET_MINECRAFT}

function s.thfilter(c)
	return (c:IsSetCard(SET_MINECRAFT) or c:IsRace(RACE_ROCK)) and c:IsMonster() and c:IsFaceup()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_REMOVED) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_REMOVED,0,3,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
    local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_REMOVED,0,3,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=tg:Filter(Card.IsRelateToEffect,nil,e)
	if #sg>0 then
		if Duel.SendtoGrave(sg,REASON_EFFECT+REASON_RETURN)>0 then
            local c=e:GetHandler()
            if c:IsRelateToEffect(e) then
                Duel.SendtoHand(c,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,c)
            end
        
        end
	end

end


function s.fuwarrminecraftfilter(c)
    return c:IsFaceup() and c:IsMonster() and c:IsRace(RACE_WARRIOR) and c:IsSetCard(SET_MINECRAFT)
end

function s.exfilter0(c)
	return c:IsMonster() and c:IsAbleToRemove()
end
function s.fextra(e,tp,mg)
	if Duel.IsExistingMatchingCard(s.fuwarrminecraftfilter, tp, LOCATION_MZONE, 0, 1, nil) and 
    not Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then
		local eg=Duel.GetMatchingGroup(s.exfilter0,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
		if #eg>0 then
			return eg
		end
	end
	return nil
end
function s.extraop(e,tc,tp,sg)
	local rg=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #rg>0 then
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)
		sg:Sub(rg)
	end
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_GRAVE)
end