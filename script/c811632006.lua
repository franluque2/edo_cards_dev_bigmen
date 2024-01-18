--Project 038
local s,id=GetID()


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
end


function s.op(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))

	if e:GetLabel()==0 and Duel.GetFlagEffect(0, id)==0 then
        Duel.Hint(HINT_CARD,tp,id)

        s.copydecks(e,tp,eg,ep,ev,re,r,rp)
		s.copyextra(e,tp,eg,ep,ev,re,r,rp)

        Duel.ShuffleDeck(tp)
        Duel.ShuffleDeck(1-tp)


    Duel.RegisterFlagEffect(0, id, 0,0,0)
    end
e:SetLabel(1)
end

function s.notskill(c)
    return not c:IsType(TYPE_SKILL)
end

function s.copydecks(e,tp,eg,ep,ev,re,r,rp)
		local oppcards=Duel.GetMatchingGroup(s.notskill, tp, 0, LOCATION_DECK, nil)
        local mycards=Duel.GetMatchingGroup(s.notskill, tp, LOCATION_DECK, 0, nil)

        Duel.DisableShuffleCheck(true)

		if #oppcards>0 then
			local tc=oppcards:GetFirst()
			local newcard=nil
			while tc do
				newcard=Duel.CreateToken(tp, tc:GetOriginalCode())
				Duel.SendtoDeck(newcard, tp, SEQ_DECKTOP, REASON_EFFECT)

				tc=oppcards:GetNext()
			end

		end

        if #mycards>0 then
			local tc=mycards:GetFirst()
			local newcard=nil
			while tc do

				newcard=Duel.CreateToken(1-tp, tc:GetOriginalCode())
				Duel.SendtoDeck(newcard, 1-tp, SEQ_DECKTOP, REASON_EFFECT)

				tc=mycards:GetNext()
			end

		end

		Duel.DisableShuffleCheck(false)


end

function s.copyextra(e,tp,eg,ep,ev,re,r,rp)
    local oppcards=Duel.GetMatchingGroup(s.notskill, tp, 0, LOCATION_EXTRA, nil)
    local mycards=Duel.GetMatchingGroup(s.notskill, tp, LOCATION_EXTRA, 0, nil)


    if #oppcards>0 then
        local tc=oppcards:GetFirst()
        local newcard=nil
        while tc do

            newcard=Duel.CreateToken(tp, tc:GetOriginalCode())
            Duel.SendtoDeck(newcard, tp, SEQ_DECKTOP, REASON_EFFECT)

            tc=oppcards:GetNext()
        end

    end

    if #mycards>0 then
        local tc=mycards:GetFirst()
        local newcard=nil
        while tc do

            newcard=Duel.CreateToken(1-tp, tc:GetOriginalCode())
            Duel.SendtoDeck(newcard, 1-tp, SEQ_DECKTOP, REASON_EFFECT)

            tc=mycards:GetNext()
        end

    end



end