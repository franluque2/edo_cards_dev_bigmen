--The Gladiator Test Driver
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)
	local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil, s.flipconactive, s.flipopactive, true, nil)
	c:RegisterEffect(e1)
	c:RegisterEffect(e2)

        aux.GlobalCheck(s, function()
        s.is_human_player = {}
        s.is_human_player[0] = false
        s.is_human_player[1] = false

    end)
end

local CARD_TAMER_EDITOR = 30864377


function s.flipconactive(e, tp, eg, ep, ev, re, r, rp)
    return (aux.CanActivateSkill(tp)) or (Duel.GetCurrentChain()==0 and Duel.IsBattlePhase() and Duel.IsTurnPlayer(tp)) --and Duel.GetPlayersCount(tp)>0
end

function s.flipopactive(e, tp, eg, ep, ev, re, r, rp)
    if (not s.is_human_player[tp]) or Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
        s.is_human_player[tp] = not s.is_human_player[tp]

        Duel.TagSwap(tp)
    end
   
end

function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    local c = e:GetHandler()

    if Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_EXTRA, 0, 1, nil, CARD_TAMER_EDITOR) then
        s.is_human_player[tp] = true
    end

    Duel.Recover(1-tp, 8000, REASON_RULE)

    -- You can Normal Summon 1 Beast non-"Gladiator Beast" monster, in addition to your Normal Summon or Set. (You can only gain this effect once per turn)
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 1))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
    e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE, 0)
    e1:SetTarget(aux.TargetBoolFunction(s.nongladbeastfilter))
    Duel.RegisterEffect(e1, tp)

    --rewrite editor
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_ADJUST)
    e2:SetCondition(s.rewritecon)
    e2:SetOperation(s.rewriteop)
    Duel.RegisterEffect(e2, tp)


        --rewrite spells
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_ADJUST)
    e3:SetCondition(s.rewritespellscon)
    e3:SetOperation(s.rewritespellsop)
    Duel.RegisterEffect(e3, tp)

    -- Draw twice for the draw phase

    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_PREDRAW)
    e4:SetCondition(s.drawtwicecon)
    e4:SetOperation(s.drawtwiceop)
    e4:SetCountLimit(1)
    Duel.RegisterEffect(e4, tp)

    -- allow the bot to swap back at the start of the battle phase and mp2
    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
    e5:SetCondition(function (_e,_tp) return Duel.IsTurnPlayer(1-_tp) and s.is_human_player[_tp] end)
    e5:SetCountLimit(1)
    e5:SetOperation(s.battleswapop)
    Duel.RegisterEffect(e5, tp)

    local e6 = Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e6:SetCode(EVENT_PHASE+PHASE_MAIN2)
    e6:SetCondition(function (_e,_tp) return Duel.IsTurnPlayer(1-_tp) and not s.is_human_player[_tp] end)
    e6:SetCountLimit(1)
    e6:SetOperation(s.m2swapop)
    Duel.RegisterEffect(e6, tp)
end

function s.nongladbeastfilter(c)
    return c:IsRace(RACE_BEAST) and not c:IsSetCard(SET_GLADIATOR_BEAST)
end

function s.rewritecardsfilter(c)
    return c:IsCode(CARD_TAMER_EDITOR) and c:GetFlagEffect(id)==0
end

function s.rewritecon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.rewritecardsfilter, tp, LOCATION_ALL, 0, 1, nil)
end

function s.rewriteop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(s.rewritecardsfilter, tp, LOCATION_ALL, 0, nil)
    for tc in g:Iter() do
        tc:RegisterFlagEffect(id, 0, 0, 0)

        local effs={tc:GetOwnEffects()}
        for _, eff in ipairs(effs) do
            if eff:GetCode()==EFFECT_FUSION_MATERIAL or eff:GetCode()==EFFECT_SPSUMMON_PROC or eff:GetCode()==EFFECT_SPSUMMON_CONDITION then
                eff:Reset()
            end
        end
        Fusion.AddProcMixN(tc,true,true,s.addededitormatfilter,2)
    end
end


function s.addededitormatfilter(c,fc,sumtype,tp)
	return c:IsRace(RACE_BEAST,fc,sumtype,tp) and not c:IsSetCard(SET_GLADIATOR_BEAST,fc,sumtype,tp)
end


function s.rewritespellsfilter(c)
    return c:IsSetCard(SET_GLADIATOR_BEAST) and c:IsSpell() and c:GetFlagEffect(id)==0
end

function s.rewritespellscon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.rewritespellsfilter, tp, LOCATION_ALL, 0, 1, nil)
end

function s.rewritespellsop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(s.rewritespellsfilter, tp, LOCATION_ALL, 0, nil)
    for tc in g:Iter() do
        tc:RegisterFlagEffect(id, 0, 0, 0)

        if tc:IsCode(05063379) then --Flavius
            local effs={tc:GetOwnEffects()}
            for _, eff in ipairs(effs) do
                if eff:IsHasCategory(CATEGORY_SPECIAL_SUMMON) then
                    eff:SetOperation(s.newspop)
                end
            end

        end

         if tc:IsCode(52496105) then --Battle Manica
            local effs={tc:GetOwnEffects()}
            for _, eff in ipairs(effs) do
                if eff:GetCode()==EFFECT_INDESTRUCTABLE_BATTLE then
                    eff:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
                    eff:SetValue(s.valcon)
                end
            end

        end

         if tc:IsCode(20201255) then --Comeback
            local effs={tc:GetOwnEffects()}
            for _, eff in ipairs(effs) do
                if eff:IsHasCategory(CATEGORY_SPECIAL_SUMMON) then
                    eff:SetOperation(s.newspcomebackop)
                end
            end

        end
        
    end
end


function s.newspfilter(c,e,tp)
	return c:IsSetCard(SET_GLADIATOR_BEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end


function s.newspop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.newspfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
		--It cannot be destroyed by battle
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id, 2))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
		e1:SetValue(s.valcon)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		sc:RegisterEffect(e1)
	end
end

function s.valcon(e,re,r,rp)
	return (r&REASON_BATTLE)~=0
end



function s.newspcomebackfilter(c,e,tp)
	return c:IsSetCard(SET_GLADIATOR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,c:GetRace()),tp,LOCATION_MZONE,0,1,nil)
end


function s.newspcomebackop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.newspcomebackfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		--Cannot be destroyed by battle
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id, 2))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
		e1:SetValue(s.valcon)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		g:GetFirst():RegisterEffect(e1)
	end
end


function s.drawtwicecon(e,tp,eg,ep,ev,re,r,rp)
    return tp==Duel.GetTurnPlayer() and Duel.GetDrawCount(tp)>0 -- and Duel.GetPlayersCount(tp)>1
end

function s.drawtwiceop(e,tp,eg,ep,ev,re,r,rp)
    local dt=Duel.GetDrawCount(tp)
    if dt>0 then
        Duel.TagSwap(tp)
        Duel.Draw(tp, dt, REASON_RULE)
        Duel.TagSwap(tp)
    end
end

function s.battleswapop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.IsTurnPlayer(tp) then return end
    if not s.is_human_player[tp] then return end
    s.is_human_player[tp] = false
    Duel.TagSwap(tp)
end

function s.m2swapop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.IsTurnPlayer(tp) then return end
    if s.is_human_player[tp] then return end
    s.is_human_player[tp] = true
    Duel.TagSwap(tp)
end