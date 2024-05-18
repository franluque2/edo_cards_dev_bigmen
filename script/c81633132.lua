--Galactical Velgearian Warfare
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

    aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end

function s.cfilter(c,p)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(p) and c:IsReason(REASON_EFFECT) and c:GetReasonEffect():GetHandler():IsOwner(1-p)
end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		local tg=eg:Filter(s.cfilter,nil,p)
		for tc in aux.Next(tg) do
			Duel.RegisterFlagEffect(1-p,id+1,RESET_PHASE+PHASE_END,0,1)
		end
	end
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

		bRush.addrules()(e,tp,eg,ep,ev,re,r,rp)

        local e6=Effect.CreateEffect(e:GetHandler())
		e6:SetType(EFFECT_TYPE_FIELD)
		e6:SetTargetRange(LOCATION_GRAVE,0)
		e6:SetCode(EFFECT_CHANGE_RACE)
        e6:SetCondition(s.chgcon)
		e6:SetTarget(s.highlvlgalaxy)
		e6:SetValue(RACE_MACHINE)
		Duel.RegisterEffect(e6, tp)

        local e7=Effect.CreateEffect(e:GetHandler())
		e7:SetType(EFFECT_TYPE_FIELD)
		e7:SetTargetRange(LOCATION_GRAVE,0)
		e7:SetCode(EFFECT_ADD_TYPE)
		e7:SetTarget(s.chtg3)
		e7:SetValue(TYPE_NORMAL)
		Duel.RegisterEffect(e7, tp)

        local e8=Effect.CreateEffect(e:GetHandler())
		e8:SetType(EFFECT_TYPE_FIELD)
		e8:SetTargetRange(LOCATION_GRAVE,0)
		e8:SetCode(EFFECT_CHANGE_CODE)
		e8:SetTarget(s.chtg2)
		e8:SetValue(53129443)
		Duel.RegisterEffect(e8, tp)

        local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e2:SetTargetRange(LOCATION_MZONE,0)
		e2:SetValue(s.efilter)
		Duel.RegisterEffect(e2,tp)

        local e12=Effect.CreateEffect(e:GetHandler())
        e12:SetType(EFFECT_TYPE_FIELD)
        e12:SetCode(EFFECT_FUSION_SUBSTITUTE)
        e12:SetTargetRange(LOCATION_MZONE,0)
        e12:SetTarget(function(_,c)  return c:IsCode(160317012) end)
		e12:SetValue(1)
		Duel.RegisterEffect(e12,tp)

        local e11=Effect.CreateEffect(e:GetHandler())
        e11:SetDescription(aux.Stringid(id,0))
        e11:SetType(EFFECT_TYPE_FIELD)
        e11:SetCode(EFFECT_SUMMON_PROC)
        e11:SetTargetRange(LOCATION_HAND,0)
        e11:SetCondition(s.otcon)
        e11:SetTarget(aux.FieldSummonProcTg(s.ottg,s.sumtg))
        e11:SetOperation(s.otop)
        e11:SetValue(SUMMON_TYPE_TRIBUTE)
		Duel.RegisterEffect(e11,tp)


        local e21=Effect.CreateEffect(e:GetHandler())
        e21:SetType(EFFECT_TYPE_FIELD)
        e21:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
        e21:SetCondition(function (e) return Duel.GetFlagEffect(e:GetHandlerPlayer(), id+1)>0 end)
        e21:SetCountLimit(1)
        e21:SetTargetRange(LOCATION_GRAVE+LOCATION_HAND,0)
        e21:SetTarget(function(e,c) return c:IsAbleToDeck() and c:IsMonster() end)
        e21:SetOperation(Fusion.ShuffleMaterial)
        e21:SetValue(1)
        Duel.RegisterEffect(e21,tp)


	end
	e:SetLabel(1)
end

function s.chgcon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,160210019), e:GetHandlerPlayer(), LOCATION_ONFIELD, 0, 1, nil)
end

function s.highlvlgalaxy(e,c)
    return c:IsOriginalRace(RACE_GALAXY) and (c:IsLevel(7) or c:IsLevel(8)) and c:IsAttribute(ATTRIBUTE_DARK)
end

function s.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=c:GetLevel()
end

function s.ottg(e,c)
	return c:IsLevelAbove(7)
end

function s.efilter(e,re,rp)
	return e:GetHandlerPlayer()==rp
end

function s.sumtg(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.GetDecktopGroup(tp, 8)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end

function s.otop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	if not sg then return end
	Duel.SendtoGrave(sg, REASON_COST)
	sg:DeleteGroup()
end

function s.chtg2(e,c)
	return c:IsSpell() and c:IsLegend()
end


function s.chtg3(e,c)
	return c:IsOriginalRace(RACE_GALAXY) and c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_DARK)
end


local CARDS_TO_ADD={160011044,160012044,160013050,160013051,160210085}
local spells={}
spells[0]=Group.CreateGroup()
spells[1]=Group.CreateGroup()

function s.filltables()
    if #spells[0]==0 then
        for i, v in pairs(CARDS_TO_ADD) do
            local token1=Duel.CreateToken(0, v)
            spells[0]:AddCard(token1)

            local token2=Duel.CreateToken(1, v)
            spells[1]:AddCard(token2)

        end

    end
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
    local dholedev=Duel.CreateToken(tp, 160014050)
    Duel.SendtoGrave(dholedev, REASON_RULE)

    s.filltables()
end

function s.addcardfilter(c)
    return (c:IsCode(CARD_FUSION) or  c:IsType(TYPE_EQUIP) ) and c:IsAbleToHand()
end

function s.swapequipfilter(c)
    return c:IsCode(160011044,160012044,160013050,160013051,160210085) and not c:IsPublic()
end
--effects to activate during the main phase go here
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	--checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
	if Duel.GetFlagEffect(tp,id+2)>0 and Duel.GetFlagEffect(tp,id+3)>0  then return end
	--Boolean checks for the activation condition: b1, b2

--do bx for the conditions for each effect, and at the end add them to the return
	local b1=Duel.GetFlagEffect(tp,id+2)==0
            and Duel.GetFlagEffect(tp, id+1)>0
			and Duel.IsExistingMatchingCard(s.addcardfilter,tp,LOCATION_GRAVE,0,1,nil)

	local b2=Duel.GetFlagEffect(tp,id+3)==0
			and Duel.IsExistingMatchingCard(s.swapequipfilter,tp,LOCATION_HAND,0,1,nil)


--return the b1 or b2 or .... in parenthesis at the end
	return aux.CanActivateSkill(tp) and (b1 or b2)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:

--copy the bxs from above

local b1=Duel.GetFlagEffect(tp,id+2)==0
    and Duel.GetFlagEffect(tp, id+1)>0
    and Duel.IsExistingMatchingCard(s.addcardfilter,tp,LOCATION_GRAVE,0,1,nil)

local b2=Duel.GetFlagEffect(tp,id+3)==0
    and Duel.IsExistingMatchingCard(s.swapequipfilter,tp,LOCATION_HAND,0,1,nil)

--effect selector
	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,1)},
								  {b2,aux.Stringid(id,2)})
	op=op-1

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	end
end



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local tc=Duel.SelectMatchingCard(tp, s.addcardfilter, tp, LOCATION_GRAVE, 0, 1,1,false,nil)
    if tc then
        Duel.SendtoHand(tc, tp, REASON_RULE)
        Duel.ConfirmCards(1-tp, tc)
    end


	Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
    local tc=Duel.SelectMatchingCard(tp, s.swapequipfilter, tp, LOCATION_HAND, 0, 1,1,false,nil)
    if tc then
        Duel.ConfirmCards(1-tp, tc)

        local tochange=Group.Select(spells[tp], tp, 1,1, nil)
        Card.Recreate(tc:GetFirst(), tochange:GetFirst():GetOriginalCode(), nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
        Duel.ShuffleHand(tp)

    end

	Duel.RegisterFlagEffect(tp,id+3,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end
