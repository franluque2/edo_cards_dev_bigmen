--Baby Venom Boa
local s,id=GetID()
function s.initial_effect(c)
    	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND|LOCATION_MZONE)
	e1:SetCost(Cost.SelfToGrave)
	e1:SetTarget(s.pltg)
	e1:SetOperation(s.plop)
	c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(s.efftg)
    e2:SetCost(Cost.SelfBanish)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)


end
s.listed_names={54306223} -- Venom Swamp

function s.plfilter(c)
	return c:IsFieldSpell() and c:IsCode(54306223) and not c:IsForbidden()
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.plfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if not sc then return end
	local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	if fc then
		Duel.SendtoGrave(fc,REASON_RULE)
		Duel.BreakEffect()
	end
	Duel.MoveToField(sc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
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
		if tc:IsCanAddCounter(COUNTER_VENOM,1) and not tc:IsSetCard(SET_VENOM) then
			local atk=tc:GetAttack()
			tc:AddCounter(COUNTER_VENOM,1)
			if atk>0 and tc:GetAttack()==0 then
				g:AddCard(tc)
			end
		end
	end
	if #g>0 then
		Duel.RaiseEvent(g,EVENT_CUSTOM+54306223,e,0,0,0,0)
	end
    Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+54306223+1,e,0,0,0,1)
end