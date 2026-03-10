--Masquerade at the Crossroads
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
        e2:SetCode(EVENT_ADJUST)
        e2:SetOperation(s.addauxtags)
        Duel.RegisterEffect(e2,tp)
	end
	e:SetLabel(1)
end






function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	s.maskmonsters(e,tp,eg,ep,ev,re,r,rp)

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.maskmonsters(e,tp,eg,ep,ev,re,r,rp)
    local cards=Duel.GetMatchingGroup(aux.TRUE, tp, LOCATION_ALL, 0, nil)
    if cards then
        
        for card in cards:Iter() do
            
			s.maskcard(e,tp,card)
        end
        
    end

    Duel.ShuffleDeck(tp)
    Duel.ShuffleHand(tp)
    Duel.ShuffleExtra(tp)
end

local idstoreplace={}
idstoreplace[TYPE_SYNCHRO]=id+6
idstoreplace[TYPE_XYZ]=id+9
idstoreplace[TYPE_FUSION]=id+4
idstoreplace[TYPE_LINK]=id+7
idstoreplace[TYPE_PENDULUM]=id+8
idstoreplace[TYPE_RITUAL]=id+5

local linkidstoreplace={}
linkidstoreplace[1]=811632076
linkidstoreplace[2]=811632069
linkidstoreplace[3]=811632072
linkidstoreplace[4]=811632073
linkidstoreplace[5]=811632074
linkidstoreplace[6]=811632075

local spellidstoreplace={}
spellidstoreplace[TYPE_FIELD]=811632080
spellidstoreplace[TYPE_CONTINUOUS]=811632077
spellidstoreplace[TYPE_EQUIP]=811632079
spellidstoreplace[TYPE_QUICKPLAY]=811632078
spellidstoreplace[TYPE_RITUAL]=811632081

local trapidstoreplace={}
trapidstoreplace[TYPE_CONTINUOUS]=811632082
trapidstoreplace[TYPE_COUNTER]=811632083

function s.maskcard(e,tp,card)
    local cardid=card:GetOriginalCode()

    if card:IsMonster() then
            local cardatk=card:GetBaseAttack()
            local carddef=card:GetBaseDefense()
            local cardlevel=Card.GetLevel(card)
			local istuner=card:IsType(TYPE_TUNER)
            local rank=card:GetRank()
            local link=card:GetLink()
            local linkarrows=card:LinkMarker()
            local archetypes={card:Setcode()}
            local lscale=card:GetLeftScale()
            local rscale=card:GetRightScale()
            local race=card:GetOriginalRace()
            local attribute=card:GetOriginalAttribute()

            local idtoreplace=id+1
            local specialtype=0
            for _,type in ipairs({TYPE_SYNCHRO,TYPE_XYZ,TYPE_FUSION,TYPE_LINK,TYPE_PENDULUM,TYPE_RITUAL}) do
                if card:IsType(type) then
                    idtoreplace=idstoreplace[type]
                    if card:IsType(TYPE_LINK) then
                        idtoreplace=linkidstoreplace[link]
                    end
                    specialtype=type
                    break
                end
            end

            
            Card.Recreate(card, idtoreplace, nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,false)
            Card.RegisterFlagEffect(card, id, 0, 0, 0)
            Card.SetFlagEffectLabel(card, id, cardid)

            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_SET_BASE_ATTACK)
            e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
            e2:SetRange(LOCATION_MZONE)
            e2:SetCondition(s.atkcon)
            e2:SetValue(cardatk)
            card:RegisterEffect(e2)
            local e3=e2:Clone()
            e3:SetCode(EFFECT_SET_BASE_DEFENSE)
            e3:SetValue(carddef)
            card:RegisterEffect(e3)
            local erace=Effect.CreateEffect(e:GetHandler())
            erace:SetType(EFFECT_TYPE_SINGLE)
            erace:SetCode(EFFECT_CHANGE_RACE)
            erace:SetValue(race)
            card:RegisterEffect(erace)

            local eattribute=Effect.CreateEffect(e:GetHandler())
            eattribute:SetType(EFFECT_TYPE_SINGLE)
            eattribute:SetCode(EFFECT_CHANGE_ATTRIBUTE)
            eattribute:SetValue(attribute)
            card:RegisterEffect(eattribute)

			if card:HasLevel() then
				local e4=Effect.CreateEffect(e:GetHandler())
				e4:SetType(EFFECT_TYPE_SINGLE)
				e4:SetCode(EFFECT_CHANGE_LEVEL)
				e4:SetValue(cardlevel)
				card:RegisterEffect(e4)
			end

			if istuner then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_ADD_TYPE)
				e1:SetValue(TYPE_TUNER)
				card:RegisterEffect(e1)
			end

            if specialtype~=0 then
                if specialtype==TYPE_LINK then
                    local e11=Effect.CreateEffect(e:GetHandler())
                    e11:SetType(EFFECT_TYPE_SINGLE)
                    e11:SetCode(EFFECT_CHANGE_LINK)
                    e11:SetValue(link)
                    card:RegisterEffect(e11)

                    card:LinkMarker(linkarrows)
                elseif specialtype==TYPE_XYZ then
                    local e121=Effect.CreateEffect(e:GetHandler())
                    e121:SetType(EFFECT_TYPE_SINGLE)
                    e121:SetCode(EFFECT_CHANGE_RANK)
                    e121:SetValue(rank)
                    card:RegisterEffect(e121)
                end
                if specialtype==TYPE_PENDULUM then

                    if not card:IsType(TYPE_PENDULUM) then
                        local e1=Effect.CreateEffect(e:GetHandler())
                        e1:SetType(EFFECT_TYPE_SINGLE)
                        e1:SetCode(EFFECT_ADD_TYPE)
                        e1:SetValue(TYPE_PENDULUM)
                        card:RegisterEffect(e1)
                    end

                    local e12=Effect.CreateEffect(e:GetHandler())
                    e12:SetType(EFFECT_TYPE_SINGLE)
                    e12:SetCode(EFFECT_CHANGE_LSCALE)
                    e12:SetValue(lscale)
                    card:RegisterEffect(e12)
                    local e13=e12:Clone()
                    e13:SetCode(EFFECT_CHANGE_RSCALE)
                    e13:SetValue(rscale)
                    card:RegisterEffect(e13)
                end
            end

            for _,archetype in ipairs(archetypes) do
				local e13=Effect.CreateEffect(e:GetHandler())
				e13:SetType(EFFECT_TYPE_SINGLE)
				e13:SetCode(EFFECT_ADD_SETCODE)
				e13:SetValue(archetype)
				card:RegisterEffect(e13)
            end
        elseif card:IsSpell() then
            local archetypes={card:Setcode()}

            local extratype=nil
            if card:IsType(TYPE_FIELD) then
                extratype=TYPE_FIELD
            elseif card:IsType(TYPE_CONTINUOUS) then
                extratype=TYPE_CONTINUOUS
            elseif card:IsType(TYPE_EQUIP) then
                extratype=TYPE_EQUIP
            elseif card:IsType(TYPE_QUICKPLAY) then
                extratype=TYPE_QUICKPLAY
            elseif card:IsType(TYPE_RITUAL) then
                extratype=TYPE_RITUAL
            end
            local idtoreplace=id+2

            if extratype then
                idtoreplace=spellidstoreplace[extratype]
            end

            Card.Recreate(card, idtoreplace, nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,false)
            Card.RegisterFlagEffect(card, id, 0, 0, 0)
            Card.SetFlagEffectLabel(card, id, cardid)

            if extratype then
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_ADD_TYPE)
                e1:SetValue(extratype)
                card:RegisterEffect(e1)
            end

            for _,archetype in ipairs(archetypes) do
                local e13=Effect.CreateEffect(e:GetHandler())
                e13:SetType(EFFECT_TYPE_SINGLE)
                e13:SetCode(EFFECT_ADD_SETCODE)
                e13:SetValue(archetype)
                card:RegisterEffect(e13)
            end

        elseif card:IsTrap() then
            local archetypes={card:Setcode()}

            local idtoreplace=id+3

            local extratype=nil
            if card:IsType(TYPE_CONTINUOUS) then
                extratype=TYPE_CONTINUOUS
            elseif card:IsType(TYPE_COUNTER) then
                extratype=TYPE_COUNTER
            end

            if extratype then
                idtoreplace=trapidstoreplace[extratype]
            end

            Card.Recreate(card, idtoreplace, nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,false)
            Card.RegisterFlagEffect(card, id, 0, 0, 0)
            Card.SetFlagEffectLabel(card, id, cardid)

            if extratype then
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_ADD_TYPE)
                e1:SetValue(extratype)
                card:RegisterEffect(e1)
            end

            for _,archetype in ipairs(archetypes) do
                local e13=Effect.CreateEffect(e:GetHandler())
                e13:SetType(EFFECT_TYPE_SINGLE)
                e13:SetCode(EFFECT_ADD_SETCODE)
                e13:SetValue(archetype)
                card:RegisterEffect(e13)
            end

        end
end

function s.unmaskcard(e,tp,card)
	local originalid=Card.GetFlagEffectLabel(card, id)
	Card.Recreate(card, originalid, nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCondition(s.sumcon)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	card:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	card:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	card:RegisterEffect(e3)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_CANNOT_MSET)
	card:RegisterEffect(e4)

	card:RegisterFlagEffect(id+1, 0,0,0)
end

function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id+1)~=0
end

function s.atkcon(e)
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL)
end

function s.shadowmonster(c)
	return c:IsCode(id+1)
end

function s.notshadowmonster(c)
	return c:IsMonster() and not s.shadowmonster(c)
end

function s.nothastagfilter(c)
    return c:GetFlagEffect(id)==1 and c:GetFlagEffect(id+1)==0
end

function s.addauxtags(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.nothastagfilter, tp, LOCATION_HAND, 0, nil)
    for tc in g:Iter() do
        tc:RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD,0,1,0,0)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_CODE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetValue(tc:GetFlagEffectLabel(id))
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)

    end
end
--[[]
local oldfunc=Duel.ConfirmCards
Duel.ConfirmCards=function(p, cards)
    if cards:IsExists(Card.GetFlagEffect, 1, nil, id+1) then
        for tc in cards:Iter() do
            local changeeffs={tc:GetOwnEffects()}
            for _,eff in ipairs(changeeffs) do
                if eff:GetCode()==EFFECT_CHANGE_CODE and eff:GetProperty()&EFFECT_FLAG_CANNOT_DISABLE~=0 then
                    eff:Reset()
                    Debug.Message(eff)
                    Duel.AdjustInstantly()
                                        Debug.Message(eff)

                    tc:ResetFlagEffect(id+1)
                end
            end
        end
    end
    return oldfunc(p, cards)
end
]]