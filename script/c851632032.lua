--Vylon Orthopex
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    aux.AddUnionProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT))

    --search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_CONJURE)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(30765615)
	c:RegisterEffect(e3)

    aux.GlobalCheck(s,function()
		s.name_list={}

        local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
		ge1:SetCode(EVENT_EQUIP)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.add_if_not_contains(tableval --[[table]], val)
    for i=1,#tableval do
       if tableval[i] == val then 
          return true
       end
    end
    table.insert(tableval,val)
    return false
 end

 function s.filter2(c)
	return Card.GetEquipTarget(c):IsCode(id)
end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(s.filter2, nil)

	if #g>0 then
        for i in g:Iter() do
            s.add_if_not_contains(s.name_list, i:GetOriginalCode())
        end
	end
end

function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return #s.name_list>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,0)
    Duel.SetOperationInfo(0,CATEGORY_CONJURE,nil,1,tp,0)

end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	for index, value in ipairs(s.name_list) do
        local token=Duel.CreateToken(tp, value)
        Duel.SendtoHand(token, tp, REASON_EFFECT,false)
    end
    Duel.ShuffleHand(tp)
end