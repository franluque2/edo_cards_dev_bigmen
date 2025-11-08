--Royal Guard of the Snake Deity
local s,id=GetID()
function s.initial_effect(c)
		c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,s.ffilter,2)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
	c:SetSPSummonOnce(id)


	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.defval)
	c:RegisterEffect(e1)

		local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(s.bttg)
	c:RegisterEffect(e2)


		local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,0})
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)

	    local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCountLimit(1,{id,1})
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_BATTLE_START)
	e4:SetTarget(s.efftg)
	e4:SetOperation(s.effop)
	c:RegisterEffect(e4)
end
s.listed_series={0x50} -- Venom
s.listed_names={54306223, 8062132} -- Venom Swamp, Vennominaga the Deity of Poisonous Snakes

function s.ffilter(c,fc,sumtype,sp,sub,mg,sg)
	return c:IsSetCard(SET_VENOM,fc,sumtype,sp)
		and c:IsRace(RACE_REPTILE) and c:IsLevelBelow(8)
end

function s.matfil(c,tp)
	return c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,false,true)
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(s.matfil,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil,tp)
end
function s.contactop(g)
	Duel.Remove(g,POS_FACEUP,REASON_COST|REASON_MATERIAL)
end

function s.defval(e,c)
	return Duel.GetMatchingGroupCount(Card.IsRace,c:GetControler(),LOCATION_GRAVE,0,nil,RACE_REPTILE)*500
end

function s.bttg(e,c)
	return c~=e:GetHandler() and c:IsFaceup() and c:IsRace(RACE_REPTILE)
end


function s.thfilter(c)
	return (c:IsCode(54306223) or (c:IsSpellTrap() and c:ListsCode(8062132))) and (c:IsAbleToHand() or c:IsSSetable())
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	aux.ToHandOrElse(tc,tp,
			function(tc) return tc:IsSSetable() end,
			function(tc) Duel.SSet(tp,tc) end,
			aux.Stringid(id,1)
		)
end


function s.filter1(c)
    return c:IsFaceup() and c:IsOriginalCode(54306223)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk, chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsFaceup() and chkc:IsOriginalCode(54306223) end
    if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_ONFIELD,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter1,tp,LOCATION_ONFIELD,0,1,1,nil)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and tc:IsFaceup() then
        Duel.HintSelection(tc)
        s.acop(e,tp,eg,ep,ev,re,r,rp)
    end
end

function s.acop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	local tg=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	local tc=tg:GetFirst()
	for tc in aux.Next(tg) do
		if tc:IsCanAddCounter(COUNTER_VENOM,3) and not tc:IsSetCard(SET_VENOM) then
			local atk=tc:GetAttack()
			tc:AddCounter(COUNTER_VENOM,3)
			if atk>0 and tc:GetAttack()==0 then
				g:AddCard(tc)
			end
		end
	end
	if #g>0 then
		Duel.RaiseEvent(g,EVENT_CUSTOM+54306223,e,0,0,0,0)
	end
    Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+54306223+1,e,0,0,0,3)
end