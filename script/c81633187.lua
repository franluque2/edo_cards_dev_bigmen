--Crew in the Schoolyard!
local s,id=GetID()
function s.initial_effect(c)
	--Activate Skill
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)

	aux.AddSkillProcedure(c,1,false,s.flipcon2,s.flipop2)


end
local xyzmats={}
xyzmats[66506689]={42969214,18063928}
xyzmats[16691074]={16178681,85497611}
local fusmats={}
fusmats[25366484]={35809262, 20721928}
fusmats[160428025]={160001028,160428042}
fusmats[96897184]={10163855,89943723}
fusmats[15989522]={61525276,34130561}
local mons={25366484, 52240819, 27520594,87460579,96897184,160428025,15989522,66506689,97489701,16691074}
local monstosummon={}
monstosummon[0]=Group.CreateGroup()
monstosummon[1]=Group.CreateGroup()


function s.filltables()
    if #monstosummon[0]==0 then
        for i, v in pairs(mons) do
            local token1=Duel.CreateToken(0, v)
            monstosummon[0]:AddCard(token1)
            local token2=Duel.CreateToken(1, v)
            monstosummon[1]:AddCard(token2)


        end

    end
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)


        s.filltables()



	end
	e:SetLabel(1)
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,0),nil)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	Duel.SendtoDeck(e:GetHandler(), tp, -2, REASON_EFFECT)
	if e:GetHandler():GetPreviousLocation()==LOCATION_HAND then
		Duel.Draw(tp, 1, REASON_EFFECT)
	end

end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)

	--OPD check
	if Duel.GetFlagEffect(tp,id)>1  then return end

	local b1=Duel.CheckLPCost(tp, 2000)

	return aux.CanActivateSkill(tp) and b1
end

function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
    Duel.PayLPCost(tp, 2000)

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local tar=monstosummon[tp]:Select(tp,1,1,nil):GetFirst()
    monstosummon[tp]:RemoveCard(tar)

    if tar:IsType(TYPE_FUSION) then
        Duel.SpecialSummon(tar, SUMMON_TYPE_FUSION, tp, tp, true, true, POS_FACEUP)
        Card.CompleteProcedure(tar)

        if fusmats[tar:GetOriginalCode()]~=nil then
            for i, val in ipairs(fusmats[tar:GetOriginalCode()]) do
                local mat=Duel.CreateToken(tp, val)
                Duel.SendtoGrave(mat, REASON_RULE)
            end
            local poly=Duel.CreateToken(tp, CARD_POLYMERIZATION)
            Duel.SendtoGrave(poly, REASON_RULE)
        end
    elseif tar:IsType(TYPE_XYZ) then
        Duel.SpecialSummon(tar, SUMMON_TYPE_XYZ, tp, tp, true, true, POS_FACEUP)
        Card.CompleteProcedure(tar)
        if xyzmats[tar:GetOriginalCode()]~=nil then
            for i, val in ipairs(xyzmats[tar:GetOriginalCode()]) do
                local mat=Duel.CreateToken(tp, val)
                Duel.SendtoGrave(mat, REASON_RULE)
                Duel.Overlay(tar, mat)
            end
        end
    elseif tar:IsType(TYPE_SYNCHRO) then
        Duel.SpecialSummon(tar, SUMMON_TYPE_SYNCHRO, tp, tp, true, true, POS_FACEUP)
        Card.CompleteProcedure(tar)
    elseif tar:IsType(TYPE_LINK) then
        Duel.SpecialSummon(tar, SUMMON_TYPE_LINK, tp, tp, true, true, POS_FACEUP)
        Card.CompleteProcedure(tar)
    elseif tar:IsType(TYPE_RITUAL) then
        Duel.SpecialSummon(tar, SUMMON_TYPE_RITUAL, tp, tp, true, true, POS_FACEUP)
        Card.CompleteProcedure(tar)
    else
        Duel.SpecialSummon(tar, SUMMON_TYPE_SPECIAL, tp, tp, true, true, POS_FACEUP)
        Card.CompleteProcedure(tar)
    end
    --add additional handling for stuff like parasite queen here later

	

	Duel.RegisterFlagEffect(tp, id, RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END, 0, 0)

end