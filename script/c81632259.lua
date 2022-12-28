--Magnet Fusion (CT)
local s,id=GetID()
function s.initial_effect(c)
    local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsCode,100000570),Card.IsAbleToRemove,s.fextra,Fusion.BanishMaterial,nil,s.stage2,nil,nil,nil,nil,nil,nil,nil,s.extratg)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end

function s.stage2(e,tc,tp,sg,chk)
	if chk==3 then
		local mats=sg
		if mats:IsExists(Card.IsCode,1,nil,450000350) and mats:IsExists(Card.IsCode,1,nil,450000351) and mats:IsExists(Card.IsCode,1,nil,450000352) then
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
            e3:SetDescription(3001)
			e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
            e3:SetRange(LOCATION_MZONE)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e3:SetValue(1)
			tc:RegisterEffect(e3)
		end
	end
end

function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,69832741) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
	end
	return nil
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
end