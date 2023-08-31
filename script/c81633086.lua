--Revenge of the Guardians
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

    aux.GlobalCheck(s,function()
		s.name_list={}
		s.name_list[0]={}
		s.name_list[1]={}
		aux.AddValuesReset(function()
			s.name_list[0]={}
			s.name_list[1]={}
		end)
	end)
end
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

        --Flip on summon turn
        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_DELAY)
        e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e3:SetCode(EVENT_MSET)
        e3:SetOperation(s.setstatuschange)
        Duel.RegisterEffect(e3,tp)

        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
        e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
        e2:SetDescription(aux.Stringid(id,0))
        e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x52))
        Duel.RegisterEffect(e2,tp)

        --add on equip
        local e4=Effect.CreateEffect(e:GetHandler())
        e4:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_DELAY)
        e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e4:SetCode(EVENT_EQUIP)
        e4:SetCondition(s.addcon)
        e4:SetOperation(s.addop)
        Duel.RegisterEffect(e4,tp)
	end
	e:SetLabel(1)
end

function s.guardianmentionsfilter(c,tp,code)
    return c:IsSetCard(0x52) and c:ListsCode(code) and c:IsAbleToHand() and not s.name_list[tp][c:GetCode()]
end

function s.addconfilter(c,tp)
	return Duel.IsExistingMatchingCard(s.guardianmentionsfilter, tp, LOCATION_DECK+LOCATION_GRAVE, 0, 1, nil, tp, c:GetCode())
end
function s.addcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.addconfilter,1,nil,tp) and rp==tp
end

function s.addop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
        Duel.Hint(HINT_CARD, tp, id)
        local g=Group.CreateGroup()
        for tc in eg:Iter() do
            local tg=Duel.GetMatchingGroup(s.guardianmentionsfilter, tp, LOCATION_DECK+LOCATION_GRAVE, 0, nil,tp,tc:GetCode())
            g:Merge(tg)
        end
        if #g>0 then
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
            local tc=g:Select(tp, 1,1,nil):GetFirst()
            if tc then
                Duel.SendtoHand(tc, tp, REASON_RULE)
                Duel.ConfirmCards(1-tp, tc)
                s.name_list[tp][tc:GetCode()]=true
            end
        end
    end

end


function s.setstatuschange(e,tp,eg,ev,ep,re,r,rp)
	local tc=eg:GetFirst()
	if Duel.GetTurnPlayer()==tp and tc:IsCode(85489096) then
		tc:SetStatus(STATUS_SUMMON_TURN, false)
	end
end




function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)


	s.startofdueleff(e,tp,eg,ep,ev,re,r,rp)

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.startofdueleff(e,tp,eg,ep,ev,re,r,rp)

    local seal=Duel.CreateToken(tp, 48179391)
	Duel.ActivateFieldSpell(seal,e,tp,eg,ep,ev,re,r,rp)

end

function s.revequipfilter(c)
    return c:IsSpell() and c:IsType(TYPE_EQUIP) and not c:IsPublic()
end

function s.addeatosfilter(c)
    return c:IsCode(34022290) and c:IsAbleToHand()
end

function s.equippedeatosfilter(c)
   return c:IsCode(34022290) and c:GetEquipGroup():IsExists(Card.IsCode,1,nil,55569674)
end

function s.shufflepowerfilter(c)
    return c:IsCode(01118137) and c:IsAbleToDeck() and c:IsFaceup()
end

function s.guardianthatmentionsfilter(c,code)
    return c:IsSetCard(0x52) and c:ListsCode(code)
end

function s.addequipspellfilter(c,tp)
    return c:IsSpell() and c:IsType(TYPE_EQUIP) and Duel.IsExistingMatchingCard(s.guardianthatmentionsfilter, tp, LOCATION_ALL, 0,1, nil, c:GetCode()) and c:IsAbleToHand()
end

function s.fusealfilter(c)
    return c:IsCode(48179391) and c:IsFaceup()
end

function s.summoneatosfilter(c,e,tp)
    return c:IsCode(34022290) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false, false)
end

--effects to activate during the main phase go here
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	--checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0 and Duel.GetFlagEffect(tp,id+3)>0 and Duel.GetFlagEffect(tp,id+4)>0  then return end
	--Boolean checks for the activation condition: b1, b2

--do bx for the conditions for each effect, and at the end add them to the return
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.revequipfilter, tp, LOCATION_HAND, 0, 2, nil)
            and Duel.IsExistingMatchingCard(s.addeatosfilter, tp, LOCATION_DECK, 0, 1, nil)

	local b2=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.equippedeatosfilter,tp,LOCATION_MZONE,0,1,nil)

    local b3=Duel.GetFlagEffect(tp,id+3)==0
        and Duel.IsExistingMatchingCard(s.shufflepowerfilter,tp,LOCATION_ONFIELD,0,1,nil)
                    and Duel.IsExistingMatchingCard(s.addequipspellfilter,tp,LOCATION_DECK,0,1,nil,tp)

    local b4=Duel.GetFlagEffect(tp,id+4)==0
        and Duel.IsExistingMatchingCard(s.fusealfilter,tp,LOCATION_ONFIELD,0,1,nil)
        and Duel.GetLP(tp)<=2000



--return the b1 or b2 or .... in parenthesis at the end
	return aux.CanActivateSkill(tp) and (b1 or b2 or b3 or b4)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:

--copy the bxs from above

    local b1=Duel.GetFlagEffect(tp,id+1)==0
        and Duel.IsExistingMatchingCard(s.revequipfilter, tp, LOCATION_HAND, 0, 2, nil)
        and Duel.IsExistingMatchingCard(s.addeatosfilter, tp, LOCATION_DECK, 0, 1, nil)

    local b2=Duel.GetFlagEffect(tp,id+2)==0
        and Duel.IsExistingMatchingCard(s.equippedeatosfilter,tp,LOCATION_MZONE,0,1,nil)

    local b3=Duel.GetFlagEffect(tp,id+3)==0
    and Duel.IsExistingMatchingCard(s.shufflepowerfilter,tp,LOCATION_ONFIELD,0,1,nil)
            and Duel.IsExistingMatchingCard(s.addequipspellfilter,tp,LOCATION_DECK,0,1,nil,tp)

    local b4=Duel.GetFlagEffect(tp,id+4)==0
        and Duel.IsExistingMatchingCard(s.fusealfilter,tp,LOCATION_ONFIELD,0,1,nil)
        and Duel.GetLP(tp)<=2000


--effect selector
	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,2)},
								  {b2,aux.Stringid(id,3)},
								  {b3,aux.Stringid(id,4)},
								  {b4,aux.Stringid(id,5)})
	op=op-1

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then
		s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
	elseif op==3 then
		s.operation_for_res3(e,tp,eg,ep,ev,re,r,rp)
	end
end



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
    local g=Duel.SelectMatchingCard(tp, s.revequipfilter, tp, LOCATION_HAND, 0, 2,2,false,nil)
    Duel.ConfirmCards(1-tp, g)

    local eatos=Duel.GetFirstMatchingCard(s.addeatosfilter, tp, LOCATION_DECK, 0, nil)
    if eatos then
        Duel.SendtoHand(eatos, tp, REASON_RULE)
        Duel.ConfirmCards(1-tp, eatos)
    end


	Duel.RegisterFlagEffect(tp,id+1,0,0,0)
end


function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
    local dread=Duel.CreateToken(tp, 18175965)
    Duel.SendtoHand(dread, tp, REASON_RULE)
    local scythe=Duel.CreateToken(tp, 81954378)
    Duel.SendtoDeck(scythe, tp, SEQ_DECKBOTTOM, REASON_RULE)

    Duel.ConfirmCards(1-tp, dread)

	Duel.RegisterFlagEffect(tp,id+2,0,0,0)
end

function s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp, s.shufflepowerfilter, tp, LOCATION_ONFIELD, 0, 1,1,false,nil)

    if g and Duel.SendtoDeck(g, tp, SEQ_DECKSHUFFLE, REASON_RULE) then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local tc=Duel.SelectMatchingCard(tp, s.addequipspellfilter, tp, LOCATION_DECK, 0, 1,1,false,nil,tp)
        if tc then
            Duel.SendtoHand(tc, tp, REASON_RULE)
            Duel.ConfirmCards(1-tp, tc)
        end
    
    end



	Duel.RegisterFlagEffect(tp,id+3,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end

function s.remfilter(c)
    return c:IsMonster() and c:IsAbleToRemove()
end


function s.operation_for_res3(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsCode,34022290))
	e1:SetValue(aux.tgoval)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,8))

    if Duel.IsExistingMatchingCard(s.summoneatosfilter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp) and Duel.GetLocationCount(tp, LOCATION_SZONE)>0 and Duel.GetLocationCount(tp, LOCATION_MZONE)
        and Duel.SelectYesNo(tp, aux.Stringid(id, 6)) then
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)

            local eatos=Duel.SelectMatchingCard(tp, s.summoneatosfilter, tp, LOCATION_GRAVE, 0, 1,1,false,nil,e,tp):GetFirst()
            if eatos then
                local g=Duel.GetMatchingGroup(s.remfilter, tp, LOCATION_GRAVE, 0, eatos)
                if Duel.Remove(g, POS_FACEUP, REASON_EFFECT) then
                    Duel.SpecialSummon(eatos, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)
                    local sword=Duel.CreateToken(tp, 55569674)
                    Duel.Equip(tp,sword,eatos)
                    
                    local e3=Effect.CreateEffect(e:GetHandler())
                    e3:SetDescription(aux.Stringid(id,7))
                    e3:SetCategory(CATEGORY_DESTROY)
                    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
                    e3:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
                    e3:SetRange(LOCATION_SZONE)
                    e3:SetCountLimit(1)
                    e3:SetOperation(s.sdesop)
                    sword:RegisterEffect(e3)
                end
            end
        end


	Duel.RegisterFlagEffect(tp,id+4,0,0,0)
end


function s.sdesop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		Duel.Destroy(c,REASON_EFFECT)
	end
end

