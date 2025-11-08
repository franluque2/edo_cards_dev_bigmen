--Presence of the Sun God
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
    e1:SetCost(s.quickcost)
	e1:SetTarget(s.target)
    e1:SetLabel(0)
	e1:SetOperation(s.activate)
    e1:SetCountLimit(1,{id,0})
	c:RegisterEffect(e1)
	

    	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SUMMON_SUCCESS)
		Duel.RegisterEffect(ge2,0)
	end)

    	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
    e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_RECOVER)
    e2:SetDescription(aux.Stringid(id,9))
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.tg)
    e2:SetCountLimit(1,{id,1})
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)


    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e3:SetRange(LOCATION_HAND)
	e3:SetValue(function(e,c) e:SetLabel(1) end)
	e3:SetCondition(function(e) return Duel.IsExistingMatchingCard(s.revfilter,e:GetHandlerPlayer(),LOCATION_HAND,0,1,c) end)
	c:RegisterEffect(e3)
    e1:SetLabelObject(e3)


end
s.listed_names={CARD_RA}
function s.revfilter(c)
    return c:IsRace(RACE_AQUA|RACE_DIVINE) and not c:IsPublic()
end

function s.quickcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then e:GetLabelObject():SetLabel(0) return true end
	if e:GetLabelObject():GetLabel()>0 then
		e:GetLabelObject():SetLabel(0)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
        local g=Duel.SelectMatchingCard(tp,s.revfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
        if #g>0 then
            Duel.ConfirmCards(1-tp,g)
            e:GetLabelObject():SetLabel(1)
            Duel.ShuffleHand(tp)
        end
	end
end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	for tc in aux.Next(eg) do
		Duel.RegisterFlagEffect(tc:GetSummonPlayer(),id,RESET_PHASE|PHASE_END,0,1)
	end
end

function s.spfilter(c,e,tp)
	return c:IsCode(CARD_RA) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp)
            and Duel.IsMainPhase()
         end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_MZONE)
end

function s.desfilter(c,e)
    return not (c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DIVINE))
end

function s.atkfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_RA)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,8))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_FUSION) end)
	e1:SetReset(RESET_PHASE|PHASE_END,2)
	Duel.RegisterEffect(e1,tp)

	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if sc and Duel.SpecialSummon(sc,0,tp,tp,true,true,POS_FACEUP)>0 then
		aux.DelayedOperation(sc,PHASE_END,id,e,tp,function(ag) Duel.Destroy(ag,REASON_EFFECT) end,nil,0)

        local b1=Duel.CheckLPCost(tp, 1000) and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
        local b2=Duel.CheckLPCost(tp, 101)
        local b3=b1 and b2 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(1-tp,id)>=5 and Duel.GetCurrentPhase()==PHASE_MAIN1
        if not (b1 or b2 or b3) then return end
        local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,2)},{b2,aux.Stringid(id,3)},{b3,aux.Stringid(id,5)},{true,aux.Stringid(id,6)})
        if op==4 then return end
        Duel.BreakEffect()
        if op==1 or op==3 then
            Duel.PayLPCost(tp, 1000)
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
            local dg=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
            if #dg>0 then
                Duel.HintSelection(dg)
                Duel.Destroy(dg,REASON_EFFECT)
            end
        end

        if op==2 or op==3 then
            local cost=Duel.GetLP(tp)-100
	        Duel.PayLPCost(tp,cost)
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACK)
            local tc=Duel.SelectMatchingCard(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
            Duel.HintSelection(tc)
            local atk=cost
            if atk>0 and tc then
                tc:UpdateAttack(atk,nil,c)
                tc:UpdateDefense(atk,nil,c)
	        end
            if Duel.GetTurnPlayer()~=tp then
                Duel.BreakEffect()
                	local e2=Effect.CreateEffect(e:GetHandler())
                    e2:SetType(EFFECT_TYPE_FIELD)
                    e2:SetDescription(aux.Stringid(id, 4))
			        e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)

                    e2:SetCode(EFFECT_MUST_ATTACK)
                    e2:SetTargetRange(0,LOCATION_MZONE)
                    e2:SetReset(RESET_PHASE|PHASE_BATTLE)
                    Duel.RegisterEffect(e2,tp)
                    local e3=e2:Clone()
                    e3:SetCode(EFFECT_MUST_ATTACK_MONSTER)
                    e3:SetValue(s.atklimit)
                    Duel.RegisterEffect(e3,tp)

                    tc:CreateEffectRelation(e3)

            end
        end

        if op==3 then
            	local e4=Effect.CreateEffect(c)
                e4:SetType(EFFECT_TYPE_FIELD)
                e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
                e4:SetCode(EFFECT_BP_FIRST_TURN)
                e4:SetTargetRange(1,1)
                e4:SetReset(RESET_PHASE|PHASE_END)
                Duel.RegisterEffect(e4,tp)


                local e5=Effect.CreateEffect(e:GetHandler())
                e5:SetType(EFFECT_TYPE_FIELD)
                e5:SetCode(EFFECT_CANNOT_EP)
                e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_PLAYER_TARGET)
                e5:SetCondition(s.bpcondition)
                e5:SetTargetRange(1,1)
                e5:SetReset(RESET_PHASE|PHASE_END)
                Duel.RegisterEffect(e5,tp)


                local e6=Effect.CreateEffect(e:GetHandler())
                e6:SetDescription(aux.Stringid(id,7))
                e6:SetType(EFFECT_TYPE_FIELD)
                e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
                e6:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
                e6:SetTargetRange(1,1)
                e6:SetValue(HALF_DAMAGE)
                e6:SetReset(RESET_PHASE|PHASE_END)
                Duel.RegisterEffect(e6,tp)

                if Duel.GetTurnPlayer()~=tp then
                    Duel.SkipPhase(1-tp,Duel.GetCurrentPhase(),RESET_PHASE|PHASE_END,1)
                else
                    Duel.SkipPhase(tp,Duel.GetCurrentPhase(),RESET_PHASE|PHASE_END,1)
                end


        end

	end
end

function s.atklimit(e,c)
	return c:IsRelateToEffect(e)
end

function s.bpcondition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()<PHASE_BATTLE
end

function s.raatkfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_RA) and c:GetAttack()>0
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.raatkfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.raatkfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.raatkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end


function s.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:GetAttack()>0 then
        local atk=tc:GetAttack()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		tc:RegisterEffect(e2)

        Duel.Recover(tp,atk,REASON_EFFECT)
	end
end