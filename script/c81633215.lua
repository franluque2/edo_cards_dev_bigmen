--Shackles for the Wandering Branded Dragon
Duel.LoadScript("big_aux.lua")
Duel.LoadScript("c420.lua")
Duel.EnableUnofficialProc(PROC_CANNOT_BATTLE_INDES)


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
        e1:SetCountLimit(1)
		Duel.RegisterEffect(e1,tp)

		--other passive duel effects go here    

        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
        e2:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
        e2:SetTargetRange(0,LOCATION_MZONE)
        e2:SetTarget(function(ef,c) return not (c:GetFlagEffect(id)>0 and c:GetFlagEffectLabel(id)==ef:GetHandlerPlayer()) end)
        e2:SetValue(s.sumlimit)
        Duel.RegisterEffect(e2,tp)

        local e9=Effect.CreateEffect(e:GetHandler())
        e9:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
        e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e9:SetCode(EVENT_SPSUMMON_SUCCESS)
        e9:SetOperation(s.spsumcheck)
        Duel.RegisterEffect(e9,tp)

	end
	e:SetLabel(1)
end

function s.spsumcheck(e,tp,eg,ev,ep,re,r,rp)
	if not re then return end
	if rp==tp then
		local ec=eg:GetFirst()
		while ec do
			ec:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0,tp)
			ec=eg:GetNext()
		end
	end
end


function s.sumlimit(e,c)
	if not c then return false end
	return c:IsControler(e:GetHandlerPlayer())
end



function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

    local g=Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_ALL, nil)

    if #g>0 then
		local tc=g:GetFirst()
		while tc do

			local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetCode(EFFECT_CANNOT_BATTLE_INDES)
            e1:SetRange(LOCATION_MZONE)
            e1:SetTargetRange(LOCATION_MZONE,0)
            e1:SetValue(1)
            tc:RegisterEffect(e1)

            tc=g:GetNext()
        end
    end

    local sprinds=Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_ALL,0, nil, 01906812)
	for tc in sprinds:Iter() do
		if tc:GetFlagEffect(id+1)==0 then
			tc:RegisterFlagEffect(id+1,0,0,0)
			local eff={tc:GetCardEffect()}
			for _,teh in ipairs(eff) do
				if (Effect.GetType(teh)&EFFECT_TYPE_IGNITION)==EFFECT_TYPE_IGNITION then
					teh:Reset()
				end
			end

            local e1=Effect.CreateEffect(tc)
            e1:SetDescription(aux.Stringid(tc:GetOriginalCode(),0))
            e1:SetType(EFFECT_TYPE_IGNITION)
            e1:SetRange(LOCATION_MZONE)
            e1:SetCountLimit(1)
            e1:SetCondition(aux.seqmovcon)
            e1:SetTarget(s.seqtg)
            e1:SetOperation(s.seqop)
            tc:RegisterEffect(e1)
			

			tc:RegisterFlagEffect(id+1,0,0,0)
	end
end
local albasystem=Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_EXTRA, 0, nil, 100436300)
    if #albasystem>0 then
	for tc in albasystem:Iter() do
        if tc:GetFlagEffect(id+1)==0 then
        local eff={tc:GetCardEffect()}
        for _,teh in ipairs(eff) do
            if teh:GetCode()&EFFECT_FUSION_MATERIAL==EFFECT_FUSION_MATERIAL then
                teh:Reset()
            end
        end
        tc:RegisterFlagEffect(id+1,0,0,0)

      end
      Fusion.AddProcMixN(tc,true,true,CARD_ALBAZ,1,55273560,1,aux.FilterBoolFunctionEx(Card.ListsCode,CARD_ALBAZ),4)
		end
    end

end

	--Activation legality
    function s.seqtg(e,tp,eg,ep,ev,re,r,rp,chk)
        if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
    end
        --Move itself to 1 of your unused MMZ, then destroy all face-up cards in its new column
    function s.seqop(e,tp,eg,ep,ev,re,r,rp,chk)
        local c=e:GetHandler()
        local seq=c:GetSequence()
        if seq>4 then return end
        local flag=0
        if seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1) then flag=flag|(0x1<<seq-1) end
        if seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1) then flag=flag|(0x1<<seq+1) end
        if flag==0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
        Duel.MoveSequence(c,math.log(Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,~flag),2))
        local dg=c:GetColumnGroup():Filter(Card.IsFaceup,c,nil) --Check for face-up cards in its current column, except itself
        if #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(e:GetHandler():GetOriginalCode(),1)) then
            Duel.BreakEffect()
            Duel.Destroy(dg,REASON_EFFECT)
        end
    end
