--Propagation of Celerity
Duel.LoadScript("wb_aux.lua")
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

local MODULAR_FIELDS={56787189,2106266,2144946,62265044,66750703,90764871,93031067}

function s.addfieldspellfilter(c)
    if not (c:IsType(TYPE_FIELD) and c:IsAbleToHand()) then return false end
    if c:IsOriginalCode(table.unpack(MODULAR_FIELDS)) then return true end
    local effs={c:GetOwnEffects()}
	for _,eff in ipairs(effs) do
		if eff:IsHasCategory(CATEGORY_SEARCH) then
			return true
		end
	end
	return false

end

function s.propagateeffectstocard(c,e)
    c:RegisterFlagEffect(id, 0,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))
    --If this card is a Spell/Trap, you can activate it from your Hand as a Quick Effect from your Hand or face-down field during either Player's Turn.
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
        e2:SetCode(EFFECT_BECOME_QUICK)
        e2:SetCondition(function(_e) return _e:GetHandler():IsSpellTrap() end)
        e2:SetRange(LOCATION_HAND+LOCATION_SZONE)
        c:RegisterEffect(e2)


        local e3=e2:Clone()
        e3:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
        c:RegisterEffect(e3)

        local e5=e2:Clone()
        e5:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
        c:RegisterEffect(e5)

        local e6=e2:Clone()
        e6:SetCode(EFFECT_TRAP_ACT_IN_HAND)
        c:RegisterEffect(e6)
        -- If this card is a Monster, you can, during the Main Phase (Quick Effect): Special Summon this card from your Hand.
        local e4=Effect.CreateEffect(e:GetHandler())
        e4:SetDescription(aux.Stringid(id,1))
        e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
        e4:SetType(EFFECT_TYPE_QUICK_O)
        e4:SetCode(EVENT_FREE_CHAIN)
        e4:SetRange(LOCATION_HAND)
        e4:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	    e4:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
        e4:SetCondition(function(_e,tp) return Duel.IsMainPhase() and _e:GetHandler():IsMonster() end)
        e4:SetTarget(s.sptg)
	    e4:SetOperation(s.spop)
        c:RegisterEffect(e4)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local exc=c:IsRelateToEffect(e) and c or nil
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
        e1:SetCountLimit(1)
		Duel.RegisterEffect(e1,tp)

        local g=Duel.GetMatchingGroup(s.addfieldspellfilter, tp, LOCATION_DECK, 0, nil)
        if #g>0 then
            Duel.Hint(HINT_CARD,tp,id)
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local sg=g:Select(tp,1,1,nil)
            Duel.SendtoHand(sg,nil,REASON_RULE)
            Duel.ConfirmCards(1-tp,sg)

            s.propagateeffectstocard(sg:GetFirst(),e)
        end

        --Any card added from the Deck or GY to the hand by this card gains all of these effects.
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetCode(EVENT_TO_HAND)
        e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e2:SetCondition(s.propagatecon)
        e2:SetOperation(s.propagateop)
        Duel.RegisterEffect(e2,tp)
	end
	e:SetLabel(1)
end

function s.propagatecon(e,tp,eg,ep,ev,re,r,rp)
    return tp==ep and eg:IsExists(Card.IsPreviousLocation,1,nil,LOCATION_DECK+LOCATION_GRAVE) and re and re:GetHandler():GetFlagEffect(id)~=0
end

function s.propagateop(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(Card.IsPreviousLocation,nil,LOCATION_DECK+LOCATION_GRAVE)
    for tc in aux.Next(g) do
        s.propagateeffectstocard(tc,e)
    end
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
end