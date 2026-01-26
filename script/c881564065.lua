--Hassan of the Hecahands, the True Fated Assailant
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_CONDITION)
    e1:SetValue(s.splimit)
    c:RegisterEffect(e1)

    --Gains 1000 ATK/DEF for each "Dregs of Angra Mainju" in your Opponent's hand.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetValue(s.atkval)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e3)

    local sme,soe=Spirit.AddProcedure(c)
    sme:SetCondition(s.mretcon)
    soe:SetCondition(s.oretcon)
    c:RegisterFlagEffect(FLAG_SPIRIT_RETURN,0,0,1)

    --  This card gains the following effects depending on the number of "Dregs of Angra Mainju" in your opponent's hand.
    -- 1+: If this card is destroyed by a DARK monster's effect: Special Summon it, then you can add 1 "Dregs of Angra Mainju" to your opponent's hand from Outside the Duel. You can only use this effect of "Hassan of the Hecahands, the True Fated Assailant" Once per turn.
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_CONJURE)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_TO_GRAVE)
    e4:SetCountLimit(1,id)
    e4:SetCondition(s.spcon)
    e4:SetTarget(s.sptg)
    e4:SetOperation(s.spop)
    c:RegisterEffect(e4)

    -- 2+: Your opponent cannot target this card with card effects, also they cannot destroy it with card effects. 
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e5:SetValue(aux.tgoval)
    e5:SetCondition(function(e) return Duel.GetMatchingGroupCount(Card.IsCode,1-e:GetHandler():GetControler(),LOCATION_HAND,0,nil,CARD_DREGS_ANGRA_MAINYU)>=2 end)
    c:RegisterEffect(e5)
    local e6=e5:Clone()
    e6:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    c:RegisterEffect(e6)

    -- 3+: The ATK/DEF of any monster this card battles becomes 0 during damage calculation only, also negate their effects during damage calculation only.
    local e7=Effect.CreateEffect(c)
    e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e7:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e7:SetRange(LOCATION_MZONE)
    e7:SetCondition(s.dropcon)
    e7:SetOperation(s.dropop)
    c:RegisterEffect(e7)

    --10+: Your opponent's maximum hand size becomes infinite, also they cannot use monsters with less ATK than this card as material for a summon. 
    local e8=Effect.CreateEffect(c)
    e8:SetType(EFFECT_TYPE_FIELD)
    e8:SetCode(EFFECT_HAND_LIMIT)
    e8:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e8:SetRange(LOCATION_MZONE)
    e8:SetTargetRange(0,1)
    e8:SetValue(99)
    e8:SetCondition(function(e) return Duel.GetMatchingGroupCount(Card.IsCode,1-e:GetHandler():GetControler(),LOCATION_HAND,0,nil,CARD_DREGS_ANGRA_MAINYU)>=10 end)
    c:RegisterEffect(e8)

    local e9=Effect.CreateEffect(c)
    e9:SetType(EFFECT_TYPE_FIELD)
    e9:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    e9:SetRange(LOCATION_MZONE)
    e9:SetTargetRange(0,LOCATION_MZONE)
    e9:SetValue(s.splimit2)
    e9:SetCondition(function(e) return Duel.GetMatchingGroupCount(Card.IsCode,1-e:GetHandler():GetControler(),LOCATION_HAND,0,nil,CARD_DREGS_ANGRA_MAINYU)>=10 end)
    c:RegisterEffect(e9)
end
s.listed_series={SET_FATED}
s.listed_names={CARD_DREGS_ANGRA_MAINYU}

function s.splimit(e,se,sp,st)
    local tc=se:GetHandler()
    return tc:IsSetCard(SET_FATED) and tc:IsMonster() and tc:IsAttribute(ATTRIBUTE_DARK)
end

function s.atkval(e,c)
    local tp=c:GetControler()
    local g=Duel.GetMatchingGroup(Card.IsCode,1-tp,LOCATION_HAND,0,nil,CARD_DREGS_ANGRA_MAINYU)
    return g:GetCount()*1000
end

function s.mretcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(Card.IsCode,1-tp,LOCATION_HAND,0,nil,CARD_DREGS_ANGRA_MAINYU)==0 and Spirit.CommonCondition(e) and not e:GetHandler():IsHasEffect(EFFECT_SPIRIT_MAYNOT_RETURN)
end

function s.oretcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(Card.IsCode,1-tp,LOCATION_HAND,0,nil,CARD_DREGS_ANGRA_MAINYU)==0 and Spirit.CommonCondition(e) and e:GetHandler():IsHasEffect(EFFECT_SPIRIT_MAYNOT_RETURN)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetMatchingGroupCount(Card.IsCode,1-tp,LOCATION_HAND,0,nil,CARD_DREGS_ANGRA_MAINYU)>=1 and re and re:GetHandler():IsAttribute(ATTRIBUTE_DARK)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
        WbAux.AddDregs(1-tp,1)
    end
end

function s.dropcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local bc=c:GetBattleTarget()
    return Duel.GetMatchingGroupCount(Card.IsCode,1-tp,LOCATION_HAND,0,nil,CARD_DREGS_ANGRA_MAINYU)>=3
        and bc and bc:IsFaceup() and bc:IsRelateToBattle()
end

function s.dropop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local bc=c:GetBattleTarget()
    --Change ATK/DEF to 0
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SET_ATTACK_FINAL)
    e1:SetValue(0)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
    bc:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
    bc:RegisterEffect(e2)
    --Negate effects
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_DISABLE)
    e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
    bc:RegisterEffect(e3)
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_DISABLE_EFFECT)
    e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
    bc:RegisterEffect(e4)
end

function s.splimit2(e,c)
    if not c then return false end
    return c:GetAttack()<e:GetHandler():GetAttack()
end