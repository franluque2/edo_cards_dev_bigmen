--King of Rush Duels
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


	end
	e:SetLabel(1)
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
    if not c:IsCode(160422002) then return false end
    local g=Duel.GetMatchingGroup(s.otherpiecefinder, c:GetOwner(), LOCATION_DECK+LOCATION_GRAVE, 0, nil, c:GetCode())
    if g:GetClassCount(Card.GetCode)<2 then return false end


    return true
end

function s.stackcon(e,tp,eg,ep,ev,re,r,rp)
	if not ( Duel.GetTurnCount()>2 and Duel.GetTurnPlayer()==tp and Duel.GetFlagEffect(tp, id+1)==0 and Duel.GetLocationCount(tp, LOCATION_HAND)<3) then return false end
    local g=Duel.GetDecktopGroup(tp, 5-Duel.GetLocationCount(tp, LOCATION_HAND))
    if g:IsExists(s.abletopiece, 1, nil) then return true end
    return false
end
function s.stackop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.SelectYesNo(tp, aux.Stringid(id, 4)) then
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
    
    local sportd1=Duel.CreateToken(tp, 160001024)
    Duel.SendtoGrave(sportd1, REASON_RULE)

    local sportd2=Duel.CreateToken(tp, 160001025)
    Duel.SendtoGrave(sportd2, REASON_RULE)

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end


function s.summonedmaximummonster(c)
    return c:IsMaximumMode()
end

function s.specialsummondragonfilter(c,e,tp)
    return c:IsRace(RACE_DRAGON) and c:IsLevel(7) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false,false)
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
    local g=Duel.GetMatchingGroup(s.spcfilter, tp, LOCATION_HAND, 0, nil)


--do bx for the conditions for each effect, and at the end add them to the return
local b1=Duel.GetFlagEffect(tp,id+2)==0
    and g:GetClassCount(Card.GetCode)>2
    and Duel.IsExistingMatchingCard(s.ablereviece,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)

local b2=Duel.GetFlagEffect(tp,id+3)==0
    and Duel.IsExistingMatchingCard(s.summonedmaximummonster,tp,LOCATION_MZONE,0,1,nil)
    and Duel.IsExistingMatchingCard(s.specialsummondragonfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)

local b3=Duel.GetFlagEffect(tp,id+4)==0
    and Duel.GetMatchingGroupCount(s.fudragonfilter, tp, LOCATION_MZONE, 0, nil)==Duel.GetMatchingGroupCount(aux.TRUE, tp, LOCATION_MZONE, 0, nil)==2
    and Duel.GetMatchingGroupCount(s.fudragonfilter, tp, LOCATION_MZONE, 0, nil)==2
    and Duel.IsExistingMatchingCard(s.sethnovafilter, tp, LOCATION_GRAVE+LOCATION_DECK, 0, 1, nil)

local b4=Duel.GetFlagEffect(tp,id+5)==0
    and Duel.IsExistingMatchingCard(s.revfusionfilter, tp, LOCATION_HAND, 0, 1, nil)
    and Duel.IsExistingMatchingCard(s.addstardragonfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)


--return the b1 or b2 or .... in parenthesis at the end
	return aux.CanActivateSkill(tp) and (b1 or b2 or b3 or b4)
end

function s.revfusionfilter(c)
    return c:IsCode(CARD_FUSION) and not c:IsPublic()
end
function s.addstardragonfilter(c)
    return c:IsCode(160204026) and c:IsAbleToHand()
end

function s.fudragonfilter(c)
    return c:IsRace(RACE_DRAGON) and c:IsLevel(7) and c:IsFaceup()
end

function s.sethnovafilter(c)
    return c:IsCode(160006040) and c:IsSSetable()
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:

--copy the bxs from above
    local g=Duel.GetMatchingGroup(s.spcfilter, tp, LOCATION_HAND, 0, nil)

    local b1=Duel.GetFlagEffect(tp,id+2)==0
    and g:GetClassCount(Card.GetCode)>2
        and Duel.IsExistingMatchingCard(s.ablereviece,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)

    local b2=Duel.GetFlagEffect(tp,id+3)==0
        and Duel.IsExistingMatchingCard(s.summonedmaximummonster,tp,LOCATION_MZONE,0,1,nil)
        and Duel.IsExistingMatchingCard(s.specialsummondragonfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)

    local b3=Duel.GetFlagEffect(tp,id+4)==0
        and Duel.GetMatchingGroupCount(s.fudragonfilter, tp, LOCATION_MZONE, 0, nil)==Duel.GetMatchingGroupCount(aux.TRUE, tp, LOCATION_MZONE, 0, nil)
        and Duel.GetMatchingGroupCount(s.fudragonfilter, tp, LOCATION_MZONE, 0, nil)==2
        and Duel.IsExistingMatchingCard(s.sethnovafilter, tp, LOCATION_GRAVE+LOCATION_DECK, 0, 1, nil)

    local b4=Duel.GetFlagEffect(tp,id+5)==0
        and Duel.IsExistingMatchingCard(s.revfusionfilter, tp, LOCATION_HAND, 0, 1, nil)
        and Duel.IsExistingMatchingCard(s.addstardragonfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)

--effect selector
	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
								  {b2,aux.Stringid(id,1)},
								  {b3,aux.Stringid(id,2)},
								  {b4,aux.Stringid(id,3)})
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

    local hg=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_HAND,0,e:GetHandler())
	local g=aux.SelectUnselectGroup(hg,e,tp,3,3,s.rescon,1,tp,HINTMSG_TODECK,nil,nil,true)

    if Duel.SendtoDeck(g, tp, SEQ_DECKBOTTOM, REASON_RULE) then

        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local tc=Duel.SelectMatchingCard(tp, s.ablereviece, tp, LOCATION_DECK+LOCATION_GRAVE, 0, 1,1,false,nil):GetFirst()
        if tc then
            local pieces=Duel.GetMatchingGroup(s.otherpiecefinder, tp, LOCATION_DECK+LOCATION_GRAVE, 0, tc, tc:GetCode())
            local tc2=pieces:Select(tp, 1,1,nil):GetFirst()
            local filteredpieces=pieces:Filter(s.otherpiecefinder, nil, tc2:GetCode())
            local tc3=filteredpieces:Select(tp, 1,1,nil):GetFirst()
    
            local g=Group.CreateGroup()
            g:AddCard(tc)
            g:AddCard(tc2)
            g:AddCard(tc3)
    
            if Duel.SendtoHand(g, tp, REASON_RULE) then
                Duel.ConfirmCards(1-tp, g)
            end        
        end
    end

	Duel.RegisterFlagEffect(tp,id+2,0,0,0)
end


function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.TRUE, tp, LOCATION_MZONE, 0, nil)
    if Duel.SendtoHand(g, tp, REASON_RULE) then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local magician=Duel.SelectMatchingCard(tp, s.specialsummondragonfilter, tp, LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE, 0, 1,1,false,nil,e,tp)
        Duel.SpecialSummon(magician, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)
    end



	Duel.RegisterFlagEffect(tp,id+3,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end

function s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
    local hnova=Duel.SelectMatchingCard(tp, s.sethnovafilter, tp, LOCATION_GRAVE+LOCATION_DECK, 0, 1,1,false,nil)
    if hnova and Duel.SSet(tp, hnova) then 
        Duel.ConfirmCards(1-tp, hnova)
    end
    


	Duel.RegisterFlagEffect(tp,id+4,0,0,0)
end

function s.spcfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsLevel(7) and not c:IsPublic()
end
function s.rescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetCode)==#sg,sg:GetClassCount(Card.GetCode)~=#sg
end

function s.operation_for_res3(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local fusion=Duel.SelectMatchingCard(tp, s.revfusionfilter, tp, LOCATION_HAND, 0, 1,1,false,nil)

    Duel.ConfirmCards(1-tp, fusion)

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sdragon=Duel.SelectMatchingCard(tp, s.addstardragonfilter, tp, LOCATION_DECK+LOCATION_GRAVE, 0, 1,1,false,nil)

    Duel.SendtoHand(sdragon, tp, REASON_RULE)
    Duel.ConfirmCards(1-tp, sdragon)



	Duel.RegisterFlagEffect(tp,id+5,0,0,0)
end
