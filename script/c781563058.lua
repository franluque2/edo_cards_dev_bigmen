--Into the Lair of the Harpies
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)
    local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,s.flipconactive,
        s.flipopactive, true, nil)
    c:RegisterEffect(e1)
    c:RegisterEffect(e2)

    aux.GlobalCheck(s, function()
        s.used_this_skill_passive = {}
        s.used_this_skill_passive[0] = false
        s.used_this_skill_passive[1] = false

        s.used_this_skill_active = {}
        s.used_this_skill_active[0] = false
        s.used_this_skill_active[1] = false

        s.active_add_blacklist={}
        s.active_add_blacklist[0] = {}
        s.active_add_blacklist[1] = {}
    
        aux.AddValuesReset(function()
    		s.used_this_skill_passive[0] = false
    		s.used_this_skill_passive[1] = false
    		s.used_this_skill_active[0] = false
    		s.used_this_skill_active[1] = false
    	end)
    end)

end

function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

local HARPIE_ULTIMATE_MOVES={12181376,18144506,86308219,100000296,100000295}
local CARD_PHANTASMAL_DRAGON=85909450

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
	Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
	Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
	local c = e:GetHandler()

    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ADJUST)
	e1:SetOperation(s.adjrevop)
	Duel.RegisterEffect(e1,tp)
	--Aroma effect manually
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(function(e,tp) return Duel.GetDecktopGroup(tp,1):GetFirst() end)
	e2:SetOperation(s.manualrevop)
	Duel.RegisterEffect(e2,tp)

    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_PHASE+PHASE_DRAW)
    e3:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) end)
    e3:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_DUEL)
    e3:SetOperation(s.placecards)
    Duel.RegisterEffect(e3,tp)

    	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e4:SetCountLimit(1)
    e4:SetCondition(function (e) return Duel.IsExistingMatchingCard(aux.TRUE,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil) end)
	e4:SetTargetRange(LOCATION_HAND|LOCATION_MZONE,0)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_HARPIE))
    Duel.RegisterEffect(e4,tp)

    --If you Xyz Summon "Harpie's Pet Phantasmal Dragon", detach 2 materials from it.
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_SPSUMMON_SUCCESS)
    e5:SetCondition(s.detachcon)
    e5:SetOperation(s.detachop)
    Duel.RegisterEffect(e5,tp)

    --Once per Turn, if you Normal or Special Summon a "Harpie" monster, you can return 1 "Harpie" monster you control to the hand, then, immediately after this effect resolves, you can Normal Summon 1 WIND monster from your Hand or top of your Deck without tributing. Monsters summoned this way cannot attack this turn.
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e6:SetProperty(EFFECT_FLAG_DELAY)
    e6:SetCode(EVENT_SUMMON_SUCCESS)
    e6:SetCondition(s.harpiereturncon)
    e6:SetOperation(s.harpiereturnop)
    Duel.RegisterEffect(e6,tp)
    local e7=e6:Clone()
    e7:SetCode(EVENT_SPSUMMON_SUCCESS)
    Duel.RegisterEffect(e7,tp)
end

function s.placecards(e,tp)
    local huntingground=Duel.CreateToken(tp, 75782277)
    Duel.MoveToField(huntingground, tp, tp, LOCATION_FZONE, POS_FACEUP, true)

    local aeronail=Duel.CreateToken(tp, 100000297)
    Duel.MoveToField(aeronail, tp, tp, LOCATION_SZONE, POS_FACEDOWN, true)
end


function s.adjrevop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetDecktopGroup(tp,1):GetFirst()
	if not tc or tc:HasFlagEffect(id) then return end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	Duel.SelectCardsFromCodes(tp,0,1,true,false,tc:GetCode())
	tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1)
end
function s.manualrevop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetDecktopGroup(tp,1):GetFirst()
	if not tc then return end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	Duel.SelectCardsFromCodes(tp,0,1,true,false,tc:GetCode())
end

function s.detachcon(e,tp,eg,ep,ev,re,r,rp)
    local tc=eg:GetFirst()
    return tc and tc:IsFaceup() and tc:IsCode(CARD_PHANTASMAL_DRAGON) and tc:IsSummonType(SUMMON_TYPE_XYZ)
end
function s.detachop(e,tp,eg,ep,ev,re,r,rp)
    local tc=eg:GetFirst()
    if tc and tc:IsFaceup() and tc:IsCode(CARD_PHANTASMAL_DRAGON) and tc:IsType(TYPE_XYZ) then
        if tc:CheckRemoveOverlayCard(tp,2,REASON_EFFECT) then
            Duel.Hint(HINT_CARD,tp,id)
            tc:RemoveOverlayCard(tp,2,2,REASON_EFFECT)
        end
    end
end

function s.fuharpiewithlevelfilter(c)
    return c:IsSetCard(SET_HARPIE) and c:HasLevel()
end
-- Once per turn, if you control "Harpie" monsters whose combined total levels equal 20 or more, you can add 1 of the Harpies' ultimate moves to your Hand from Outside the Duel. (But you can only add each card once per Duel).
function s.flipconactive(e, tp, eg, ep, ev, re, r, rp)
    if s.used_this_skill_active[tp] then return false end
    if not aux.CanActivateSkill(tp) then return false end
    if (#HARPIE_ULTIMATE_MOVES) <= #s.active_add_blacklist[tp] then return false end
    return Duel.GetMatchingGroup(s.fuharpiewithlevelfilter, tp, LOCATION_MZONE, 0, nil):GetSum(Card.GetLevel) >= 20
end

function s.flipopactive(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_CARD, tp, id)
    local c = e:GetHandler()

    local valid_ultimate_moves={}
    for i, code in ipairs(HARPIE_ULTIMATE_MOVES) do
        local is_blacklisted=false
        for j, blacklisted_code in ipairs(s.active_add_blacklist[tp] or {}) do
            if code == blacklisted_code then
                is_blacklisted=true
                break
            end
        end
        if not is_blacklisted then
            table.insert(valid_ultimate_moves, code)
        end
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local code=Duel.SelectCardsFromCodes(tp,1,1,false,false,table.unpack(valid_ultimate_moves))

    local token=Duel.CreateToken(tp, code)
    Duel.SendtoHand(token, tp, REASON_EFFECT)
    table.insert(s.active_add_blacklist[tp], code)
    Duel.ConfirmCards(1-tp, token)
    s.used_this_skill_active[tp]=true
end

function s.fuharpiefilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_HARPIE)
end

function s.harpiereturncon(e,tp,eg,ep,ev,re,r,rp)
    if s.used_this_skill_passive[tp] == true then return false end
    
    return eg:IsExists(s.fuharpiefilter, 1, nil)
end

function s.normalsummonablwindfilter(c, code)
    return c:IsMonster() and c:IsAttribute(ATTRIBUTE_WIND) and c:IsSummonable(true, e) and not c:IsCode(code)
end

function s.harpiereturnop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
        Duel.Hint(HINT_CARD,tp,id)
        s.used_this_skill_passive[tp] = true
        local g=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_MZONE,0,1,1,nil,SET_HARPIE)
        if #g>0 then
            if Duel.SendtoHand(g,nil,REASON_EFFECT) then
                local g2=Duel.GetMatchingGroup(s.normalsummonablwindfilter,tp,LOCATION_HAND,0,nil,g:GetFirst():GetCode())
                local topdeck=Duel.GetDecktopGroup(tp, 1)
                if s.normalsummonablwindfilter(topdeck:GetFirst(), g:GetFirst():GetCode()) then
                    g2:AddCard(topdeck:GetFirst())
                end
                if #g2>0 then
                    if Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
                        Duel.BreakEffect()
                        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
                        local sg=g2:Select(tp,1,1,nil)
                        Duel.Summon(tp,sg:GetFirst(),true,nil)

                        local e1=Effect.CreateEffect(e:GetHandler())
                        e1:SetDescription(3206)
                        e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
                        e1:SetType(EFFECT_TYPE_SINGLE)
                        e1:SetCode(EFFECT_CANNOT_ATTACK)
                        e1:SetReset(RESETS_STANDARD_PHASE_END)
                        sg:GetFirst():RegisterEffect(e1)
                    end
                end
            end
        end
    end
end