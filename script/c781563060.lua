--The Valorous Commanding Velgearian
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)

        aux.GlobalCheck(s, function()
        s.used_this_skill_1 = {}
        s.used_this_skill_1[0] = false
        s.used_this_skill_1[1] = false

        s.used_this_skill_2 = {}
        s.used_this_skill_2[0] = false
        s.used_this_skill_2[1] = false

        s.added_cards={}
        s.added_cards[0] = {}
        s.added_cards[1] = {}

        aux.AddValuesReset(function()
			s.used_this_skill_1[0] = false
			s.used_this_skill_1[1] = false
			s.used_this_skill_2[0] = false
			s.used_this_skill_2[1] = false
		end)
    end)

    local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil, s.flipconactive, s.flipopactive, true, nil)
    c:RegisterEffect(e1)
    c:RegisterEffect(e2)
end

local CARD_PALERIDER=160317012
local CARD_VOID_HOLE=160024043
local CARD_VOID_FUSION=160020052
local CARD_VOIDVELG_REQUIEM=160010025
local CARD_VOIDVELG_FORBIDDEN_REQUIEM=160020044

function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    local c = e:GetHandler()

    BRush.addrules()(e,tp,eg,ep,ev,re,r,rp)

    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(511002961)
    e3:SetTarget(function (_,_c) return _c:IsCode(CARD_PALERIDER) end)
    e3:SetTargetRange(LOCATION_ALL,0)
    Duel.RegisterEffect(e3,tp)

    --The Name of "Worm Void Hole" in your possession is also treated as "Dark Hole", 
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_ADD_CODE)
    e4:SetValue(53129443)
    e4:SetTarget(function (_,_c) return _c:IsOriginalCode(CARD_VOID_HOLE) end)
    e4:SetTargetRange(LOCATION_ALL,0)
    Duel.RegisterEffect(e4,tp)

    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_ADJUST)
    e5:SetCondition(s.rewritecardscon)
    e5:SetOperation(s.rewritecardsop)
    Duel.RegisterEffect(e5,tp)


    --While you control "Voidvelg Requiem", all monsters your opponent control are also treated as LIGHT monsters, also, it cannot be destroyed by your card effects. 
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD)
    e6:SetCode(EFFECT_ADD_ATTRIBUTE)
    e6:SetValue(ATTRIBUTE_LIGHT)
    e6:SetCondition(function (_,_c) return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,nil,CARD_VOIDVELG_REQUIEM) end)
    e6:SetTargetRange(0,LOCATION_MZONE)
    Duel.RegisterEffect(e6,tp)

    local e7=Effect.CreateEffect(c)
    e7:SetType(EFFECT_TYPE_FIELD)
    e7:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e7:SetTarget(function (_,_c) return _c:IsCode(CARD_VOIDVELG_REQUIEM) end)
    e7:SetTargetRange(LOCATION_ONFIELD,0)
    e7:SetValue(s.defilter )
    Duel.RegisterEffect(e7,tp)
end

function s.defilter(e,re,rp)
	return e:GetHandlerPlayer()==rp
end


function s.fupaleriderfilter(c)
    return c:IsFaceup() and c:IsCode(CARD_PALERIDER)
end

function s.validaddfilter(c,tp)
    if not (c:IsType(TYPE_FUSION) and c.material) then return false end

    for _, mat in ipairs(c.material) do
        if not s.added_cards[tp][mat] then
            return true
        end
    end
    return false
end

function s.flipconactive(e, tp, eg, ep, ev, re, r, rp)
    local b1= not s.used_this_skill_1[e:GetHandlerPlayer()] and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>2
    local b2= not s.used_this_skill_2[e:GetHandlerPlayer()] and 
    Duel.IsExistingMatchingCard(s.fupaleriderfilter, tp, LOCATION_ONFIELD, 0, 1, nil)
    and Duel.IsExistingMatchingCard(s.validaddfilter, tp, LOCATION_EXTRA, 0, 1, nil, tp)
    return (b1 or b2) and aux.CanActivateSkill(tp)
end

function s.flipopactive(e, tp, eg, ep, ev, re, r, rp)
    local b1= not s.used_this_skill_1[e:GetHandlerPlayer()] and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>2
    local b2= not s.used_this_skill_2[e:GetHandlerPlayer()] and 
    Duel.IsExistingMatchingCard(s.fupaleriderfilter, tp, LOCATION_ONFIELD, 0, 1, nil)
    and Duel.IsExistingMatchingCard(s.validaddfilter, tp, LOCATION_EXTRA, 0, 1, nil, tp)

    local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
									{b2,aux.Stringid(id,1)})

    Duel.Hint(HINT_CARD,tp,id)
    
    if op==1 then
        s.used_this_skill_1[e:GetHandlerPlayer()] = true
        -- excavate 3 cards from the top of your Deck, pick one and add it to your hand, then, if you added a Level 4 or lower monster you can add 1 "Void Dust Fusion", 1 "Worm Dark Hole" OR 1 "Voidvelg Pale Rider" from outside the Duel to your hand.

        	Duel.ConfirmDecktop(tp,3)
	        local g=Duel.GetDecktopGroup(tp,3)
        if g:IsExists(Card.IsAbleToHand,1,nil) then
            	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
                local tg=g:FilterSelect(tp,Card.IsAbleToHand,1,1,nil)
                if #tg>0 then
                    Duel.DisableShuffleCheck()
                    Duel.SendtoHand(tg,nil,REASON_EFFECT)
                    Duel.ConfirmCards(1-tp,tg)
                    Duel.ShuffleHand(tp)
                    g:RemoveCard(tg)
                end

                Duel.ShuffleDeck(tp)

                if tg:GetFirst():IsType(TYPE_MONSTER) and tg:GetFirst():GetLevel()<=4 and Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
                    -- add 1 "Void Dust Fusion", 1 "Worm Dark Hole" OR 1 "Voidvelg Pale Rider" from outside the Duel to your hand

                    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
                    local code=Duel.SelectCardsFromCodes(tp,1,1,nil,false,CARD_VOID_FUSION,CARD_VOID_HOLE,CARD_PALERIDER)
                    local token=Duel.CreateToken(tp,code)

                    Duel.SendtoHand(token,nil,REASON_EFFECT)
                    Duel.ConfirmCards(1-tp,token)
                    Duel.ShuffleHand(tp)
                end

        end
    elseif op==2 then
        s.used_this_skill_2[e:GetHandlerPlayer()] = true

        local revg=Duel.GetMatchingGroup(s.validaddfilter, tp, LOCATION_EXTRA, 0, nil, tp)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
        local sg=revg:Select(tp,1,1,nil)

        Duel.ConfirmCards(1-tp, sg)
        Duel.ShuffleExtra(tp)

        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local tc=sg:GetFirst()
        if tc then

            local validmats={}
            for _, mat in ipairs(tc.material) do
                if not s.added_cards[tp][mat] then
                    table.insert(validmats, mat)
                end
            end
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local tokenname=Duel.SelectCardsFromCodes(tp,1,1,nil,false,table.unpack(validmats))

            local token=Duel.CreateToken(tp,tokenname)
            Duel.SendtoHand(token,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,token)

            s.added_cards[tp][tokenname] = true
            Duel.ShuffleHand(tp)
        end
    end

end

function s.rewritecardfilter(c)
    return c:IsCode(CARD_VOID_FUSION, CARD_VOIDVELG_FORBIDDEN_REQUIEM) and c:GetFlagEffect(id) == 0
end

function s.rewritecardscon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.rewritecardfilter, tp, LOCATION_ALL, 0, 1, nil)
end
    
function s.rewritecardsop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.rewritecardfilter, tp, LOCATION_ALL, 0, nil)
    for tc in g:Iter() do
        tc:RegisterFlagEffect(id, 0, 0, 0)

        if tc:IsCode(CARD_VOID_FUSION) then
            local effs = {tc:GetOwnEffects()}
            for _, eff in ipairs(effs) do

                if eff:IsHasType(EFFECT_TYPE_ACTIVATE) then
                    eff:SetTarget(s.fakefustg)
                    eff:SetOperation(s.fusop)
                end
            end
        end

        if tc:IsCode(CARD_VOIDVELG_FORBIDDEN_REQUIEM) then
            tc:RegisterFlagEffect(id, 0, EFFECT_FLAG_CLIENT_HINT, 0, aux.Stringid(id, 2))

            local e6=Effect.CreateEffect(tc)
            e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
            e6:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_DELAY)
            e6:SetCode(EVENT_PHASE+PHASE_END)
            e6:SetRange(LOCATION_MZONE)
            e6:SetCountLimit(1)
            e6:SetCondition(function(e,tp) return e:GetHandler():IsControler(tp) end)
            e6:SetOperation(function(e) Duel.Win(1-tp,WIN_REASON_RELAY_SOUL) end)
            tc:RegisterEffect(e6)

            local e3=Effect.CreateEffect(tc)
            e3:SetType(EFFECT_TYPE_SINGLE)
            e3:SetCode(EFFECT_IMMUNE_EFFECT)
            e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
            e3:SetRange(LOCATION_MZONE)
            e3:SetCondition(function(e) return  e:GetHandler():IsControler(e:GetHandler():GetOwner())  end)
            e3:SetValue(s.efilter)
            tc:RegisterEffect(e3)


        end
    end
end

function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end


--things to rewrite cards with

function s.fakefustg(e,tp,eg,ep,ev,re,r,rp,chk)
    local fusion_params={fusfilter=s.fusmonfilter,
		matfilter=aux.FALSE,
		extrafil=s.extrafusionmat(),
		extraop=Fusion.ShuffleMaterial,
		exactcount=2,
		stage2=s.atklimit
	}
	if chk==0 then return Fusion.SummonEffTG(fusion_params)(e,tp,eg,ep,ev,re,r,rp,0) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end


function s.fusmonfilter(c)
	return c:IsLevel(9) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_GALAXY) and c:IsDefenseAbove(2000)
end
function s.matfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_GALAXY) and c:IsAbleToDeck()
end

function s.extrafusionmat()
	return function(e,tp,mg)
		return Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_GRAVE,0,nil),s.matexclusioncheck()
	end
end
function s.matexclusioncheck()
	return function(tp,sg,fc)
		return true
	end
end

function s.fusop(e,tp,eg,ep,ev,re,r,rp)
	local fusion_params={fusfilter=s.fusmonfilter,
		matfilter=aux.FALSE,
        extrafil=s.extrafusionmat(),
		extraop=Fusion.ShuffleMaterial,
		exactcount=2
	}
	Fusion.SummonEffTG(fusion_params)(e,tp,eg,ep,ev,re,r,rp,1)
	Fusion.SummonEffOP(fusion_params)(e,tp,eg,ep,ev,re,r,rp)
end