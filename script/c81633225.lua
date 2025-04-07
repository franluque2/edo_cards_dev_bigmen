--War to Weighted Packs
local s,id=GetID()
Duel.LoadScript("big_aux.lua")


function s.initial_effect(c)
	--Activate Skill
	aux.AddSkillProcedure(c,1,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)

	aux.AddSkillProcedure(c,1,false,s.flipcon2,s.flipop2)
end


function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		e1:SetCountLimit(1)
		Duel.RegisterEffect(e1,tp)

        bRush.addrules()(e,tp,eg,ep,ev,re,r,rp)


end
e:SetLabel(1)
end

	function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
		return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
	end

	function s.flipop(e,tp,eg,ep,ev,re,r,rp)
		Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
		Duel.Hint(HINT_CARD,tp,id)
		
		s.morpharchetypes(e,tp,eg,ep,ev,re,r,rp)

	end


function s.morpharchetypes(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp, Card.IsMonster, tp, LOCATION_DECK+LOCATION_HAND+LOCATION_EXTRA, 0, 1, 1,false,nil)
    if not g or #g==0 then return end
	Duel.ConfirmCards(1-tp, g)

    local archetypes=nil

    local base=g:GetFirst()
    archetypes={base:Setcode()}


    for key,value in ipairs(archetypes) do

        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetCode(EFFECT_ADD_SETCODE)
        e3:SetTargetRange(LOCATION_ALL-LOCATION_OVERLAY,0)
        e3:SetValue(value)
        Duel.RegisterEffect(e3,tp)

    end

    if base:IsMonster() then

        local op=Duel.SelectEffect(tp, {true,aux.Stringid(id,0)},
                                    {true,aux.Stringid(id,1)},
                                    {true,aux.Stringid(id,2)})

        if op==1 then

            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetCode(EFFECT_ADD_RACE)
            e1:SetTargetRange(LOCATION_ALL-LOCATION_OVERLAY,0)
            e1:SetValue(base:Race())
            Duel.RegisterEffect(e1,tp)

        elseif op==2 then

            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetCode(EFFECT_ADD_ATTRIBUTE)
            e1:SetTargetRange(LOCATION_ALL-LOCATION_OVERLAY,0)
            e1:SetValue(base:Attribute())
            Duel.RegisterEffect(e1,tp)

        elseif op==3 then

            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetCode(EFFECT_ADD_RACE)
            e1:SetTargetRange(LOCATION_ALL-LOCATION_OVERLAY,0)
            e1:SetValue(base:Race())
            Duel.RegisterEffect(e1,tp)

            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_FIELD)
            e2:SetCode(EFFECT_ADD_ATTRIBUTE)
            e2:SetTargetRange(LOCATION_ALL-LOCATION_OVERLAY,0)
            e2:SetValue(base:Attribute())
            Duel.RegisterEffect(e2,tp)

        end
    end

end


function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id+3)>0 then return end
	local b1=Duel.GetFlagEffect(tp,id+3)==0
                        and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_ONFIELD,0,1,nil)

	return aux.CanActivateSkill(tp) and (b1 or b2)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)


	local b1=Duel.GetFlagEffect(tp,id+3)==0
                        and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_ONFIELD,0,1,nil)

	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,3)})
	op=op-1

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	end
end

function s.rescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetLocation)==3
end

function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)

	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD|LOCATION_HAND|LOCATION_GRAVE,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,3,s.rescon,1,tp,HINTMSG_CONFIRM)

    if #sg>0 then
        local val=Duel.AnnounceCard(tp)
        Duel.HintSelection(sg)
        for tc in sg:Iter() do
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CHANGE_CODE)
            e1:SetValue(val)
            e1:SetReset(RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e1)
        end
    end
    Duel.RegisterFlagEffect(tp,id+3,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end
