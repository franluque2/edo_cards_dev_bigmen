--Countdown to Extinction
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,2,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)


	end
	e:SetLabel(1)
end


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	--start of duel effects go here

	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(s.flipcon2)
	e1:SetOperation(s.flipop2)
	Duel.RegisterEffect(e1,tp)

    local e2=e1:Clone()
    e2:SetCode(EVENT_REMOVE)
    Duel.RegisterEffect(e2, tp)

    local e8=e1:Clone()
    e8:SetCode(EVENT_TO_DECK)
    e8:SetCondition(s.flipconextra)
    Duel.RegisterEffect(e8, tp)



	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_ADJUST)
	e3:SetCondition(s.flipcon3)
	e3:SetOperation(s.flipop3)
	Duel.RegisterEffect(e3,tp)

	local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetType(EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(s.flipcon4)
	e4:SetOperation(s.flipop4)
	Duel.RegisterEffect(e4,tp)

	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_NEGATED)
	Duel.RegisterEffect(e5,tp)

	local e6=e4:Clone()
	e6:SetCode(EVENT_SUMMON_NEGATED)
	Duel.RegisterEffect(e6,tp)

	local e7=e4:Clone()
	e7:SetCode(EVENT_SUMMON_SUCCESS)
	Duel.RegisterEffect(e7,tp)


end

function s.ownedcard(c)
	return c:GetOwner()==c:GetControler() and not (c:IsLocation(LOCATION_EXTRA) and c:IsFacedown())
end

function s.fupend(c)
	return c:IsFaceup() and c:IsLocation(LOCATION_EXTRA) and s.ownedcard(c)
end

function s.flipconextra(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.fupend,1,nil) and Duel.GetFlagEffect(tp, id+1)==0
end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.ownedcard,1,nil) and Duel.GetFlagEffect(tp, id+1)==0
end

function s.wasnotmaterialfilter(c)
	return (c:GetReason()==(REASON_RELEASE) or c:IsReason(REASON_SUMMON)
	or c:IsReason(REASON_FUSION|REASON_SYNCHRO|REASON_LINK))
end

function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(s.ownedcard,nil)
    for card in g:Iter() do
        card:RegisterFlagEffect(id, 0,0,0)
    end

	if eg:IsExists(s.wasnotmaterialfilter, 1, nil) then
		Duel.RegisterFlagEffect(tp, id+2, RESET_EVENT+RESET_PHASE+PHASE_END, 0, 0)
	else
		Duel.RegisterFlagEffect(tp, id+1, RESET_EVENT+RESET_PHASE+PHASE_END, 0, 0)
	end
    
end

function s.taggedcard(c)
    return c:GetFlagEffect(id)>0
end

function s.flipcon3(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id+1)==1 and Duel.GetCurrentChain()==0
end
function s.flipop3(e,tp,eg,ep,ev,re,r,rp)

	Duel.Hint(HINT_CARD,tp,id)
    local g=Duel.GetMatchingGroup(s.taggedcard, tp, LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA, 0, nil)
    for card in g:Iter() do
        s.removecards(card,tp)
    end
    Duel.RemoveCards(g)


    Duel.ResetFlagEffect(tp, id+1)
end

function s.removemonstertypefilter(c,race)
    return c:IsMonster() and c:IsRace(race) and ((c:IsLocation(LOCATION_EXTRA) and c:IsFaceup()) or
        c:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED))
end

function s.removearchetypefilter(c,archetype)
    return c:IsSetCard(archetype) and ((c:IsMonster() and c:IsLocation(LOCATION_EXTRA) and c:IsFaceup()) or
        c:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED))
end

function s.removecards(c, tp)
    local race=nil
    if c:IsMonster() then
        race=c:GetRace()
        local g2=Duel.GetMatchingGroup(s.removemonstertypefilter, tp, LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA, 0, c,race)
        if g2 and #g2>0 then
            Duel.RemoveCards(g2)
        end
    end

    local archetypes=nil
    archetypes={c:Setcode()}

    for key,value in ipairs(archetypes) do

        local g2=Duel.GetMatchingGroup(s.removearchetypefilter, tp, LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA, 0, c,value)
        if g2 and #g2>0 then
            Duel.RemoveCards(g2)
        end

    end
end


function s.flipcon4(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id+2)==1 and Duel.GetCurrentChain()==0
end
function s.flipop4(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
    local g=Duel.GetMatchingGroup(s.taggedcard, tp, LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA, 0, nil)
    for card in g:Iter() do
        s.removecards(card,tp)
    end
    Duel.RemoveCards(g)

    Duel.ResetFlagEffect(tp, id+2)
end
