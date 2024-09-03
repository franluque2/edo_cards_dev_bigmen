--Call of the Haunting (CT)
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
    e1:SetCountLimit(1,{id,0})
	c:RegisterEffect(e1)
	--draw
	local e3a=Effect.CreateEffect(c)
	e3a:SetDescription(aux.Stringid(id,1))
	e3a:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3a:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3a:SetCode(EVENT_CUSTOM+id)
	e3a:SetRange(LOCATION_FZONE)
	e3a:SetCountLimit(1,id)
	e3a:SetTarget(s.sptg)
	e3a:SetOperation(s.spop)
	c:RegisterEffect(e3a)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e3a:SetLabelObject(g)
	--Register the destuction of monsters
	local e3b=Effect.CreateEffect(c)
	e3b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3b:SetCode(EVENT_DESTROYED)
	e3b:SetRange(LOCATION_FZONE)
	e3b:SetLabelObject(e3a)
	e3b:SetOperation(s.regop)
	c:RegisterEffect(e3b)
	
 end
 function s.fil(c,e,tp)
	return c:IsCode(81632718, 81632719, 81632720, 81632721) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
 end
 function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsExistingMatchingCard(s.fil,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	local g=Duel.GetMatchingGroup(s.fil,tp,LOCATION_GRAVE,0,nil,e,tp)
	if #g==0 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,ft,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_ATTACK)
end
function s.tgfilter(c,tp,e)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and c:IsFaceup() and c:IsPreviousControler(tp)
		and c:IsReason(REASON_BATTLE|REASON_EFFECT) and c:IsCanBeEffectTarget(e)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsCode(81632719, 81632720, 81632721)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetLabelObject():Filter(s.tgfilter,nil,tp,e)
	if chkc then return g:IsContains(chkc) and s.tgfilter(chkc,tp,e) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	local tc=nil
	if #g==1 then
		tc=g:GetFirst()
		Duel.SetTargetCard(tc)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		tc=g:Select(tp,1,1,nil)
		Duel.SetTargetCard(tc)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		e1:SetValue(tc:GetBaseAttack()/2)
		tc:RegisterEffect(e1)
	end
end