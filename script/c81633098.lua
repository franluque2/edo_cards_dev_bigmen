--The Ultimate Rush Duel! - The Lord of Chaos
Duel.LoadScript("big_aux.lua")


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

		--other passive duel effects go here

		bRush.addrules()(e,tp,eg,ep,ev,re,r,rp)

		local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e2:SetCountLimit(1)
        e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
        e2:SetCondition(s.sendcon)
        e2:SetOperation(s.sendop)
        Duel.RegisterEffect(e2,tp)


		local e6=Effect.CreateEffect(e:GetHandler())
		e6:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e6:SetCode(EFFECT_DESTROY_REPLACE)
		e6:SetTarget(s.desreptg)
		e6:SetValue(s.desrepval)
		e6:SetOperation(s.desrepop)
		Duel.RegisterEffect(e6,tp)


		local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
        e3:SetCode(EVENT_LEAVE_FIELD)
        e3:SetCountLimit(1)
        e3:SetCondition(s.summonlackeyscon)
        e3:SetOperation(s.summonlackeysop)
        Duel.RegisterEffect(e3,tp)

		local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetCountLimit(1)
		e4:SetCode(EVENT_PHASE+PHASE_END)
		e4:SetCondition(s.setcon)
		e4:SetOperation(s.setop)
		Duel.RegisterEffect(e4,tp)


	end
	e:SetLabel(1)
end

function s.ishighleveldarkspellcasterfilter(c)
    return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevelAbove(7) and c:IsFaceup()
end

function s.darknessroadbackrowfilter(c)
    return c:IsCode(511310100,1475311,78811937,80168720,81632424,160203027,
	511000418,69542930,511000357,21862633,90434926,511002451,59160188,
	100000080,160428020,511310023,29826127,79766336,81632425,100000264,9030160,78637313,
	84970821,511000958,511001528,511310101,511310102,511310103,36935434,58120309,100000553,
	160428021,511000318,62829077,160001039,160002036,160006039,160402001,160402001,160402003,
	160428019,69042950,160011050,160012045,2144946)
end

local CARDS_TO_ADD={160013054,160428019}
local darkspells={}
darkspells[0]=Group.CreateGroup()
darkspells[1]=Group.CreateGroup()

local LACKEYS_TO_SUMMON={160004037,160006028,160008025,160205022,160202042}
local lackeys={}
lackeys[0]=Group.CreateGroup()
lackeys[1]=Group.CreateGroup()

function s.darknessroadbackrowsetfilter(c)
    return s.darknessroadbackrowfilter(c) and c:IsSSetable()
end


function s.monsterordarknessroadbackrowaddfilter(c,code)
    return ((c:IsMonster() and c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK) and not c:IsCode(code)) or (s.darknessroadbackrowfilter(c))) and c:IsAbleToHand()
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	if (Duel.GetFlagEffect(tp,id+5)>0) then return false end
	local g=Duel.IsExistingMatchingCard(s.ishighleveldarkspellcasterfilter, tp, LOCATION_ONFIELD, 0, 1,nil)
	return Duel.GetTurnPlayer()==tp and g and (Duel.GetLocationCount(tp,LOCATION_SZONE)>0) and Duel.IsExistingMatchingCard(s.darknessroadbackrowsetfilter,tp,LOCATION_GRAVE,0,1,nil)
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)

    if Duel.SelectYesNo(tp, aux.Stringid(id, 6)) then
        local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.darknessroadbackrowsetfilter),tp,LOCATION_GRAVE,0,nil)

		local sg=aux.SelectUnselectGroup(tg,e,tp,1,1,aux.dncheck,1,tp,HINTMSG_TARGET)
		if #sg>0 then
		Duel.Hint(HINT_CARD, tp, id)

			
		local g=sg:GetFirst()

        while g do
			
            Duel.SSet(tp, g)
            --Banish it if it leaves the field
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetDescription(3301)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
            e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
            e1:SetValue(LOCATION_DECKBOT)
            g:RegisterEffect(e1)
			
			g=sg:GetNext()
        end
		
		end

	end

	--sets the opd
	Duel.RegisterFlagEffect(tp,id+5,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


function s.darksevensfilter(c,tp)
    return (c:GetReasonPlayer()~=c:GetControler()) and c:IsCode(160428005) and c:GetControler()==tp
end

function s.summonlackeyscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp, id+4)==0 and eg:IsExists(s.darksevensfilter, 1, nil,tp) and Duel.GetLocationCount(tp, LOCATION_MZONE)>0
end

function s.summonlackeysop(e,tp,eg,ep,ev,re,r,rp)
	local num=Duel.GetLocationCount(tp, LOCATION_MZONE)
	if Duel.SelectYesNo(tp, aux.Stringid(id, 7)) then
		Duel.Hint(HINT_CARD,tp,id)
		Duel.RegisterFlagEffect(tp,id+4,0,0,0)

		for i = 1, num, 1 do
			local lackey=lackeys[tp]:TakeatPos(Duel.GetRandomNumber(1,#lackeys[tp]))
			Duel.SpecialSummon(lackey, SUMMON_TYPE_SPECIAL, tp, tp, false,false, POS_FACEUP)
			lackeys[tp]:RemoveCard(lackey)
			
			local e5=Effect.CreateEffect(e:GetHandler())
			e5:SetType(EFFECT_TYPE_SINGLE)
			e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
			e5:SetCode(EFFECT_CHANGE_RACE)
			e5:SetValue(RACE_SPELLCASTER)
			lackey:RegisterEffect(e5)

			local e6=e5:Clone()
			e6:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e6:SetValue(ATTRIBUTE_DARK)
			lackey:RegisterEffect(e6)
		end


	end
end



function s.repfilter(c,tp)
	return c:IsControler(tp) and c:IsCode(160428005) and c:IsFaceup() and c:IsLocation(LOCATION_ONFIELD)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		and c:GetReasonPlayer()~=tp
end
function s.desfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToDeckAsCost()
end
function s.cfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToDeckAsCost()
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
		and g:GetClassCount(Card.GetCode)>2 end
	if Duel.SelectYesNo(tp,aux.Stringid(id, 5)) then
		local sg=aux.SelectUnselectGroup(g,e,tp,3,3,aux.dncheck,1,tp,HINTMSG_DESREPLACE)
		Duel.HintSelection(sg)
		Duel.SendtoDeck(sg, tp, SEQ_DECKBOTTOM, REASON_EFFECT+REASON_REPLACE)
		return true
	else return false end
end
function s.desrepval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
end


function s.sendcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
end

function s.darkspellcasterfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK)
end

function s.differentspellcasterfilter(c, code)
	return s.darkspellcasterfilter(c) and not c:IsCode(code)
end

function s.sendop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
	Duel.Hint(HINT_CARD,tp,id)
	local card=Duel.GetDecktopGroup(tp, 1):GetFirst()
	Duel.ConfirmDecktop(tp, 1)
	if s.darkspellcasterfilter(card) and Duel.SelectYesNo(tp, aux.Stringid(id, 1)) and Duel.SendtoGrave(card, REASON_EFFECT) and Duel.IsExistingMatchingCard(s.differentspellcasterfilter, tp, LOCATION_DECK,0, 1, nil, card:GetCode()) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
		local tc=Duel.SelectMatchingCard(tp, s.differentspellcasterfilter, tp, LOCATION_DECK, 0,1,1,false,nil,card:GetCode())
		Duel.SendtoGrave(tc, REASON_EFFECT)
	 end

	end

end




function s.filltables()
	if #darkspells[0]==0 then
        for i, v in pairs(CARDS_TO_ADD) do
            local token1=Duel.CreateToken(0, v)
            darkspells[0]:AddCard(token1)

            local token2=Duel.CreateToken(1, v)
            darkspells[1]:AddCard(token2)
        end

		for i, v in pairs(LACKEYS_TO_SUMMON) do
            local token1=Duel.CreateToken(0, v)
            lackeys[0]:AddCard(token1)

            local token2=Duel.CreateToken(1, v)
            lackeys[1]:AddCard(token2)
        end
	end
end




function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	local droad=Duel.CreateToken(tp, 160428020)
	Duel.ActivateFieldSpell(droad,e,tp,eg,ep,ev,re,r,rp)


	--start of duel effects go here
	s.filltables()


	Duel.RegisterFlagEffect(tp,id,0,0,0)
end



function s.revtargetfilter(c)
	return c:IsCode(CARD_SEVENS_ROAD_MAGICIAN,160428006) and not c:IsPublic()
end

function s.furoadmagicianfilter(c)
	return c:IsCode(CARD_SEVENS_ROAD_MAGICIAN) and c:IsFaceup()
end


--effects to activate during the main phase go here
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	--checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0  then return end
	--Boolean checks for the activation condition: b1, b2

--do bx for the conditions for each effect, and at the end add them to the return
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.revtargetfilter,tp,LOCATION_HAND,0,1,nil)
						and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>2

	local b2=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.furoadmagicianfilter,tp,LOCATION_ONFIELD,0,1,nil)
			and #darkspells[tp]>0


--return the b1 or b2 or .... in parenthesis at the end
	return aux.CanActivateSkill(tp) and (b1 or b2)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:

--copy the bxs from above

	local b1=Duel.GetFlagEffect(tp,id+1)==0
		and Duel.IsExistingMatchingCard(s.revtargetfilter,tp,LOCATION_HAND,0,1,nil)
				and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>2

	local b2=Duel.GetFlagEffect(tp,id+2)==0
		and Duel.IsExistingMatchingCard(s.furoadmagicianfilter,tp,LOCATION_ONFIELD,0,1,nil)
		and #darkspells[tp]>0

	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,2)},
								  {b2,aux.Stringid(id,4)})
	op=op-1

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	end
end



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
	local card=Duel.SelectMatchingCard(tp, s.revtargetfilter, tp, LOCATION_HAND, 0, 1,1,false,nil):GetFirst()
	if card then
		Duel.ConfirmCards(1-tp, card)
		local g=Duel.GetDecktopGroup(tp, 3)
		Duel.ConfirmDecktop(tp, 3)

		local g2=g:Filter(s.monsterordarknessroadbackrowaddfilter, nil, card:GetCode())
		if #g2>0 and Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local tc=g2:Select(tp, 1,1,false,nil):GetFirst()
			Duel.SendtoHand(tc, tp, REASON_RULE)
			g:RemoveCard(tc)
		end
		Duel.SendtoGrave(g, REASON_EFFECT)
	end


	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)

	Duel.DiscardDeck(tp, 1, REASON_RULE)

	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local tar=darkspells[tp]:Select(tp,1,1,nil):GetFirst()
	darkspells[tp]:RemoveCard(tar)
	Duel.SendtoHand(tar, tp, REASON_RULE)
	Duel.ConfirmCards(1-tp, tar)


	Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end
