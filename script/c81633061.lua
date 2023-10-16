--Creator of Rush Duels
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
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

		--other passive duel effects go here

		bRush.addrules()(e,tp,eg,ep,ev,re,r,rp)

        local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PREDRAW)
		e2:SetCondition(s.stackcon)
		e2:SetOperation(s.stackop)
		Duel.RegisterEffect(e2,tp)

        s.filltables()

	end
	e:SetLabel(1)
end

local MAXIMUM_CENTERS={160202002,160203002,160207002,160005015}
local MAXIMUM_LEFTS={160202001,160203001,160207001,160428001,160005014}
local MAXIMUM_RIGHTS={160202003,160203003,160207003,160428003,160005016}
local CARDS_TO_ADD={160001039,160002036,160006039,160402001,160402003,160011050,160012045,160013054}

local maximums={}
maximums[0]=Group.CreateGroup()
maximums[1]=Group.CreateGroup()

local spells={}
spells[0]=Group.CreateGroup()
spells[1]=Group.CreateGroup()


function s.filltables()
    if #maximums[0]==0 then
        for i, v in pairs(MAXIMUM_CENTERS) do
            local token1=Duel.CreateToken(0, v)
            maximums[0]:AddCard(token1)
            local token2=Duel.CreateToken(1, v)
            maximums[1]:AddCard(token2)


        end

        for i, v in pairs(CARDS_TO_ADD) do
            local token1=Duel.CreateToken(0, v)
            spells[0]:AddCard(token1)

            local token2=Duel.CreateToken(1, v)
            spells[1]:AddCard(token2)

        end

    end
end

function s.getindex(code)
    for i, v in pairs(MAXIMUM_CENTERS) do
        if v == code then
          return i
        end
    end
end

function s.removefromtable(tabletorem,code)
    for i,v in ipairs(tabletorem) do
        if v:GetCode()==code then
            table.remove(tabletorem,i)
        end
    end
end

function s.abletoaddpiece(c,code)
    return c:IsCode(code) and c:IsAbleToHand()
end

function s.otherpiecefinder(c,code)
    return math.abs(c:GetCode()-code)<4 and not c:IsCode(code)
end

function s.abletopiece(c)
    if not c:IsType(TYPE_MAXIMUM) then return false end

    local g=Duel.GetMatchingGroup(s.otherpiecefinder, c:GetOwner(), LOCATION_DECK, 0, nil, c:GetCode())
    if g:GetClassCount(Card.GetCode)<2 then return false end

    return true
end

function s.ablereviece(c)
    if not c:IsType(TYPE_MAXIMUM) then return false end

    local g=Duel.GetMatchingGroup(s.otherpiecefinder, c:GetOwner(), LOCATION_HAND, 0, nil, c:GetCode())
    if g:GetClassCount(Card.GetCode)<2 then return false end

    return not c:IsPublic()
end

function s.stackcon(e,tp,eg,ep,ev,re,r,rp)
    if not ( Duel.GetTurnCount()>2 and Duel.GetTurnPlayer()==tp and Duel.GetFlagEffect(tp, id+1)==0 and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)<3) then return false end
    local g=Duel.GetDecktopGroup(tp, 5-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0))
    if g:IsExists(s.abletopiece, 1, nil) then return true end
    return false
end
function s.stackop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.SelectYesNo(tp, aux.Stringid(id, 7)) then
        local tc=Duel.GetFirstMatchingCard(s.abletopiece, tp, LOCATION_DECK, 0, nil)
        local pieces=Duel.GetMatchingGroup(s.otherpiecefinder, tp, LOCATION_DECK, 0, nil, tc:GetCode())
        local tc2=pieces:GetFirst()
        local filteredpieces=pieces:Filter(s.otherpiecefinder, nil, tc2:GetCode())
        local tc3=filteredpieces:GetFirst()
        Duel.DisableShuffleCheck()

        Duel.MoveSequence(tc2,0 )
        Duel.MoveSequence(tc,0 )
        Duel.MoveSequence(tc3, 0)

        Duel.DisableShuffleCheck(false)

        Duel.RegisterFlagEffect(tp, id+1, 0, 0, 0)
    end
end




function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)


	Duel.RegisterFlagEffect(tp,id,0,0,0)
end


function s.furoadmagicianfilter(c)
    return c:IsFaceup() and c:IsCode(CARD_SEVENS_ROAD_MAGICIAN)
end

function s.summonedmaximummonster(c)
    return c:IsMaximumMode()
end

function s.specialsummonmagicianfilter(c,e,tp)
    return c:IsCode(CARD_SEVENS_ROAD_MAGICIAN) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false,false)
end

function s.completemaximumfiler(c)
    if not c:IsType(TYPE_MAXIMUM) then return false end

    local g=Duel.GetMatchingGroup(s.otherpiecefinder, c:GetOwner(), LOCATION_GRAVE, 0, nil, c:GetCode())
    if g:GetClassCount(Card.GetCode)<2 then return false end

    return c:IsAbleToHand()
end

function s.discardfilter(c)
    return c:IsDiscardable(REASON_COST)
end


--effects to activate during the main phase go here
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	--checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
	if Duel.GetFlagEffect(tp,id+2)>0 and Duel.GetFlagEffect(tp,id+3)>0 and Duel.GetFlagEffect(tp,id+4)>0 and Duel.GetFlagEffect(tp,id+5)>0  then return end
	--Boolean checks for the activation condition: b1, b2

--do bx for the conditions for each effect, and at the end add them to the return
	local b1=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.ablereviece,tp,LOCATION_HAND,0,1,nil)
						and #maximums[tp]>0

	local b2=Duel.GetFlagEffect(tp,id+3)==0
			and Duel.IsExistingMatchingCard(s.summonedmaximummonster,tp,LOCATION_MZONE,0,1,nil)
            and Duel.IsExistingMatchingCard(s.specialsummonmagicianfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)

    local b3=Duel.GetFlagEffect(tp,id+4)==0
        and Duel.IsExistingMatchingCard(s.furoadmagicianfilter,tp,LOCATION_ONFIELD,0,1,nil)
                and #spells[tp]>0

	local b4=Duel.GetFlagEffect(tp,id+5)==0
			and Duel.IsExistingMatchingCard(s.discardfilter,tp,LOCATION_HAND,0,3,nil)
            and Duel.IsExistingMatchingCard(s.completemaximumfiler,tp,LOCATION_GRAVE,0,1,nil)


--return the b1 or b2 or .... in parenthesis at the end
	return aux.CanActivateSkill(tp) and (b1 or b2 or b3 or b4)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:

--copy the bxs from above

    local b1=Duel.GetFlagEffect(tp,id+2)==0
    and Duel.IsExistingMatchingCard(s.ablereviece,tp,LOCATION_HAND,0,1,nil)
                and #maximums[tp]>0

    local b2=Duel.GetFlagEffect(tp,id+3)==0
        and Duel.IsExistingMatchingCard(s.summonedmaximummonster,tp,LOCATION_MZONE,0,1,nil)
        and Duel.IsExistingMatchingCard(s.specialsummonmagicianfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)

    local b3=Duel.GetFlagEffect(tp,id+4)==0
    and Duel.IsExistingMatchingCard(s.furoadmagicianfilter,tp,LOCATION_ONFIELD,0,1,nil)
        and #spells[tp]>0

    local b4=Duel.GetFlagEffect(tp,id+5)==0
        and Duel.IsExistingMatchingCard(s.discardfilter,tp,LOCATION_HAND,0,3,nil)
        and Duel.IsExistingMatchingCard(s.completemaximumfiler,tp,LOCATION_GRAVE,0,1,nil)

--effect selector
	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
								  {b2,aux.Stringid(id,1)},
								  {b3,aux.Stringid(id,2)},
								  {b4,aux.Stringid(id,6)})
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
    local tc=Duel.SelectMatchingCard(tp, s.ablereviece, tp, LOCATION_HAND, 0, 1,1,false,nil):GetFirst()
    if tc then
        local pieces=Duel.GetMatchingGroup(s.otherpiecefinder, tp, LOCATION_HAND, 0, tc, tc:GetCode())
        local tc2=pieces:GetFirst()
        local filteredpieces=pieces:Filter(s.otherpiecefinder, nil, tc2:GetCode())
        local tc3=filteredpieces:GetFirst()

        local g=Group.CreateGroup()
        g:AddCard(tc)
        g:AddCard(tc2)
        g:AddCard(tc3)

        Duel.ConfirmCards(1-tp, g)

        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local tar=maximums[tp]:Select(tp,1,1,nil):GetFirst()
        maximums[tp]:RemoveCard(tar)

        local tar1=Duel.CreateToken(tp, tar:GetCode()+1)
        local tar2=Duel.CreateToken(tp, tar:GetCode()-1)

        local cards=Group.CreateGroup()
        cards:AddCard(tar)
        cards:AddCard(tar2)
        cards:AddCard(tar1)

        Duel.RemoveCards(g)

        Duel.SendtoHand(cards, tp, REASON_RULE)
        Duel.ConfirmCards(1-tp, cards)


    end


	Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.TRUE, tp, LOCATION_MZONE, 0, nil)
    if Duel.SendtoHand(g, tp, REASON_RULE) then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local magician=Duel.SelectMatchingCard(tp, s.specialsummonmagicianfilter, tp, LOCATION_GRAVE, 0, 1,1,false,nil,e,tp)
        Duel.SpecialSummon(magician, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)
    end

	Duel.RegisterFlagEffect(tp,id+3,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end

function s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local tar=spells[tp]:Select(tp,1,1,nil):GetFirst()
    spells[tp]:RemoveCard(tar)

    Duel.SendtoHand(tar, tp, REASON_RULE)
    Duel.ConfirmCards(1-tp, tar)

	Duel.RegisterFlagEffect(tp,id+4,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end

function s.operation_for_res3(e,tp,eg,ep,ev,re,r,rp)
    if Duel.DiscardHand(tp,Card.IsDiscardable,3,3,REASON_COST+REASON_DISCARD,nil) then
        local maximum=Duel.SelectMatchingCard(tp, s.completemaximumfiler, tp, LOCATION_GRAVE, 0, 1,1,false,nil):GetFirst()
        local pieces=Duel.GetMatchingGroup(s.otherpiecefinder, tp, LOCATION_GRAVE, 0, tc, maximum:GetCode())
        local tc2=pieces:GetFirst()
        local filteredpieces=pieces:Filter(s.otherpiecefinder, nil, tc2:GetCode())
        local tc3=filteredpieces:GetFirst()

        local cards=Group.CreateGroup()
        cards:AddCard(maximum)
        cards:AddCard(tc2)
        cards:AddCard(tc3)

        Duel.SendtoHand(cards, tp, REASON_RULE)
        Duel.ConfirmCards(1-tp, cards)
        
    end

	Duel.RegisterFlagEffect(tp,id+5,0,0,0)
end
