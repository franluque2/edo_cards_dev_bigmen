--Khamsin of the Winds of Destruction

Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
--You can reveal this card from your Hand; Add 1 "Revengeance of the Desperados" from your Deck to your hand, then discard a card, also you cannot Special Summon "Jetstream Sam of the Winds of Destruction" for the rest of this turn.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,{id,1})
    e1:SetCost(s.thcost)
    e1:SetCondition(function (e) return not s.qphandcon(e) end)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

       --During the Main Phase: You can Special Summon this card from your Hand, then if you control no other monsters, you can, immediately after this effect resolves, Synchro Summon 1 monster from your Extra Deck, using only this monster and 1 monster in your hand as material (if your opponent activated 15 or more cards or effects this turn, you can treat this card's level as the other monster's).
        local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_HAND)
    e3:SetCountLimit(1,{id,2})
    e3:SetCondition(function (e) return not s.qphandcon(e) end)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)

    local e4=e3:Clone()
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
    e4:SetCondition(function (e) return s.qphandcon(e) and Duel.IsMainPhase() end)
    c:RegisterEffect(e4)
    Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,aux.FALSE)

end
s.listed_names={CARD_REVENGEANCE} --Revengeance of the Desperados

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
	Duel.ConfirmCards(1-tp,e:GetHandler())
end

function s.thfilter(c)
    return c:IsCode(CARD_REVENGEANCE) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.GetFlagEffect(tp, id)==0 end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    Duel.RegisterFlagEffect(tp, id, RESET_CHAIN, 0, 1)

end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
        Duel.ConfirmCards(1-tp,g)
        Duel.ShuffleHand(tp)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
        local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil)
        if #dg>0 then
            Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
        end
    end
    --You cannot Special Summon cards with this card's name for the rest of this turn.
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(_,c) return c:IsCode(id) end)
    e1:SetReset(RESET_PHASE|PHASE_END)
    Duel.RegisterEffect(e1,tp)
    
end

function s.qphandcon(e)
    return Duel.GetCustomActivityCount(id,1-e:GetHandlerPlayer(),ACTIVITY_CHAIN)>9
end




function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.scfilter1(c,e,tp,b1)
	local mg=Group.FromCards(c,e:GetHandler())
	return (b1 or not c:IsType(TYPE_TUNER)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(s.syncfilter,tp,LOCATION_EXTRA,0,1,nil,mg)
end
function s.syncfilter(c,mg)
	return c:IsSynchroSummonable(nil,mg)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and c:IsLocation(LOCATION_MZONE) and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==1 then
       	local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
        e3:SetCode(EFFECT_HAND_SYNCHRO)
        e3:SetLabel(id)
        e3:SetValue(s.synval)
        e3:SetReset(RESET_CHAIN)
        c:RegisterEffect(e3)

        local b1=Duel.GetCustomActivityCount(id,1-e:GetHandlerPlayer(),ACTIVITY_CHAIN)>14
        if b1 then
            	local e1=Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
                e1:SetCode(EFFECT_NONTUNER)
                e1:SetRange(LOCATION_MZONE)
                e1:SetReset(RESET_CHAIN)
                c:RegisterEffect(e1)
        end
        local g=Duel.GetMatchingGroup(s.scfilter1,tp,LOCATION_HAND,0,nil,e,tp,b1)
        if #g>0 and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
            local tc=g:Select(tp, 1, 1, nil):GetFirst()
            local mg=Group.FromCards(c, tc)
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
            local g2=Duel.GetMatchingGroup(s.syncfilter,tp,LOCATION_EXTRA,0,nil,mg)
            local sg=g2:Select(tp,1,1,nil)
		    Duel.SynchroSummon(tp,sg:GetFirst(),nil,mg)

        end

    end
end




function s.synval(e,c,sc)
	if c:IsLocation(LOCATION_HAND) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
		e1:SetLabel(id)
		e1:SetTarget(s.synchktg)
		c:RegisterEffect(e1)
		return true
	else return false end
end
function s.chk(c)
	if not c:IsHasEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK) then return false end
	local te={c:GetCardEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)}
	for i=1,#te do
		local e=te[i]
		if e:GetLabel()~=id then return false end
	end
	return true
end
function s.chk2(c)
	if not c:IsHasEffect(EFFECT_HAND_SYNCHRO) or c:IsHasEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK) then return false end
	local te={c:GetCardEffect(EFFECT_HAND_SYNCHRO)}
	for i=1,#te do
		local e=te[i]
		if e:GetLabel()==id then return true end
	end
	return false
end
function s.synchktg(e,c,sg,tg,ntg,tsg,ntsg)
	if c then
		local res=true
		if sg:IsExists(s.chk,1,c) or (not tg:IsExists(s.chk2,1,c) and not ntg:IsExists(s.chk2,1,c) 
			and not sg:IsExists(s.chk2,1,c)) then return false end
		local trg=tg:Filter(s.chk,nil)
		local ntrg=ntg:Filter(s.chk,nil)
		return res,trg,ntrg
	else
		return true
	end
end