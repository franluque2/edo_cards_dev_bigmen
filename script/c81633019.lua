--Identity Crisis
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
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

        local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_SUMMON_SUCCESS)
		e2:SetCondition(s.repcon)
		e2:SetOperation(s.repop)
		Duel.RegisterEffect(e2,tp)

        local e3=e2:Clone()
        e3:SetCode(EVENT_SPSUMMON_SUCCESS)
        Duel.RegisterEffect(e3,tp)


        local e4=e2:Clone()
        e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
        Duel.RegisterEffect(e4, tp)


	end
	e:SetLabel(1)
end

local levelcards={}
levelcards[1]={18590133}
levelcards[2]={68963107}
levelcards[3]={10802915}
levelcards[4]={08806072}
levelcards[5]={59975920}
levelcards[6]={56099748}
levelcards[7]={32909498}
levelcards[8]={60461804}
levelcards[9]={28226490}
levelcards[10]={32240937}
levelcards[11]={27204311}
levelcards[12]={48546368}


function s.validreplacefilter(c, e)
    return c:HasLevel() and c:GetFlagEffect(id)==0 and c:GetOwner()==e:GetHandlerPlayer()
end

function s.repcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.validreplacefilter, 1, nil, e)
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    Duel.Hint(HINT_CARD,tp,id)

    local tc=eg:GetFirst()
    while tc do
        if s.validreplacefilter(tc, e) then
            local level=tc:GetLevel()
            if level<1 then
                level=1
            end

            if level>12 then
                level=12
            end
            --Debug.Message(levelcards[level][Duel.GetRandomNumber(1,#levelcards[level])])
			tc:Recreate(levelcards[level][Duel.GetRandomNumber(1,#levelcards[level])],nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
            tc:RegisterFlagEffect(id, RESETS_STANDARD, 0, 0)
        end
        
        tc=eg:GetNext()
    end

end






function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	--start of duel effects go here

	--s.startofdueleff(e,tp,eg,ep,ev,re,r,rp)

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.startofdueleff(e,tp,eg,ep,ev,re,r,rp)
    --stuff we gotta do

    for _, levelcardsin in ipairs(levelcards) do
        for _,innermostloader in ipairs(levelcardsin) do
            Duel.LoadCardScript(innermostloader)
        end
        
    end

end