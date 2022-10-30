--Sakutersu Altar (CT)
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,2,nil) end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tg=Duel.GetAttacker()
	if chk==0 then return tg:IsOnField() end
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
end

function s.dekaizofilter(c)
	return c:IsFaceup() and c:IsCode(81632205) and c:IsDestructable()
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	Duel.HintSelection(g)
	if g and Duel.SendtoDeck(g,nil,2,REASON_COST)>0 then
		--Effect
		local tc=Duel.GetAttacker()
		if tc and tc:CanAttack() and tc:IsRelateToBattle() and not tc:IsStatus(STATUS_ATTACK_CANCELED) then
			local tg=Group.CreateGroup()
			tg:AddCard(tc)
			tg=tg:AddMaximumCheck()
			if Duel.Destroy(tg,REASON_EFFECT)>0 then
				if Duel.IsExistingMatchingCard(s.dekaizofilter, tp, LOCATION_MZONE,0, 1,nil) then
					local targ=Duel.SelectMatchingCard(tp, s.dekaizofilter, tp, LOCATION_MZONE, 0, 1,1,false,nil):GetFirst()
						if targ then
							local c=e:GetHandler()
							local e3=Effect.CreateEffect(c)
							e3:SetType(EFFECT_TYPE_SINGLE)
							e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
							e3:SetRange(LOCATION_MZONE)
							e3:SetReset(RESETS_STANDARD+RESET_PHASE+PHASE_END)
							e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
							e3:SetValue(1)
							targ:RegisterEffect(e3)
							local e4=e3:Clone()
							e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
							targ:RegisterEffect(e4)


						end

				end
			end
		end
	end
end
