--Hydradrive Advent
local s,id=GetID()
function s.initial_effect(c)
	--skill
		--Activate
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
	aux.AddSkillProcedure(c,2,false,s.flipcon2,s.flipop2)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_SPSUMMON_SUCCESS)
		e2:SetCondition(s.flipcon3)
		e2:SetOperation(s.flipop3)
		Duel.RegisterEffect(e2,tp)
	end
	e:SetLabel(1)
end


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	s.swap_dragid(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(ep,id,0,0,0)
end

function s.dragid_filter(c)
return c:IsCode(511600365)
end

function s.swap_dragid(e,tp,eg,ep,ev,re,r,rp)
local hg=Duel.GetMatchingGroup(s.dragid_filter,tp,LOCATION_EXTRA,0,nil)
if #hg>0 then
			for card in aux.Next(hg)do
			Duel.SendtoDeck(card,tp,-2,REASON_EFFECT)
			local newdrag=Duel.CreateToken(tp,81632008)
			--newdrag:RegisterEffect(e1,true)
			Duel.SendtoDeck(newdrag,tp,SEQ_DECKTOP,REASON_EFFECT)
	end

end
end

function s.adcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end

local tableHydra_l1={511009711,511009713,511009714,511600223,511027009}
local tableHydra_l2={511009716}
local tableHydra_l3={511106013,81632167, 81632168}
local tableHydra_l4={81632169}

function s.getcard1()
return tableHydra_l1[ Duel.GetRandomNumber(1, #tableHydra_l1 ) ]
end
function s.getcard2()
return tableHydra_l2[ Duel.GetRandomNumber(1, #tableHydra_l2 ) ]
end

function s.getcard3()
return tableHydra_l3[ Duel.GetRandomNumber(1, #tableHydra_l3 ) ]
end

function s.getcard4()
return tableHydra_l4[ Duel.GetRandomNumber(1, #tableHydra_l4 ) ]
end


function s.adop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.CreateToken(tp,s.getcard())
	Duel.SendtoDeck(g,tp,SEQ_DECKTOP,REASON_EFFECT)
end

function s.hydra_d_filter(c,label)
	return (c:IsSetCard(0x577) and c:IsAbleToHand() and (not c:IsCode(label))) -- or c:IsCode(511009503)
end


function s.hydra_r_filter(c,tp)
	return c:IsSetCard(0x577) and c:IsAbleToRemoveAsCost()
end

function gethydradrive(lv)
	if lv==1 then
		return s.getcard1()
	elseif lv==2 then
		return s.getcard2()
	elseif lv==3 then
		return s.getcard3()
	elseif lv==4 then
		return s.getcard4()
end
end

--Add 1 Hydradrive link to extra deck, banish 1 hydradrive to add a hydradrive
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--opt check
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0 then return end
	--condition
	local b1=Duel.GetFlagEffect(tp,id+1)==0
	local b2=Duel.GetFlagEffect(tp,id+2)==0 and Duel.IsExistingMatchingCard(s.hydra_r_filter,tp,LOCATION_GRAVE,0,1,nil,tp) and Duel.IsExistingMatchingCard(s.hydra_d_filter,tp,LOCATION_DECK,0,1,nil,tp)

	return aux.CanActivateSkill(tp) and (b1 or b2)
end

--c:RegisterFlagEffect(id,,0,1,fid)
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local b1=Duel.GetFlagEffect(ep,id+1)==0
	local b2=Duel.GetFlagEffect(ep,id+2)==0 and Duel.IsExistingMatchingCard(s.hydra_r_filter,tp,LOCATION_GRAVE,0,1,nil,tp) and Duel.IsExistingMatchingCard(s.hydra_d_filter,tp,LOCATION_DECK,0,1,nil,tp)
	if (b2 and b1) then
		p=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif b1 then
		p=Duel.SelectOption(tp,aux.Stringid(id,0))
	else
		p=Duel.SelectOption(tp,aux.Stringid(id,1))+1
	end
	if p==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
		local lv=Duel.AnnounceLevel(tp,1,4)
		local tokenid=gethydradrive(lv)

		local g=Duel.CreateToken(tp,tokenid)
		Duel.SendtoDeck(g,tp,SEQ_DECKTOP,REASON_EFFECT)
		--opt register
		Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
	else
		local g1=Duel.SelectMatchingCard(tp,s.hydra_r_filter,tp,LOCATION_GRAVE,0,1,1,nil)
		if #g1<=0 then return end
		local tpid=g1:GetFirst():GetCode()
		if Duel.Remove(g1,POS_FACEUP,REASON_EFFECT)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.hydra_d_filter,tp,LOCATION_DECK,0,1,1,tpid)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
		--opt register
		Duel.RegisterFlagEffect(tp,id+2,0,0,0)

	end
end
end


function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsSummonPlayer(tp) and c:IsCode(81632008) and c:IsSummonType(SUMMON_TYPE_LINK)
end

function s.tokenfilter(c)
	return c:IsType(TYPE_TOKEN)
end

function s.fieldspellfilter(c)
	return c:IsCode(81632904) and c:IsFaceup()
end

function s.filter(c,tp)
	return c:IsCode(4064256) and c:GetActivateEffect() and c:GetActivateEffect():IsActivatable(tp,true,true)
end

function s.flipcon3(e,tp,eg,ep,ev,re,r,rp)
	--opd check
	if Duel.GetFlagEffect(tp,id+3)>0 then return end
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) and eg:IsExists(s.cfilter,1,nil,tp)
end
function s.flipop3(e,tp,eg,ep,ev,re,r,rp)
		Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
		Duel.Hint(HINT_CARD,tp,id)
		--disable other parts of the skill
		Duel.RegisterFlagEffect(tp,id+1,0,0,0)
		Duel.RegisterFlagEffect(tp,id+2,0,0,0)
		--opd register
		Duel.RegisterFlagEffect(tp,id+3,0,0,0)

		e:GetHandler():Recreate(id+1)
		Duel.Hint(HINT_SKILL_REMOVE,tp,id)
		Duel.Hint(HINT_SKILL_FLIP,tp,(id+1)|(1<<32))
		Duel.Hint(HINT_SKILL,tp,id+1)

			local hydra1=Duel.CreateToken(tp,81632002)
			 local hydra2=Duel.CreateToken(tp,81632003)
			 local hydra3=Duel.CreateToken(tp,81632004)
			 local hydra4=Duel.CreateToken(tp,81632005)
			 local hydra5=Duel.CreateToken(tp,81632006)
			 local hydra6=Duel.CreateToken(tp,81632007)

			 local perfectron=Duel.CreateToken(tp, 511027001)

		g=Group.CreateGroup()
		g:AddCard(hydra1)
		g:AddCard(hydra2)
		g:AddCard(hydra3)
		g:AddCard(hydra4)
		g:AddCard(hydra5)
		g:AddCard(hydra6)
		g:AddCard(perfectron)
		Duel.SendtoDeck(g,tp,SEQ_DECKTOP,REASON_EFFECT)

local e2=Effect.CreateEffect(e:GetHandler())
e2:SetType(EFFECT_TYPE_FIELD)
e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
e2:SetTargetRange(LOCATION_MZONE,0)
e2:SetTarget(s.target)
e2:SetValue(1)
Duel.RegisterEffect(e2,tp)
local e3=e2:Clone()
e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
Duel.RegisterEffect(e3,tp)



end

function s.target(e,c)
	return c:IsLink(5)
end
