--Invasion of the Fusion Dimension!
--Duel.LoadScript("big_aux.lua")


local s,id=GetID()
function s.initial_effect(c)
	--Activate Skill
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
	--aux.AddSkillProcedure(c,2,false,s.flipcon2,s.flipop2)

    aux.GlobalCheck(s,function()
		s[0]=0
		s[1]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLE_DAMAGE)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_ADJUST)
		ge2:SetCountLimit(1)
		ge2:SetOperation(s.clear)
		Duel.RegisterEffect(ge2,0)
	end)
end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	s[ep]=s[ep]+ev
end
function s.clear(e,tp,eg,ep,ev,re,r,rp)
	s[0]=0
	s[1]=0
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

        --skip to next turn if first
        local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE_START+PHASE_MAIN1)
		e2:SetCondition(s.skipcon)
		e2:SetOperation(s.skipop)
		Duel.RegisterEffect(e2,tp)

        --cannot take more than 2k lp at a time
        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetCode(EFFECT_CHANGE_DAMAGE)
        e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e3:SetTargetRange(1,0)
        e3:SetValue(s.damval)
        Duel.RegisterEffect(e3,tp)


        --end bp if you take 2k dmg
        local e4=Effect.CreateEffect(e:GetHandler())
        e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e4:SetCode(EVENT_BATTLE_DAMAGE)
        e4:SetCondition(s.endcon)
        e4:SetOperation(s.endop)
        Duel.RegisterEffect(e4,tp)

        --cant summon same turn you special
        local e5=Effect.CreateEffect(e:GetHandler())
        e5:SetType(EFFECT_TYPE_FIELD)
        e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e5:SetCode(EFFECT_CANNOT_SUMMON)
        e5:SetTargetRange(1,0)
        e5:SetTarget(s.sumlimit1)
        Duel.RegisterEffect(e5,tp)
        local e6=e5:Clone()
        e6:SetCode(EFFECT_CANNOT_MSET)
        Duel.RegisterEffect(e6,tp)
        local e7=e5:Clone()
        e7:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e7:SetTarget(s.sumlimit2)
        Duel.RegisterEffect(e7,tp)

        --skip draw to add hunting hound
        local e8=Effect.CreateEffect(e:GetHandler())
		e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e8:SetCode(EVENT_PREDRAW)
		e8:SetCondition(s.addcon)
		e8:SetOperation(s.addop)
		Duel.RegisterEffect(e8,tp)

        --take multiple turns
        local e9=Effect.CreateEffect(e:GetHandler())
		e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e9:SetCode(EVENT_PHASE+PHASE_END)
        e9:SetCountLimit(1)
		e9:SetCondition(s.skipturncon)
		e9:SetOperation(s.skipturnop)
		Duel.RegisterEffect(e9,tp)
	end
	e:SetLabel(1)
end

function s.skipturncon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnPlayer()==tp and Duel.GetTurnCount()>1
end
function s.skipturnop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLP(tp)<=2000 then return end
    if Duel.GetFlagEffect(tp, id+2)<(math.min(Duel.GetLP(tp)/2000)-1) then
        Duel.Hint(HINT_CARD,tp,id)

        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetCode(EFFECT_SKIP_TURN)
        e1:SetTargetRange(0,1)
        e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
        Duel.RegisterEffect(e1,tp)

        Duel.RegisterFlagEffect(tp, id+2, 0, 0, 0)
    else
        Duel.ResetFlagEffect(tp, id+2)
    end
end

function s.atohandhoundfilter(c)
    return c:IsCode(42878636) and c:IsAbleToHand()
end

function s.addcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnPlayer()==tp and Duel.GetFlagEffect(tp, id+1)==0
         and Duel.GetDrawCount(tp)>0 and Duel.IsExistingMatchingCard(s.atohandhoundfilter, tp, LOCATION_DECK+LOCATION_GRAVE, 0, 1, nil)
         and Duel.GetTurnCount()>1
end
function s.addop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
        Duel.Hint(HINT_CARD,tp,id)
        local dt=Duel.GetDrawCount(tp)
        if dt~=0 then
            _replace_count=0
            _replace_max=dt
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
            e1:SetCode(EFFECT_DRAW_COUNT)
            e1:SetTargetRange(1,0)
            e1:SetReset(RESET_PHASE+PHASE_DRAW)
            e1:SetValue(0)
            Duel.RegisterEffect(e1,tp)
        end
        
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local card=Duel.SelectMatchingCard(tp, s.atohandhoundfilter, tp, LOCATION_DECK+LOCATION_GRAVE, 0, 1, 1, false, nil)
        Duel.SendtoHand(card, tp, REASON_RULE)
        Duel.ConfirmCards(1-tp, card)
    end
	Duel.RegisterFlagEffect(ep,id+1,RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end

function s.sumlimit1(e,c,sump,sumtype,sumpos,targetp,se)
	return Duel.GetActivityCount(sump,ACTIVITY_SPSUMMON)>0 and Duel.GetLP(e:GetHandlerPlayer())>2000
end
function s.sumlimit2(e,c,sump,sumtype,sumpos,targetp,se)
	return Duel.GetActivityCount(sump,ACTIVITY_NORMALSUMMON)>0 and Duel.GetLP(e:GetHandlerPlayer())>2000
end



function s.endcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and (s[tp]+Duel.GetBattleDamage(tp))>=2000
end

function s.endop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)

    Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
end

function s.damval(e,re,val,r,rp,rc)
	if val>2000 then return 2000 else return val end
end

function s.skipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetTurnPlayer()==tp
end
function s.skipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)

    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetCode(EFFECT_SKIP_DP)
    e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_OPPO_TURN)
    Duel.RegisterEffect(e1,tp)

    local e2=e1:Clone()
    e2:SetCode(EFFECT_SKIP_BP)
    e2:SetReset(RESET_PHASE+PHASE_BATTLE_START+RESET_OPPO_TURN)
    Duel.RegisterEffect(e2, tp)

    local turnp=Duel.GetTurnPlayer()
    Duel.SkipPhase(turnp,PHASE_DRAW,RESET_PHASE+PHASE_END,1)
    Duel.SkipPhase(turnp,PHASE_STANDBY,RESET_PHASE+PHASE_END,1)
    Duel.SkipPhase(turnp,PHASE_MAIN1,RESET_PHASE+PHASE_END,1)
    Duel.SkipPhase(turnp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1,1)
    Duel.SkipPhase(turnp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_BP)
    e1:SetTargetRange(1,0)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,turnp)
end







function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	--start of duel effects go here

	s.startofdueleff(e,tp,eg,ep,ev,re,r,rp)

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.startofdueleff(e,tp,eg,ep,ev,re,r,rp)
    Duel.SetLP(tp, 6000)

end


--effects to activate during the main phase go here
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	--checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0  then return end
	--Boolean checks for the activation condition: b1, b2

--do bx for the conditions for each effect, and at the end add them to the return
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.icustomfilter,tp,LOCATION_ONFIELD,0,1,nil)
						and Duel.IsExistingMatchingCard(s.conttrapfiler,tp,LOCATION_DECK,0,1,nil)

	local b2=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,tp)


--return the b1 or b2 or .... in parenthesis at the end
	return aux.CanActivateSkill(tp) and (b1 or b2)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:

--copy the bxs from above

	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.icustomfilter,tp,LOCATION_ONFIELD,0,1,nil)
						and Duel.IsExistingMatchingCard(s.conttrapfiler,tp,LOCATION_DECK,0,1,nil)


	local b2=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,tp)

--effect selector
	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
								  {b2,aux.Stringid(id,1)})
	op=op-1 --SelectEffect returns indexes starting at 1, so we decrease the result by 1 to match your "if"s

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	end
end



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)


--sets the opt (replace RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END with 0 to make it an opd)
	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)

	--sets the opd
	Duel.RegisterFlagEffect(tp,id+2,0,0,0)
end
