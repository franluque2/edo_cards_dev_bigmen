--Deep Warning Fusion (CT)
Duel.LoadScript("big_aux.lua")

local s,id=GetID()
function s.initial_effect(c)

    local e1=Fusion.CreateSummonEff({handler=c,desc=aux.Stringid(id, 1),matfilter=Fusion.InHandMat, fusfilter=aux.FilterBoolFunction(Card.IsRace,RACE_CYBERSE),nil,nil,nil,nil, stage2=s.stage2})
	c:RegisterEffect(e1)

    local e2=Fusion.CreateSummonEff({handler=c,desc=aux.Stringid(id, 2),matfilter=Fusion.OnFieldMat(Card.IsFaceup), fusfilter=aux.FilterBoolFunction(Card.IsRace,RACE_CYBERSE),nil,nil,nil,nil, stage2=s.stage2})
	c:RegisterEffect(e2)
    
end
s.listed_names={SPACE_YGGDRAGO}


function s.desfilter(c)
	local code=c:GetCode()
	return (code==SPACE_YGGDRAGO and c:IsLocation(LOCATION_GRAVE))
end

function s.stage2(e,tc,tp,mg,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
		local mc=mg:FilterCount(s.desfilter,nil)
		if #g>0 and mc>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local sg=g:Select(tp,1,1,nil)
			if #sg>0 then
				Duel.BreakEffect()
				Duel.Destroy(sg,REASON_EFFECT)
			end
		end
	end
end
