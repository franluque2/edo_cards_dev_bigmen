--Vanguard of the Shadows
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
	aux.AddSkillProcedure(c,2,false,s.flipcon2,s.flipop2)
end

local CARD_PANDEMONIUM=94585852
local ARCHFIEND_MATADOR=511000009
local VILEPAWN_ARCHFIEND=73219648
local MASTERKING_ARCHFIEND=35606858

function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

		--other passive duel effects go here

		--uncomment (remove the --) the line below to make it a rush skill
		--bRush.addrules()(e,tp,eg,ep,ev,re,r,rp)

        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetCode(EFFECT_PATRICIAN_OF_DARKNESS)
        e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e3:SetTargetRange(0,1)
        e3:SetCondition(s.battlecon)
		--Duel.RegisterEffect(e3,tp)

        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
        e2:SetTargetRange(LOCATION_MZONE,0)
        e2:SetTarget(aux.TargetBoolFunction(s.haschessvalue))
        e2:SetValue(s.tglimit)
        Duel.RegisterEffect(e2,tp)


        local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_ADJUST)
	e4:SetCondition(s.descon)
	e4:SetOperation(s.desop)
    Duel.RegisterEffect(e4,tp)

    aux.GlobalCheck(s,function()
        s[0]=0
        s[1]=0
        local ge1=Effect.CreateEffect(e:GetHandler())
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
        ge1:SetCode(EVENT_PAY_LPCOST)
        ge1:SetCondition(function(_,tp,_,ep) return ep==tp end)
        ge1:SetOperation(s.checkop)
        Duel.RegisterEffect(ge1,0)
        local ge2=Effect.CreateEffect(e:GetHandler())
        ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge2:SetCode(EVENT_ADJUST)
        ge2:SetCountLimit(1)
        ge2:SetOperation(s.clear)
        Duel.RegisterEffect(ge2,0)
    end)

    local e10=Effect.CreateEffect(e:GetHandler())
	e10:SetType(EFFECT_TYPE_FIELD)
	e10:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e10:SetTargetRange(LOCATION_ONFIELD,0)
	e10:SetCondition(s.mkingcon)
	e10:SetTarget(function(_,c) return c:IsCode(CARD_PANDEMONIUM) and c:IsFaceup() end)
	e10:SetValue(1)
	e10:SetCountLimit(1)
	--Duel.RegisterEffect(e10,tp)

    local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetCategory(CATEGORY_RECOVER)
		e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e5:SetCode(EVENT_PHASE+PHASE_END)
        e5:SetCondition(s.reccon)
		e5:SetCountLimit(1)
		e5:SetOperation(s.recop)
		Duel.RegisterEffect(e5,tp)

    local e6=Effect.CreateEffect(e:GetHandler())
    e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e6:SetCode(EVENT_BATTLE_DAMAGE)
    e6:SetCondition(s.reccon2)
    e6:SetOperation(s.recop2)
    Duel.RegisterEffect(e6,tp)

	local e7=Effect.CreateEffect(e:GetHandler())
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_ADD_RACE)
	e7:SetTargetRange(LOCATION_ALL-LOCATION_OVERLAY,0)
	e7:SetTarget(function (_,c) return c:IsSetCard(0x45) end)
	e7:SetValue(RACE_FIEND)
	Duel.RegisterEffect(e7,tp)

	local e17=Effect.CreateEffect(e:GetHandler())
	e17:SetType(EFFECT_TYPE_FIELD)
	e17:SetCode(EFFECT_ADD_ATTRIBUTE)
	e17:SetTargetRange(LOCATION_ALL-LOCATION_OVERLAY,0)
	e17:SetTarget(function (_,c) return c:IsSetCard(0x45) end)
	e17:SetValue(ATTRIBUTE_DARK)
	Duel.RegisterEffect(e17,tp)

	local e8=Effect.CreateEffect(e:GetHandler())
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetCode(EFFECT_ADD_CODE)
	e8:SetTargetRange(LOCATION_ALL-LOCATION_OVERLAY,0)
	e8:SetTarget(function (_,c) return c:IsOriginalCode(35606858) end)
	e8:SetValue(35975813)
	Duel.RegisterEffect(e8,tp)

	local e9=Effect.CreateEffect(e:GetHandler())
	e9:SetType(EFFECT_TYPE_SINGLE)
	e9:SetCode(EFFECT_DIRECT_ATTACK)
	e9:SetRange(LOCATION_MZONE)
	e9:SetCondition(s.dircon)

	local e21=Effect.CreateEffect(e:GetHandler())
	e21:SetType(EFFECT_TYPE_SINGLE)
	e21:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e21:SetCondition(s.rdcon)
	e21:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))


	local e11=Effect.CreateEffect(e:GetHandler())
	e11:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e11:SetTargetRange(LOCATION_MZONE,0)
	e11:SetTarget(function (_,c) return c:IsCode(VILEPAWN_ARCHFIEND) end)
	e11:SetLabelObject(e9)
	Duel.RegisterEffect(e11,tp)

	local e22=e11:Clone()
	e22:SetLabel(e21)
	Duel.RegisterEffect(e22,tp)


	local e12=Effect.CreateEffect(e:GetHandler())
	e12:SetType(EFFECT_TYPE_FIELD)
	e12:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e12:SetCode(EFFECT_SPSUMMON_PROC)
	e12:SetRange(LOCATION_HAND)
	e12:SetCondition(s.spcon)
	e12:SetOperation(s.spop)

	local e13=Effect.CreateEffect(e:GetHandler())
	e13:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e13:SetTargetRange(LOCATION_HAND,0)
	e13:SetTarget(function (_,c) return c:IsCode(ARCHFIEND_MATADOR) end)
	e13:SetLabelObject(e12)
	--Duel.RegisterEffect(e13,tp)

	local e14=Effect.CreateEffect(e:GetHandler())
	e14:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e14:SetCode(EVENT_TOSS_DICE_NEGATE)
	e14:SetCondition(s.dicecon)
	e14:SetOperation(s.diceop)
	e14:SetCountLimit(1)
	Duel.RegisterEffect(e14,tp)

	end
	e:SetLabel(1)
end

function s.rdcon(e)
	local c,tp=e:GetHandler(),e:GetHandlerPlayer()
	return Duel.GetAttackTarget()==nil and c:GetEffectCount(EFFECT_DIRECT_ATTACK)<2
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end

function s.dicecon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and Duel.GetMatchingGroupCount(s.vilepawnfilter, tp, LOCATION_MZONE, 0, nil, tp)>0
end
function s.diceop(e,tp,eg,ep,ev,re,r,rp)
	local cc=Duel.GetCurrentChain()
	local cid=Duel.GetChainInfo(cc,CHAININFO_CHAIN_ID)
	if s[0]~=cid and Duel.SelectYesNo(tp,aux.Stringid(id,7)) then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
		local pawn=Duel.SelectMatchingCard(tp,s.vilepawnfilter, tp, LOCATION_MZONE, 0, 1,1,false,nil,tp)
		Duel.Release(pawn, REASON_COST)
		local dc={Duel.GetDiceResult()}
		local ac=1
		local ct=(ev&0xff)+(ev>>16)
		Duel.Hint(HINT_CARD,tp,id)
		if ct>1 then
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,7))
			local val,idx=Duel.AnnounceNumber(tp,table.unpack(dc,1,ct))
			ac=idx+1
		end
		dc[ac]=6
		Duel.SetDiceResult(table.unpack(dc))
		s[0]=cid
	end
end


function s.getchesspointvalue(c)
	return Chesspointvalues[c:GetCode()]
end

function s.spfilter(c)
	return c:IsSetCard(0x45) and c:IsAbleToGraveAsCost() and s.haschessvalue(c)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	if not c:IsAbleToGraveAsCost() then
		g:RemoveCard(c)
	end
	return g:CheckWithSumGreater(s.getchesspointvalue,6)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.GetMatchingGroup(s.spfilter,c:GetControler(),LOCATION_HAND+LOCATION_MZONE,0,nil)
	if not c:IsAbleToGraveAsCost() then
		g:RemoveCard(c)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=g:SelectWithSumGreater(tp,s.getchesspointvalue,6)
	Duel.SendtoGrave(sg,REASON_COST)
	Duel.SpecialSummon(e:GetHandler(), SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)
end



function s.oppcardfilter(c,p)
	return c and c:IsControler(1-p) and c:IsType(TYPE_MONSTER)
end

function s.dircon(e)
	return e:GetHandler():GetColumnGroup():FilterCount(s.oppcardfilter,nil,e:GetHandlerPlayer())==0
end




local monsters={}
monsters[0]=Group.CreateGroup()
monsters[1]=Group.CreateGroup()

function s.vilepawnfilter(c,tp)
	return c:IsControler(tp) and c:IsCode(VILEPAWN_ARCHFIEND)
end
function s.reccon2(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and eg:IsExists(s.vilepawnfilter,1,nil,tp) and Duel.GetAttackTarget()==nil
end
function s.recop2(e,tp,eg,ep,ev,re,r,rp)
    local tc=eg:Filter(s.vilepawnfilter, nil, tp):GetFirst()
    if tc and Duel.GetFlagEffect(tp, id+3)==0 and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
        Duel.Hint(HINT_CARD,tp,id)
        if Duel.SendtoGrave(tc, REASON_RULE) then
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)

            local sc=monsters[tp]:Select(tp,1,1,nil):GetFirst()
            if sc then
                local archfiend=Duel.CreateToken(tp, sc:GetOriginalCode())
                Duel.SpecialSummon(archfiend, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)

				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetDescription(3206)
				e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CANNOT_ATTACK)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
				archfiend:RegisterEffect(e1)
            end
			Duel.RegisterFlagEffect(tp, id+3, RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END, 0, 0)
        end
    end
end


function s.kingqueenfilter(c)
    return c:IsCode(52248570,8581705,35975813,36407615,35606858) and c:IsFaceup()
end



function s.reccon(e)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	return Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_PANDEMONIUM),tp,LOCATION_ONFIELD,0,1,nil) and Duel.IsExistingMatchingCard(s.kingqueenfilter,tp,LOCATION_MZONE,0,1,nil) and s[tp]>0
end

function s.recop(e,tp,eg,ep,ev,re,r,rp)
    if(s[tp]>0) and Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
    Duel.Hint(HINT_CARD,tp,id)
    Duel.Recover(tp,s[tp],REASON_EFFECT)
end
end


function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    s[ep]=s[ep]+ev
end
function s.clear(e,tp,eg,ep,ev,re,r,rp)
    s[0]=0
    s[1]=0
end



function s.mkingcon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,MASTERKING_ARCHFIEND),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end


function s.fumatadorfilter(c,e)
    return c:IsCode(ARCHFIEND_MATADOR) and c:IsFaceup() and c:IsDestructable(e)
end

function s.descon(e)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.fumatadorfilter,tp,LOCATION_ONFIELD,0,1,nil,e) and not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_PANDEMONIUM),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	local g=Duel.GetMatchingGroup(s.fumatadorfilter, tp, LOCATION_ONFIELD, 0, nil, e)
	Duel.Destroy(g,REASON_EFFECT)
end




function s.tglimit(e,c)
	return c and not c:GetColumnGroup():IsContains(c:GetBattleTarget())
end



function s.battlecon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_PANDEMONIUM),tp,LOCATION_ONFIELD,0,1,nil) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,ARCHFIEND_MATADOR),tp,LOCATION_ONFIELD,0,1,nil)
end

Chesspointvalues={}
Chesspointvalues[73219648]=1
Chesspointvalues[72192100]=5
Chesspointvalues[92039899]=3
Chesspointvalues[9603356]=3
Chesspointvalues[35798491]=3
Chesspointvalues[8581705]=9
Chesspointvalues[35975813]=4
Chesspointvalues[52248570]=9
Chesspointvalues[35606858]=4

local lowerchessvalues={}
lowerchessvalues[73219648]=nil
lowerchessvalues[72192100]={73219648,92039899,9603356,35798491,35975813,35606858}
lowerchessvalues[92039899]={73219648}
lowerchessvalues[9603356]={73219648}
lowerchessvalues[35798491]={73219648}
lowerchessvalues[8581705]={73219648,92039899,9603356,35798491,35975813,35606858,72192100}
lowerchessvalues[35975813]={73219648,92039899,9603356,35798491}
lowerchessvalues[52248570]={73219648,92039899,9603356,35798491,35975813,35606858,72192100}
lowerchessvalues[35606858]={73219648,92039899,9603356,35798491}

local chessvalueindexes={}
chessvalueindexes[73219648]=1
chessvalueindexes[72192100]=2
chessvalueindexes[92039899]=3
chessvalueindexes[9603356]=4
chessvalueindexes[35798491]=5
chessvalueindexes[8581705]=6
chessvalueindexes[35975813]=7
chessvalueindexes[52248570]=8
chessvalueindexes[35606858]=9

function s.haschessvalue(c)
    return Chesspointvalues[c:GetOriginalCode()]~=nil
end



local CARDS_TO_SUMMON={72192100,92039899,9603356,35798491,8581705,35975813,52248570,35606858}



function s.filltables()
    if #monsters[0]==0 then
        for i, v in pairs(CARDS_TO_SUMMON) do
            local token1=Duel.CreateToken(0, v)
            monsters[0]:AddCard(token1)
            local token2=Duel.CreateToken(1, v)
            monsters[1]:AddCard(token2)
        end
    end
end


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	--start of duel effects go here

	s.startofdueleff(e,tp,eg,ep,ev,re,r,rp)

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.startofdueleff(e,tp,eg,ep,ev,re,r,rp)
    local pandem=Duel.CreateToken(tp, CARD_PANDEMONIUM)
	Duel.ActivateFieldSpell(pandem,e,tp,eg,ep,ev,re,r,rp)
	s.filltables()

	local vilepawns=Group.CreateGroup()
	for i = 1, 2, 1 do
		local vilepawn=Duel.CreateToken(tp, VILEPAWN_ARCHFIEND)
		Group.AddCard(vilepawns, vilepawn)
	end
	Duel.SpecialSummon(vilepawns, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)
end


function s.abletohandfilter(c,codelist)
    return c:IsCode(table.unpack(codelist)) and c:IsAbleToHand()
end

function s.summonarchfiendhandfilter(c,e,tp)
    return c:IsSetCard(0x45) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false,false,POS_FACEUP)
end


function s.specialsummonchessarchfiendfilter(c,e,tp,codelist)
    return c:IsCode(table.unpack(codelist)) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false,false,POS_FACEUP)
end

function s.centerarchfiendfilter(c,e,tp)
    return s.haschessvalue(c) and lowerchessvalues[c:GetOriginalCode()]~=nil and Duel.IsExistingMatchingCard(s.specialsummonchessarchfiendfilter, tp, LOCATION_HAND+LOCATION_DECK, 0, 2, nil, e, tp, lowerchessvalues[c:GetOriginalCode()])
end

--effects to activate during the main phase go here
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)

	if Duel.GetFlagEffect(tp,id+2)>0  then return end --Duel.GetFlagEffect(tp,id+1)>0 and
	--local b1=Duel.GetFlagEffect(tp,id+1)==0 and Duel.IsExistingMatchingCard(s.summonarchfiendhandfilter,tp,LOCATION_HAND,0,1,nil,e,tp)

	local b2=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.centerarchfiendfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)

	return aux.CanActivateSkill(tp) and (b2)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)

if Duel.GetFlagEffect(tp,id+2)>0  then return end --Duel.GetFlagEffect(tp,id+1)>0 and
--local b1=Duel.GetFlagEffect(tp,id+1)==0 and Duel.IsExistingMatchingCard(s.summonarchfiendhandfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
local b1=false

local b2=Duel.GetFlagEffect(tp,id+2)==0
		and Duel.IsExistingMatchingCard(s.centerarchfiendfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)


	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
								  {b2,aux.Stringid(id,1)})
	op=op-1

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	end
end



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)

	local tc=Duel.SelectMatchingCard(tp, s.summonarchfiendhandfilter, tp, LOCATION_HAND, 0, 1,1,false,nil,e,tp)
	if tc then
		Duel.SpecialSummon(tc, SUMMON_TYPE_SPECIAL, tp, tp, false,false, POS_FACEUP)
	end

	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	local tc1=Duel.SelectMatchingCard(tp, s.centerarchfiendfilter, tp, LOCATION_MZONE, 0, 1,1,false,nil,e,tp)
	if tc1 then
		Duel.HintSelection(tc1)

		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
		local tc2=Duel.SelectMatchingCard(tp, s.specialsummonchessarchfiendfilter, tp, LOCATION_HAND+LOCATION_DECK, 0, 1,1,false,nil,e,tp,lowerchessvalues[tc1:GetFirst():GetOriginalCode()])
		Duel.Hint(HINT_SELECTMSG,tp, HINTMSG_CONFIRM)
		local tc3=Duel.SelectMatchingCard(tp, s.specialsummonchessarchfiendfilter, tp, LOCATION_HAND+LOCATION_DECK, 0, 1,1,false,nil,e,tp,lowerchessvalues[tc1:GetFirst():GetOriginalCode()]):GetFirst()

		Duel.SpecialSummon(tc2, SUMMON_TYPE_SPECIAL, tp, tp, false,false,POS_FACEUP)

		if tc3 then

			local op=Duel.SelectEffect(tp, {true,aux.Stringid(id,4)},
								  {true,aux.Stringid(id,5)})

			if op==1 then
				Duel.PayLPCost(tp, tc3:GetAttack())
			else
				Duel.PayLPCost(tp, tc3:GetDefense())
			end

		end


	end

	Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end
