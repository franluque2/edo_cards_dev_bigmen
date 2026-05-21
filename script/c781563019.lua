--Shield of the Barians
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_STARTUP)
    e3:SetRange(0x5f)
    e3:SetCountLimit(1)
    e3:SetOperation(s.shuffledownop)
    c:RegisterEffect(e3)


    local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil, nil, nil, true, nil)
    c:RegisterEffect(e1)
    c:RegisterEffect(e2)
end

function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.rankfivefilter(c)
    return c:IsType(TYPE_XYZ) and c:GetRank()==5
end

local starseraphcounts={}
starseraphcounts[0]={}
starseraphcounts[1]={}

local starseraphextracounts={}
starseraphextracounts[0]={}
starseraphextracounts[1]={}

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    local c = e:GetHandler()

    local g=Duel.GetMatchingGroup(s.rankfivefilter,tp,LOCATION_EXTRA,0,nil)

    for tc in g:Iter() do
        Xyz.AddProcedure(tc,s.xyzop,4,3)
    end

    s.registerstarseraphs(tp)

    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SET_SUMMON_COUNT_LIMIT)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(3)
	Duel.RegisterEffect(e1,tp)

    
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_MOVE)
    e2:SetCondition(function(_,_,eg) return eg:IsExists(Card.IsPreviousLocation,1,nil,LOCATION_DECK|LOCATION_EXTRA) end)
    e2:SetOperation(s.completestarseraphs)
    Duel.RegisterEffect(e2,tp)

    s.completestarseraphs(nil, tp, nil, nil, nil, nil, nil, nil)
end

function s.fdsentryfilter(c)
    return c:IsSetCard(SET_NUMBER) and c.xyz_number and (c.xyz_number==102)
end

function s.registerstarseraphs(tp)
    local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_ALL-LOCATION_EXTRA,0,nil,SET_STAR_SERAPH)
    for tc in g:Iter() do
        local code=tc:GetCode()
        if not starseraphcounts[tp][code] then
            starseraphcounts[tp][code]=0
        end
        starseraphcounts[tp][code]=starseraphcounts[tp][code]+1
    end

    local g2=Duel.GetMatchingGroup(s.fdsentryfilter,tp,LOCATION_EXTRA,0,nil)
    for tc in g2:Iter() do
        local code=tc:GetCode()
        if not starseraphextracounts[tp][code] then
            starseraphextracounts[tp][code]=0
        end
        starseraphextracounts[tp][code]=starseraphextracounts[tp][code]+1
    end
end

function s.completestarseraphs(e,tp,eg,ep,ev,re,r,rp)
    for code, count in pairs(starseraphcounts[tp]) do
        local num=Duel.GetMatchingGroupCount(Card.IsCode, tp, LOCATION_DECK, 0, nil, code)
        if count>num then
            for i=1, count-num do
                local token=Duel.CreateToken(tp, code)
                Duel.SendtoDeck(token, nil, SEQ_DECKBOTTOM, REASON_RULE)
            end
        end
    end

    for code, count in pairs(starseraphextracounts[tp]) do
        local num=Duel.GetMatchingGroupCount(Card.IsCode, tp, LOCATION_EXTRA, 0, nil, code)
        if count>num then
            for i=1, count-num do
                local token=Duel.CreateToken(tp, code)
                Duel.SendtoDeck(token, nil, SEQ_DECKBOTTOM, REASON_RULE)
            end
        end
    end
end

function s.sentryfilter(c)
    return c:IsSetCard(SET_NUMBER) and c.xyz_number and (c.xyz_number==102) and c:IsFaceup()
end

function s.xyzop(_,c)
	return Duel.IsExistingMatchingCard(s.sentryfilter, c:GetOwner(), LOCATION_ONFIELD, 0, 1,nil)
end

function s.cardfilter(c, tp)
    return c:IsCode(97769122, 57734012) and c:GetSequence() >= (Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) - (10))
end

function s.shuffledownop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(s.cardfilter, tp, LOCATION_DECK, 0, nil, tp)
    if #g == Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) then return end
    if #g > 0 then
        Duel.MoveToDeckBottom(g)
    end

    local g1 = Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_DECK, 0, nil, 38331564)
	if #g1 > 0 then
		Duel.MoveToDeckTop(g1:GetFirst())
	end

    local g2 = Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_DECK, 0, nil, 91110378)
	if #g2 > 0 then
		Duel.MoveToDeckTop(g2:GetFirst())
	end
end