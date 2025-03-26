--Minecraft Contraption: Piston
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,s.ffilter,1,s.ffilter2,1)
		


    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,{id,0})
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)


    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)

end
s.listed_series={SET_MINECRAFT}

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0,nil)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)

    if g then
        local tc=g:GetMinGroup(Card.GetSequence)
        Duel.Destroy(tc,REASON_EFFECT)
    end

    local g2=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
    local g2_table = {}
    for tc in g2:Iter() do
        table.insert(g2_table, tc)
    end

    table.sort(g2_table, function(a, b)
        return a:GetSequence() < b:GetSequence()
    end)

    for _, tc in ipairs(g2_table) do
        if tc and tc:IsControler(1-tp) and tc:IsLocation(LOCATION_MZONE) then
            local seq = tc:GetSequence()
            local nseq = seq - 1
            Debug.Message(Duel.CheckLocation(1-tp, LOCATION_MZONE, nseq))
            if nseq >= 0 and nseq <= 4 and Duel.CheckLocation(1-tp, LOCATION_MZONE, nseq) then
                Duel.MoveSequence(tc, nseq)
            end
        end
    end
end

function s.setfilter(c,cd)
	return c:IsSetCard(SET_MINECRAFT) and c:IsSpell() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)

        local tc1=g:GetFirst()
        if tc1:IsQuickPlaySpell() then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetDescription(aux.Stringid(id,1))
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
            e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
            e1:SetReset(RESET_EVENT|RESETS_STANDARD)
            tc1:RegisterEffect(e1)
            end
end
end

function s.ffilter(c,fc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_EARTH,fc,sumtype,tp) and c:IsRace(RACE_ROCK,fc,sumtype,tp)
end

function s.ffilter2(c,fc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE,fc,sumtype,tp) and c:IsRace(RACE_ROCK,fc,sumtype,tp)
end