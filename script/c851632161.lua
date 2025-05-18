--Celtic Guardian of Tenacity
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
s.listed_names={46232525,CARD_REDEYES_B_DRAGON,84565800} --Claw of Hermos, Red-Eyes Black Dragon, Legendary Knight Hermos
s.listed_series={SET_CELTIC_GUARD}


function s.thfilter(c)
	return ((c:IsSetCard(SET_CELTIC_GUARD) and not c:IsCode(id)) or c:IsCode(46232525)) and c:IsAbleToHand()
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
	local b3=s.sptarget3(e,tp,eg,ep,ev,re,r,rp,0)
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
        e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetOperation(s.spop3)
		s.sptarget3(e,tp,eg,ep,ev,re,r,rp,1)
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
	return c:IsCode(CARD_REDEYES_B_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK|LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_HAND|LOCATION_GRAVE)
end


function s.filter2(c,e,tp)
	return c:IsCode(84565800) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.sptarget2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK|LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_HAND)
end


function s.filter3(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_WARRIOR|RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
function s.sptarget3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter3,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end

function s.spop3(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.filter3, tp, LOCATION_DECK|LOCATION_GRAVE, 0, nil, e, tp)
    if #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=g:Select(tp,1,1,nil)
        Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEDOWN_DEFENSE)
        Duel.ConfirmCards(1-tp,sg)
    end
end