--Reinforcements of the Resistance
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
xyzmats[100000498]={81632613, 81632613} --Dog Chan
xyzmats[73887236]={52159691, 53251824, 05929801} --Kurosaki
xyzmats[19369609]={34550857, 60954556, 97949165} --Ruri
xyzmats[64554883]={511002683, 05244497} --Cameron
xyzmats[01992816]={38173725, 01586457} --Quinton
xyzmats[88120966]={34620088, 101205009} --Quattro
xyzmats[39139935]={87430304, 05291803} --Trey
xyzmats[60645181]={65848811, 01833916} --Nistro
xyzmats[56910167]={51126152, 51126152} --Anna Kaboom
xyzmats[29515122]={511002686, 511002687, 42851643} --Cody
xyzmats[20343502]={77848740, 11868731} --Scarlet
xyzmats[16195942]={77462146, 77462146} --Yuto
-- example on how to fill: xyzmats[12014404]={26082117, 62476815} for Gagaga Cowboy:  Gagaga Magician & Gogogo Golem as materials

local fusmats={}
-- same as xyzmats

local mons={100000498, 73887236,19369609,64554883,01992816,88120966,39139935,51960178,60645181,56910167,29515122,20343502,16195942}
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
    
    else

        Duel.SpecialSummon(tar, SUMMON_TYPE_SPECIAL, tp, tp, true, true, POS_FACEUP)
        Card.CompleteProcedure(tar)
    end

    --add additional handling for stuff like parasite queen here later

	

	Duel.RegisterFlagEffect(tp, id, RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END, 0, 0)

end
