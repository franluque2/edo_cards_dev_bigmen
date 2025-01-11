--Conscription into the Spirit World
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
end





function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

        local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetCode(EFFECT_ADD_CODE)
        e2:SetTargetRange(LOCATION_MZONE,0)
        e2:SetTarget(function(_,c) return c:IsOriginalCode(TOKEN_ADVENTURER) end)
        e2:SetValue(CARD_ANCIENT_FAIRY_DRAGON)
        Duel.RegisterEffect(e2, tp)

        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
        e3:SetTargetRange(0,LOCATION_MZONE)
        e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        e3:SetValue(s.evalue)
        Duel.RegisterEffect(e3, tp)

        
        local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_SPSUMMON_SUCCESS)
		e4:SetCondition(s.repcon)
		e4:SetOperation(s.repop)
		Duel.RegisterEffect(e4,tp)

        local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_FIELD)
        e5:SetCode(EFFECT_CHANGE_CODE)
        e5:SetTargetRange(LOCATION_ALL,0)
        e5:SetTarget(function(_,c) return c:IsOriginalCode(64047146) end)
        e5:SetValue(92341815)
        Duel.RegisterEffect(e5, tp)
	end
	e:SetLabel(1)
end

function s.validreplacefilter(c,e)
    return c:IsType(TYPE_TOKEN) and (c:IsOriginalCode(TOKEN_ADVENTURER)) and c:GetOwner()==e:GetHandlerPlayer()
end

function s.repcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.validreplacefilter, 1, nil, e)
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
    local tc=eg:GetFirst()
    while tc do
        if s.validreplacefilter(tc, e) then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetCode(30765615)
            e1:SetReset(RESETS_STANDARD)
            tc:RegisterEffect(e1)
    
        end
        
        tc=eg:GetNext()
    end

end

function s.evalue(e,re,rp)
	return re:IsActiveType(TYPE_TRAP) and re:GetHandler():IsOriginalCode(101208071)
end

function s.isormentionsafdfilter(c)
    return c:IsCode(CARD_ANCIENT_FAIRY_DRAGON) or c:ListsCode(CARD_ANCIENT_FAIRY_DRAGON)
end

function s.isormentionsadventurerfilter(c)
    return c:IsCode(TOKEN_ADVENTURER) or c:ListsCode(TOKEN_ADVENTURER)
end


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

    local g=Duel.GetMatchingGroup(s.isormentionsafdfilter, tp, LOCATION_ALL, 0, nil)
    local g2=Duel.GetMatchingGroup(s.isormentionsadventurerfilter, tp, LOCATION_ALL, 0, nil)

    for tc in g:Iter() do
        local metatable=tc:GetMetatable()
        if metatable.listed_names and #metatable.listed_names>0 then
            table.insert(metatable.listed_names,TOKEN_ADVENTURER)
        else
            metatable.listed_names={TOKEN_ADVENTURER,CARD_ANCIENT_FAIRY_DRAGON}
        end
    end

    for tc in g2:Iter() do
        local metatable=tc:GetMetatable()
        if metatable.listed_names and #metatable.listed_names>0 then
            table.insert(metatable.listed_names,CARD_ANCIENT_FAIRY_DRAGON)
        else
            metatable.listed_names={TOKEN_ADVENTURER,CARD_ANCIENT_FAIRY_DRAGON}
        end
    end

    local g3=Duel.GetMatchingGroup(Card.IsOriginalCode, tp, LOCATION_ALL, 0, nil,64047146)
    for tc in g3:Iter() do
        local metatable=tc:GetMetatable()
        if metatable.listed_names and #metatable.listed_names>0 then
            table.insert(metatable.listed_names,TOKEN_ADVENTURER)
        else
            metatable.listed_names={TOKEN_ADVENTURER}
        end
    end

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

