--Serket the Great Beast
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)


    --copy
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)


    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetHintTiming(0,TIMING_MAIN_END+TIMINGS_CHECK_MONSTER)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(function(_,tp) return Duel.IsTurnPlayer(1-tp) end)
    e3:SetCost(s.selfspcost)
	e3:SetTarget(s.selfsptg)
	e3:SetOperation(s.selfspop)
	c:RegisterEffect(e3)



    Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)

end
s.listed_names={CARD_EXCHANGE_SPIRIT}

function s.counterfilter(c)
	return c:IsType(TYPE_FUSION) or c:GetSummonLocation()~=LOCATION_EXTRA
end

function s.selfspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	--Cannot Special Summon from the Extra Deck, except Fusions
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
	--lizard check
	aux.addTempLizardCheck(e:GetHandler(),tp,s.lizfilter)
end

function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_GRAVE, 0, 1, nil, CARD_EXCHANGE_SPIRIT) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- Banish it when it leaves the field
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
	end
end

function s.spcfilter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsMonster() and c:IsAbleToGraveAsCost()
end

function s.check(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetCode)==2 and sg:GetClassCount(Card.GetLocation)==2
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_HAND+LOCATION_DECK,0,e:GetHandler())
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
		and aux.SelectUnselectGroup(rg,e,tp,2,2,s.check,0) end
	local g=aux.SelectUnselectGroup(rg,e,tp,2,2,s.check,1,tp,HINTMSG_TOGRAVE)
	Duel.SendtoGrave(g,REASON_COST)
	--Cannot Special Summon from the Extra Deck, except Fusions
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
	--lizard check
	aux.addTempLizardCheck(e:GetHandler(),tp,s.lizfilter)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
function s.lizfilter(e,c)
	return not c:IsOriginalType(TYPE_FUSION)
end




function s.filter(c)
	return c:IsContinuousTrap()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil)
	g:Remove(s.codefilterchk,nil,e:GetHandler())
	if c:IsFacedown() or #g<=0 then return end
	repeat
		local tc=g:GetFirst()
		local code=tc:GetOriginalCode()

        local effs={tc:GetOwnEffects()}



        for key, te in ipairs(effs) do
            if te:IsHasType(EFFECT_TYPE_FIELD) and not (te:IsHasType(EFFECT_TYPE_TRIGGER_F) or te:IsHasType(EFFECT_TYPE_TRIGGER_O) or te:IsHasType(EFFECT_TYPE_ACTIVATE) or te:IsHasProperty(EFFECT_FLAG_UNCOPYABLE)) then
                local e1=te:Clone()
                e1:SetRange(LOCATION_MZONE)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                if e1:GetProperty() then
                    e1:SetProperty(e1:GetProperty()+EFFECT_FLAG_CANNOT_DISABLE)
                else
                    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                end

                c:RegisterEffect(e1)

                local e0=Effect.CreateEffect(c)
                e0:SetCode(id)
                e0:SetLabel(code)
                e0:SetLabelObject(e1)
                e0:SetReset(RESET_EVENT+RESETS_STANDARD)
                c:RegisterEffect(e0,true)
                local e2=Effect.CreateEffect(c)
                e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
                e2:SetCode(EVENT_ADJUST)
                e2:SetRange(LOCATION_MZONE)
                e2:SetLabelObject(e0)
                e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                e2:SetOperation(s.resetop)
                e2:SetReset(RESET_EVENT+RESETS_STANDARD)
                c:RegisterEffect(e2,true)
        
            end
        end

        c:RegisterFlagEffect(code,RESET_EVENT+RESETS_STANDARD,0,0)

		g:Remove(s.codefilter,nil,code)

	until #g<=0
end
function s.codefilter(c,code)
	return c:IsOriginalCode(code) and c:IsContinuousTrap()
end
function s.codefilterchk(c,sc)
	return sc:GetFlagEffect(c:GetOriginalCode())>0
end
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil)
	if not g:IsExists(s.codefilter,1,nil,e:GetLabelObject():GetLabel()) then
        e:GetLabelObject():GetLabelObject():Reset()
		c:ResetFlagEffect(e:GetLabelObject():GetLabel())
        e:GetLabelObject():Reset()
        e:Reset()
	end
end
