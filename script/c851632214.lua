--Vennominon the Promised Consort
local s,id=GetID()
function s.initial_effect(c)

    	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:SetCost(s.spcost)
    e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)


    	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)

    	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.spcon2)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)

    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_CHAIN_SOLVED)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(s.addcountercon)
    e4:SetOperation(s.addcounterop)
    c:RegisterEffect(e4)

    local e5=e4:Clone()
    e5:SetCode(EVENT_CUSTOM+54306223+1)
    e5:SetCondition(aux.TRUE)
    c:RegisterEffect(e5)
end
s.listed_series={0x50} -- Venom
s.listed_names={54306223, 8062132} -- Venom Swamp, Vennominaga the Deity of Poisonous Snakes


function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(Card.IsRace,c:GetControler(),LOCATION_GRAVE,0,nil,RACE_REPTILE)*500
end

function s.cfilter(c)
	return c:IsRace(RACE_REPTILE)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.cfilter,2,false,aux.ReleaseCheckMMZ,nil) end
	local g=Duel.SelectReleaseGroupCost(tp,s.cfilter,2,2,false,aux.ReleaseCheckMMZ,nil)
	Duel.Release(g,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,1,tp,tp,false,false,POS_FACEUP)
end


function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
function s.spfilter(c,e,tp)
	return c:IsCode(8062132) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP)
        Card.CompleteProcedure(g:GetFirst())
	end
end

function s.addcountercon(e,tp,eg,ep,ev,re,r,rp)
    --COUNTER_VENOM
    return re and re:GetHandler():IsOriginalCode(54306223) and re:IsHasCategory(CATEGORY_COUNTER)
end

function s.addcounterop(e,tp,eg,ep,ev,re,r,rp)
    local g=Group.CreateGroup()
    local tg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
    tg=tg:Filter(Card.IsMonster, nil)
    local tc=tg:GetFirst()
    for tc in aux.Next(tg) do
        if not tc:IsSetCard(SET_VENOM) then
            local atk=tc:GetAttack()
            for i=1,ev do
                tc:RegisterFlagEffect(id, RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD, 0, 0)
            end
            if atk>0 and tc:GetAttack()-(tc:GetFlagEffect(id)*500)<=0 then
                g:AddCard(tc)
            end
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetCategory(CATEGORY_COUNTER)
            e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
            e1:SetCode(EVENT_SUMMON_SUCCESS)
            e1:SetCountLimit(1,{id,8})
            e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
            e1:SetOperation(s.addc)
            tc:RegisterEffect(e1)

            local e2=e1:Clone()
            e2:SetCode(EVENT_SPSUMMON_SUCCESS)
            tc:RegisterEffect(e2)

            local e3=e1:Clone()
            e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
            tc:RegisterEffect(e3)
        end
    end
    if #g>0 then
        Duel.RaiseEvent(g,EVENT_CUSTOM+54306223,e,0,0,0,0)
    end
end

function s.addc(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(COUNTER_VENOM,e:GetHandler():GetFlagEffect(id))
end