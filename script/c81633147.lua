--Obelisk Force Commander
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
xyzmats[17016362]={67696066, 511001580} --Dennis
-- example on how to fill: xyzmats[12014404]={26082117, 62476815} for Gagaga Cowboy:  Gagaga Magician & Gogogo Golem as materials

local fusmats={}
fusmats[12652643]={CARD_ANCIENT_GEAR_GOLEM, CARD_ANCIENT_GEAR_GOLEM, CARD_ANCIENT_GEAR_GOLEM, CARD_POLYMERIZATION} -- Crowler
fusmats[90579153]={37780349, 64184058, CARD_POLYMERIZATION} -- Edo
fusmats[41209827]={35272499, 61677004, CARD_POLYMERIZATION} -- Yuri
fusmats[88753594]={11439455, 48427163, 84812868, CARD_POLYMERIZATION} -- Serena
fusmats[74157028]={CARD_CYBER_DRAGON, CARD_CYBER_DRAGON, CARD_POLYMERIZATION} -- Zane
fusmats[81632322]={05265750, 15653824, CARD_POLYMERIZATION} -- Captain Solo
fusmats[36256625]={44729197, 71218746, 99861526, CARD_POLYMERIZATION} -- Syrus
fusmats[81632418]={511009366, 511009363, CARD_POLYMERIZATION} -- Leo Akaba
fusmats[91998119]={62651957, 65622692, 64500000} -- Chazz






-- same as xyzmats

local mons={17016362, 29357956, 12652643, 90579153, 41209827, 88753594, 74157028, 81632322, 36256625, 81632418, 91998119}
--fill in the monsters for this side here

local monstosummon={}
monstosummon[0]=Group.CreateGroup()
monstosummon[1]=Group.CreateGroup()



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


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,0),nil)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	Duel.SendtoDeck(e:GetHandler(), tp, -2, REASON_EFFECT)
	if e:GetHandler():GetPreviousLocation()==LOCATION_HAND then
		Duel.Draw(tp, 1, REASON_EFFECT)
	end
end


function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)

	--OPD check
	if Duel.GetFlagEffect(tp,id)>0  then return end

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
            local savedfusmats=Group.CreateGroup()
            for i, val in ipairs(fusmats[tar:GetOriginalCode()]) do
                local mat=Duel.CreateToken(tp, val)
                if mat:IsType(TYPE_MONSTER) then
                    Duel.SendtoGrave(mat, REASON_MATERIAL|REASON_FUSION)
                else
                    Duel.SendtoGrave(mat, REASON_RULE)
                end
                mat:SetReasonCard(tar)
                if mat:IsType(TYPE_MONSTER) then
                    Group.AddCard(savedfusmats, mat)
                end
            end
            if #savedfusmats~=0 then
                tar:SetMaterial(savedfusmats)
            end
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
    
    else

        Duel.SpecialSummon(tar, SUMMON_TYPE_SPECIAL, tp, tp, true, true, POS_FACEUP)
        Card.CompleteProcedure(tar)
    end

    --add additional handling for stuff like parasite queen here later

	

	Duel.RegisterFlagEffect(tp, id, RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END, 0, 0)

end
