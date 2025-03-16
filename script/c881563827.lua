--Enchanted Minecraft Pumpkin: Curse of Binding
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)	
    
    aux.AddPersistentProcedure(c,nil,aux.FaceupFilter(aux.TRUE),CATEGORY_DISABLE,nil,nil,0x1c0,s.tgcon,nil,s.target)

	--disable
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(aux.PersistentTargetFilter)
	c:RegisterEffect(e3)

    local e2=e3:Clone()
	e2:SetCode(EFFECT_SET_ATTACK)
	e2:SetValue(0)
	c:RegisterEffect(e2)
	local e1=e3:Clone()
	e1:SetCode(EFFECT_SET_DEFENSE)
	e1:SetValue(0)
	c:RegisterEffect(e1)


end

s.listed_series={SET_MINECRAFT}


function s.tgcon(e)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_MINECRAFT), e:GetHandlerPlayer(), LOCATION_MZONE, 0, 1, nil) and Duel.GetFlagEffect(e:GetHandlerPlayer(), id)==0
end

function s.target(e,tp,eg,ep,ev,re,r,rp,tc,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,tc,1,0,0)
    Duel.RegisterFlagEffect(tp, id, RESET_PHASE+PHASE_END, 0, 0)
end

function s.filter(c)
	return c:IsFaceup()
end