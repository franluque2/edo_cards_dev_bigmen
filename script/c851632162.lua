--Celtic Guardian of Pride
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(Cost.SelfDiscard)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg2)
	c:RegisterEffect(e2)
end
s.listed_names={11082056,CARD_BLUEEYES_W_DRAGON,85800949} --Fang of Critias, Blue-Eyes White Dragon, Legendary Knight Critias
s.listed_series={SET_CELTIC_GUARD}


function s.thfilter(c)
	return ((c:IsSetCard(SET_CELTIC_GUARD) and not c:IsCode(id)) or c:IsCode(11082056)) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end

    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE|PHASE_END)
    Duel.RegisterEffect(e1,tp)
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_FUSION)
end


function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.Remove(c,POS_FACEUP,REASON_COST)
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST|REASON_DISCARD)
end

function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=s.sptarget(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=s.sptarget2(e,tp,eg,ep,ev,re,r,rp,0)
	local b3=s.settarget(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return b1 or b2 or b3 end
	local ops={}
	local opval={}
	local off=1
	if b1 then
		ops[off]=aux.Stringid(id,2)
		opval[off-1]=1
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(id,3)
		opval[off-1]=2
		off=off+1
	end
	if b3 then
		ops[off]=aux.Stringid(id,4)
		opval[off-1]=3
		off=off+1
	end
	local op=Duel.SelectOption(tp,table.unpack(ops))
	local sel=opval[op]
	if sel==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetOperation(s.spop)
		s.sptarget(e,tp,eg,ep,ev,re,r,rp,1)
	elseif sel==2 then
        e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetOperation(s.spop2)
		s.sptarget2(e,tp,eg,ep,ev,re,r,rp,1)
	elseif sel==3 then
		e:SetOperation(s.setop)
		s.settarget(e,tp,eg,ep,ev,re,r,rp,1)
	else
		e:SetCategory(0)
		e:SetOperation(nil)
	end
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.filter, tp, LOCATION_DECK|LOCATION_HAND|LOCATION_GRAVE, 0, nil, e, tp)
    if #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=g:Select(tp,1,1,nil)
        Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
    end
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.filter2, tp, LOCATION_DECK|LOCATION_HAND|LOCATION_GRAVE, 0, nil, e, tp)
    if #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=g:Select(tp,1,1,nil)
        Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
    end
end


function s.filter(c,e,tp)
	return c:IsCode(CARD_BLUEEYES_W_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK|LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_HAND|LOCATION_GRAVE)
end


function s.filter2(c,e,tp)
	return c:IsCode(85800949) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.sptarget2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK|LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_HAND)
end

function s.spfilter(c,code)
	return c:IsType(TYPE_FUSION) and c.material_trap and code==c.material_trap
end
function s.tgfilter(c)
	return c:IsTrap() and c:IsAbleToGrave() and Duel.IsExistingMatchingCard(s.spfilter,c:GetControler(),LOCATION_EXTRA,0,1,nil,c:GetCode())
end
function s.settarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.tgfilter, tp, LOCATION_DECK, 0, nil)
    if #g>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
        local sg=g:Select(tp,1,1,nil)
        local tc=sg:GetFirst()
        local tc2=Duel.GetFirstMatchingCard(s.spfilter, tp, LOCATION_EXTRA, 0, nil, tc:GetCode())
        if tc2 then
            Duel.ConfirmCards(1-tp, tc2)
            if Duel.SSet(tp, tc, tp, true) then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CANNOT_TRIGGER)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				tc:RegisterEffect(e1)

				tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1)
				local e3=Effect.CreateEffect(e:GetHandler())
				e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e3:SetCode(EVENT_PHASE+PHASE_END)
				e3:SetCountLimit(1)
				e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				e3:SetLabelObject(tc)
				e3:SetCondition(s.rmcon)
				e3:SetOperation(s.rmop)
				Duel.RegisterEffect(e3,tp)
			end
        end
    end
end

function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(id)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end