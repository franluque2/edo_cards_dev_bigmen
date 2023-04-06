--Machine King Evolution
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
local LOCATION_HDG=LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE
local LOCATION_RMV_GRV=LOCATION_REMOVED+LOCATION_GRAVE
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)
	end
	e:SetLabel(1)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	s.summon_king(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id,0,0,0)
end
function s.summon_king(e,tp,eg,ep,ev,re,r,rp)
	local king=Duel.CreateToken(tp,89222931)
	Duel.SpecialSummon(king,0,tp,tp,false,false,POS_FACEUP)
end
function s.king_proto_filter(c)
	return c:IsCode(89222931) and c:IsReleasable()
end

function s.king_proto_filter_gy_banish(c)
	return c:IsCode(89222931)
end
function s.king_filter(c)
	return c:IsOriginalCode(46700124)
end
function s.king_filter_summon(c,e,tp)
	return c:IsCode(46700124) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.perfect_king_filter_anime(c)
	return c:IsOriginalCode(511001057)
end
function s.perfect_king_filter_anime_summon(c)
	return c:IsOriginalCode(511001057)
end
function s.perfect_king_filter_tcg(c)
	return c:IsOriginalCode(18891691)
end
function s.robotic_knight(c)
	return c:IsCode(44203504)
end
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	if Duel.GetFlagEffect(ep,id+1)>0 and Duel.GetFlagEffect(ep,id+2)>0 and Duel.GetFlagEffect(ep,id+3)>0 then return end
	--Boolean checks for the activation condition: b1, b2, b3
	local b1=Duel.GetFlagEffect(ep,id+1)==0
			and Duel.IsExistingMatchingCard(s.king_proto_filter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.king_filter_summon,tp,LOCATION_HDG,0,1,nil,e,tp)

	local fusionparams = {aux.FilterBoolFunction(Card.IsCode,511001057),Fusion.OnFieldMat(Card.IsAbleToRemove),s.fextra,Fusion.BanishMaterial}
	local b2=Duel.GetFlagEffect(ep,id+2)==0
			and Duel.IsExistingMatchingCard(s.king_filter,tp,LOCATION_MZONE,0,1,nil,tp)
			and Duel.IsExistingMatchingCard(s.robotic_knight,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
			and Fusion.SummonEffTG(table.unpack(fusionparams))

	local b3=Duel.GetFlagEffect(ep,id+3)==0
			and Duel.GetLocationCount(tp,LOCATION_MZONE)
			and Duel.IsExistingMatchingCard(s.king_proto_filter_gy_banish,tp,LOCATION_RMV_GRV,0,1,nil)
			and Duel.IsExistingMatchingCard(s.king_filter,tp,LOCATION_RMV_GRV,0,1,nil)
			and Duel.IsExistingMatchingCard(s.perfect_king_filter_anime,tp,LOCATION_RMV_GRV,0,1,nil)

	return aux.CanActivateSkill(tp) and (b1 or b2 or b3)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:
	local b1=Duel.GetFlagEffect(ep,id+1)==0
			and Duel.IsExistingMatchingCard(s.king_proto_filter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.king_filter_summon,tp,LOCATION_HDG,0,1,nil,e,tp)

	--Boolean check for effect2:
	local fusionparams = {aux.FilterBoolFunction(Card.IsCode,511001057),Fusion.OnFieldMat(Card.IsAbleToRemove),s.fextra,Fusion.BanishMaterial}
	local b2=Duel.GetFlagEffect(ep,id+2)==0
			and Duel.IsExistingMatchingCard(s.king_filter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.robotic_knight,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
			and Fusion.SummonEffTG(table.unpack(fusionparams))

	--Boolean check for effect3:
	local b3=Duel.GetFlagEffect(ep,id+3)==0
			and Duel.GetLocationCount(tp,LOCATION_MZONE)
			and Duel.IsExistingMatchingCard(s.king_proto_filter_gy_banish,tp,LOCATION_RMV_GRV,0,1,nil)
			and Duel.IsExistingMatchingCard(s.king_filter,tp,LOCATION_RMV_GRV,0,1,nil)
			and Duel.IsExistingMatchingCard(s.perfect_king_filter_anime,tp,LOCATION_RMV_GRV,0,1,nil)

	--This auxiliary function should simplify what you did with all the Duel.SelectOption you used previously:
	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
								  {b2,aux.Stringid(id,1)},
								  {b3,aux.Stringid(id,2)})
	op=op-1 --SelectEffect returns indexes starting at 1, so we decrease the result by 1 to match your "if"s

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then
		s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
	end
end

--op=0, Tribute 1 machine king prototype, summon a machine king from Hand/Deck/GY
function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TRIBUTE)
	local tc=Duel.SelectMatchingCard(tp,s.king_proto_filter,tp,LOCATION_MZONE,0,1,1,nil)
	if tc and Duel.Release(tc,REASON_COST)>0 and Duel.GetMZoneCount(tp)>0 then --i'm not sure if the reason should be cost
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.king_filter_summon,tp,LOCATION_HDG,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.BreakEffect()
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end
function s.spfilter2(c,e,tp,rmg)
	return c:IsCode(18891691) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,true,false)
	and Duel.GetLocationCountFromEx(tp,tp,rmg,SUMMON_TYPE_FUSION)>0
end
function s.matlfilter(c)
	return c:IsCode(46700124,44203504) and c:IsAbleToRemove()
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsCode,1,nil,46700124) and sg:IsExists(Card.IsCode,1,nil,44203504)
end
--op=1, Tribute 1 Machine King, fusion summon anime perfect machine king: NOT FINISHED
function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TRIBUTE)
	local tc=Duel.SelectMatchingCard(tp,s.king_filter,tp,LOCATION_MZONE,0,1,1,nil)
	if tc and Duel.Release(tc,REASON_COST)>0 then
		local rmg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local ssc=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,rmg):GetFirst()
		local matg=aux.SelectUnselectGroup(rmg,e,tp,2,2,s.rescon,1,tp,HINTMSG_FMATERIAL)
		Duel.Remove(matg,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL)
		Duel.SpecialSummon(ssc,SUMMON_TYPE_FUSION,tp,tp,true,false,POS_FACEUP)
		ssc:CompleteProcedure()
		ssc:SetMaterial(matg)
	end
	Duel.RegisterFlagEffect(tp,id+2,0,0,0)
end
--Extra material (aka, allow banishing things also from the GY)
function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,69832741) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
	end
	return nil
end
--op=2, Summon tcg perfect machine from outside the duel, then turn the field into machines for 1 turn
function s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
	local perfectking=Duel.CreateToken(tp,18891691)
	Duel.SpecialSummon(perfectking,0,tp,tp,false,false,POS_FACEUP)
	--Change things on the field to Machine until the end phase
	Duel.BreakEffect()
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetValue(RACE_MACHINE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
	Duel.RegisterFlagEffect(tp,id+3,0,0,0)
end
