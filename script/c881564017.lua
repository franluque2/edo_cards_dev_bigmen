--The Fated War Rock Berseker
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
	Spirit.AddProcedure(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)

    --unaffected by your opponent's card effects that would make this card leave the field during their turn while you control a Spellcaster monster.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_IMMUNE_EFFECT)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.imcon)
    e2:SetValue(s.imval)
    c:RegisterEffect(e2)
    --send replace for comprehensive protection
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EFFECT_SEND_REPLACE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.imcon)
    e3:SetTarget(s.reptg)
    e3:SetValue(function(e,c) return false end)
    c:RegisterEffect(e3)

    -- Once per turn, at the start of your Battle Phase, if you control no DARK monsters, you can, for the rest of this turn, apply the following effects:
    -- For the rest of this turn, negate the effects of all other face-up cards you control, except "Illya the Fated Master". 
    -- Your opponent takes twelve times the battle damage from attacks involving this monster.
    -- Other Monsters you control cannot attack. 
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
    e4:SetRange(LOCATION_MZONE)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetCountLimit(1)
    e4:SetCondition(function(e) return Duel.GetTurnPlayer()==e:GetHandlerPlayer() and Duel.GetMatchingGroupCount(Card.IsAttribute,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil,ATTRIBUTE_DARK)==0 end)
    e4:SetOperation(s.batlop)
    c:RegisterEffect(e4)

end
s.listed_series={SET_FATED}
s.listed_names={881564016} -- Illya the Fated Master

function s.splimit(e,se,sp,st)
    return se:GetHandler():IsSetCard(SET_FATED)
end

function s.imcon(e)
    return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
        and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_SPELLCASTER),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

function s.leaveChk(c,category)
    local ex,tg=Duel.GetOperationInfo(0,category)
    return ex and tg~=nil and tg:IsContains(c)
end

function s.imval(e,te)
    if not te then return false end
    local c=e:GetHandler()
    local tc=te:GetOwner()
    if tc:IsControler(e:GetHandlerPlayer()) then return false end
    return (c:GetDestination()>0 and c:GetReasonEffect()==te)
        or (s.leaveChk(c,CATEGORY_TOHAND) or s.leaveChk(c,CATEGORY_DESTROY) or s.leaveChk(c,CATEGORY_REMOVE)
        or s.leaveChk(c,CATEGORY_TODECK) or s.leaveChk(c,CATEGORY_RELEASE) or s.leaveChk(c,CATEGORY_TOGRAVE))
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsReason(REASON_EFFECT) and r&REASON_EFFECT~=0 and re 
        and re:GetOwner():IsControler(1-tp) end
    return true
end


function s.batlop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
    --negate the effects of all other face-up cards you control, except "Illya the Fated Master".
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCode(EFFECT_DISABLE)
    e1:SetTargetRange(LOCATION_ONFIELD,0)
    e1:SetTarget(function(_,tc) return tc:IsFaceup() and (not tc:IsMonster() or (tc:IsType(TYPE_EFFECT) or (tc:GetOriginalType()&TYPE_EFFECT)==TYPE_EFFECT)) and tc~=c and not tc:IsCode(881564016) end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)

    --Your opponent takes twelve times the battle damage from attacks involving this monster.
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
    e3:SetCondition(function() return Duel.GetAttackTarget()==c or Duel.GetAttacker()==c end)
    e3:SetValue(function(e,c) return Duel.GetBattleDamage(1-e:GetHandlerPlayer())*12 end)
    e3:SetReset(RESET_PHASE+PHASE_END)
    c:RegisterEffect(e3)

    --Other Monsters you control cannot attack. 
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_CANNOT_ATTACK)
    e4:SetTargetRange(LOCATION_MZONE,0)
    e4:SetTarget(function(_,tc) return tc:IsFaceup() and tc~=c end)
    e4:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e4,tp)

end