--Red-Eyes Revenant Necro Dragon
local s,id=GetID()
function s.initial_effect(c)	
    --synchro: 1 Tuner + 1+ non-Tuner Zombie monsters
    c:EnableReviveLimit()
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(Card.IsRace,RACE_ZOMBIE),1,99)

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return Duel.IsMainPhase() and Duel.IsTurnPlayer(tp) end)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():IsPreviousLocation(LOCATION_SZONE) end)
    e2:SetTarget(s.restarget)
    e2:SetOperation(s.resoperation)
    c:RegisterEffect(e2)
end

--Effect 1: Special Summon from opponent's GY and equip
function s.eqfilter(c,ec,e,tp)
    return c:IsType(TYPE_MONSTER) and c:IsCanBeEffectTarget(e) and c:IsLocation(LOCATION_GRAVE)
        and c:IsReason(REASON_MATERIAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and s.eqfilter(chkc,e:GetHandler(),e,tp) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingTarget(s.eqfilter,tp,0,LOCATION_GRAVE,1,nil,e:GetHandler(),e,tp)
            and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
         end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,s.eqfilter,tp,0,LOCATION_GRAVE,1,1,nil,e:GetHandler(),e,tp)
    Duel.HintSelection(g)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
    --Equip limit
        Duel.Equip(tp,c,tc,true)
        local e4=Effect.CreateEffect(c)
        e4:SetType(EFFECT_TYPE_SINGLE)
        e4:SetCode(EFFECT_EQUIP_LIMIT)
        e4:SetReset(RESET_EVENT|RESETS_STANDARD)
        e4:SetValue(s.eqlimit)
        e4:SetLabelObject(tc)
        c:RegisterEffect(e4)


    --banish it when it leaves the field
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetDescription(3300)
    e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
    e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
    e1:SetValue(LOCATION_REMOVED)
    tc:RegisterEffect(e1,true)

    --it becomes a zombie
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_CHANGE_RACE)
    e3:SetReset(RESET_EVENT+RESETS_STANDARD)
    e3:SetValue(RACE_ZOMBIE)
    tc:RegisterEffect(e3)

    local reasoncard=tc:GetReasonCard()
    if reasoncard then
        --The equipped monster gains ATK equal to the ATK of the monster that was summoned with it as material.
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_EQUIP)
        e2:SetCode(EFFECT_UPDATE_ATTACK)
        e2:SetValue(reasoncard:GetBaseAttack())
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e2)

        -- The equipped monster gains the original effects of the monster that was summoned with it as material.
        local code=reasoncard:GetOriginalCode()
		local cid=tc:CopyEffect(code,RESET_EVENT+RESETS_STANDARD,1)
		tc:RegisterFlagEffect(code+id,RESET_EVENT+RESETS_STANDARD,0,0)
		local e0=Effect.CreateEffect(c)
		e0:SetCode(id)
		e0:SetLabel(code)
		e0:SetLabelObject(e:GetOwner())
		e0:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e0,true)
		local e01=Effect.CreateEffect(c)
		e01:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e01:SetCode(EVENT_ADJUST)
		e01:SetRange(LOCATION_MZONE)
		e01:SetLabel(cid)
		e01:SetLabelObject(e0)
		e01:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e01:SetOperation(s.resetop)
		e01:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e01,true)
    end
end


function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:GetEquipGroup():IsContains(e:GetLabelObject():GetLabelObject()) or e:GetLabelObject():GetLabelObject():IsDisabled() then
		c:ResetEffect(e:GetLabel(),RESET_COPY)
		c:ResetFlagEffect(e:GetLabelObject():GetLabel()+id)
		e:GetLabelObject():Reset()
		e:Reset()
	end
end

--Effect 2: Special Summon from GY
function s.restarget(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.resoperation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
        --You cannot Special Summon monsters from the Extra Deck for the rest of this turn, except Zombie monsters.
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetDescription(aux.Stringid(id,2))
        e1:SetTargetRange(1,0)
        e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsRace(RACE_ZOMBIE) end)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end



function s.eqlimit(e,c)
	return e:GetLabelObject()==c
end