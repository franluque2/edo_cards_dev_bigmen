--Shadows of the First Velgearian
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

		bRush.addrules()(e,tp,eg,ep,ev,re,r,rp)

        local e0=Effect.CreateEffect(e:GetHandler())
		e0:SetType(EFFECT_TYPE_FIELD)
		e0:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
		e0:SetTargetRange(LOCATION_MZONE,0)
		e0:SetTarget(function(_,c)  return s.funondarknesslowfilter(c) end)
		e0:SetValue(s.fuslimit)
		Duel.RegisterEffect(e0,tp)

        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetCode(EFFECT_EXTRA_ATTACK)
        e2:SetTargetRange(LOCATION_MZONE,0)
        e2:SetTarget(function(_,c)  return s.propersummondynabasefilter(c) end)
        e2:SetValue(2)
		Duel.RegisterEffect(e2,tp)


        local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e5:SetCode(EVENT_PHASE+PHASE_END)
		e5:SetCondition(s.epcon)
		e5:SetOperation(s.epop)
        e5:SetCountLimit(1)
		Duel.RegisterEffect(e5,tp)

        local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e4:SetProperty(EFFECT_FLAG_DELAY)
		e4:SetCode(EVENT_TO_HAND)
		e4:SetCondition(s.scon0)
		e4:SetOperation(s.sop0)
		Duel.RegisterEffect(e4,tp)


	end
	e:SetLabel(1)
end
function s.notownedfilter(c)
    return (c:GetFlagEffect(id)>0) and (c:GetControler()~=c:GetOwner())
end
function s.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_DECK) and not c:IsReason(REASON_DRAW)
end
function s.scon0(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp)
		and Duel.GetMatchingGroupCount(s.notownedfilter, 1-tp, LOCATION_DECK, 0, nil)>0
end

function s.sop0(e,tp,eg,ep,ev,re,r,rp)
    local chance=Duel.GetFlagEffect(tp, id+6)
    local triggered=false

    if chance==0 then
        local num=Duel.GetRandomNumber(0,100)
        if num<25 then
            triggered=true
        end
        
    elseif chance==1 then
        local num=Duel.GetRandomNumber(0,100)
        if num<50 then
            triggered=true
        end
    
    elseif chance>1 then
        triggered=true
    end

    if triggered then
        Duel.Hint(HINT_CARD, tp, id)
        local lildark=Duel.GetFirstMatchingCard(s.notownedfilter, 1-tp, LOCATION_DECK, 0, nil)
        Duel.MoveSequence(lildark,0)
        Duel.Draw(1-tp, 1, REASON_RULE)

    end

	Duel.RegisterFlagEffect(tp,id+6,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


function s.lowleveldarknessfilter(c)
    return c:IsLevelBelow(2) and c:IsCTDarkness() and c:IsAbleToDeck()
end

function s.epcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.IsExistingMatchingCard(s.lowleveldarknessfilter, tp, LOCATION_GRAVE, 0, 1, nil) and Duel.GetTurnPlayer()==tp
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) end
end

function s.validfusionfilter(c,e,tp)


    return c:IsType(TYPE_FUSION) and c:ListsCodeAsMaterial(e:GetHandler():GetCode()) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_FUSION, 1-tp, false,false,POS_FACEUP)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
        local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
        Duel.ConfirmCards(1-tp,g)
        if Duel.GetLocationCount(1-tp, LOCATION_MZONE)>0 and
             Duel.IsExistingMatchingCard(s.validfusionfilter, tp, 0, LOCATION_EXTRA, 1, nil, e, tp)
             and Duel.IsExistingMatchingCard(Card.IsMonster, tp, LOCATION_MZONE|LOCATION_HAND, 0, 1, c) and Duel.SelectYesNo(1-tp, aux.Stringid(id, 6)) then
            
                Duel.Hint(HINT_SELECTMSG, 1-tp, HINTMSG_TOGRAVE)
                local g2=Duel.SelectMatchingCard(1-tp, Card.IsMonster, tp, LOCATION_HAND|LOCATION_MZONE, 0, 1,1,false, c)
                g2:AddCard(c)

                Duel.SendtoGrave(g2, REASON_EFFECT+REASON_FUSION)
                Duel.Hint(HINT_SELECTMSG, 1-tp, HINTMSG_SPSUMMON)
                local tar=Duel.SelectMatchingCard(1-tp, s.validfusionfilter, tp, 0, LOCATION_EXTRA, 1,1,false,nil,e,tp)
                Duel.SpecialSummon(tar, SUMMON_TYPE_FUSION, 1-tp, 1-tp, false, false, POS_FACEUP)
        else
            Duel.SendtoDeck(c, tp, SEQ_DECKSHUFFLE, REASON_EFFECT)
            Duel.ShuffleDeck(tp)
            Duel.Draw(tp, 2, REASON_EFFECT)
        end
        Duel.ShuffleHand(tp)
    end
end


function s.epop(e,tp,eg,ep,ev,re,r,rp)

	local littledarks=Duel.GetMatchingGroup(s.lowleveldarknessfilter, tp, LOCATION_GRAVE, 0, nil)
	if #littledarks>0 and Duel.SelectYesNo(tp, aux.Stringid(id, 4)) then
        Duel.Hint(HINT_CARD,tp,id)
        sg=aux.SelectUnselectGroup(littledarks,e,tp,1,99,aux.dncheck,1,tp,HINTMSG_TODECK)

        for tc in sg:Iter() do
            local tc2=Duel.CreateToken(tp, tc:GetOriginalCode())

            Duel.SendtoDeck(tc,1-tp,SEQ_DECKSHUFFLE,REASON_EFFECT)
            Duel.SendtoDeck(tc2,1-tp,SEQ_DECKSHUFFLE,REASON_EFFECT)

            


            if tc:GetFlagEffect(id)==0 then
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
                e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
                e1:SetCode(EVENT_TO_HAND)
                e1:SetTarget(s.sptg)
                e1:SetOperation(s.spop)
                tc:RegisterEffect(e1)
                tc:RegisterFlagEffect(id, 0,0,0)
            end
            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
            e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
            e2:SetCode(EVENT_TO_HAND)
            e2:SetTarget(s.sptg)
            e2:SetOperation(s.spop)
            tc2:RegisterEffect(e2)
            tc2:RegisterFlagEffect(id, 0,0,0)


        

        end
		
	end
end

function s.propersummondynabasefilter(c)
    if not c:IsCode(160016041) then return false end
    local g=c:GetMaterial()
    return Group.FilterCount(g, Card.IsLevelAbove, nil, 5)==3
end

function s.fuslimit(e,c)
	if not c then return false end
	return c:IsLevel(9)
end


function s.funondarknesslowfilter(c)
    return c:IsFaceup() and c:IsLevelBelow(4) and not c:IsCTDarkness()
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

function s.fusionfilter(c)
    return c:IsType(TYPE_FUSION) and not c:IsCode(160016041)
end

function s.notctfusmat(c)
    return not c:IsCTDarkness()
end

function s.ctfusmat(c)
    return c:IsCTDarkness()
end


function s.startofdueleff(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.fusionfilter, tp, LOCATION_EXTRA, 0, nil)
    for tc in g:Iter() do
        Fusion.AddProcMix(tc,true,true,s.notctfusmat,s.ctfusmat)
    end

end

function s.normaldarknesstributefilter(c)
    return c:IsType(TYPE_NORMAL) and c:IsCTDarkness() and c:IsReleasableByEffect()
end

function s.addnondarknessmonsterfilter(c)
    return c:IsLevel(7) and c:IsAbleToHand() and not c:IsCTDarkness()
end

function s.transamuaddfilter(c)
    return c:IsCode(160015004) and c:IsAbleToHand()
end

function s.fusionaddfilter(c)
    return c:IsCode(CARD_FUSION) and c:IsAbleToHand()
end

function s.tributetyrantfilter(c)
    return c:IsCode(160016018) and c:IsReleasableByEffect()
end

function s.nesstrydertankfilter(c,e,tp)
    return c:IsCode(160016017) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPECIAL, tp, false,false,POS_FACEUP)
end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0  then return end
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.normaldarknesstributefilter,tp,LOCATION_MZONE,0,1,nil)
                        and Duel.IsPlayerCanDiscardDeck(tp, 3)
						and ( (Duel.GetFlagEffect(tp, id+3)==0 and Duel.IsExistingMatchingCard(s.addnondarknessmonsterfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil))
                        or (Duel.GetFlagEffect(tp, id+4)==0 and Duel.IsExistingMatchingCard(s.transamuaddfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil))
                        or (Duel.GetFlagEffect(tp, id+5)==0 and Duel.IsExistingMatchingCard(s.fusionaddfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)))

	local b2=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.tributetyrantfilter,tp,LOCATION_MZONE,0,1,nil)
            and Duel.IsExistingMatchingCard(s.nesstrydertankfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp)


	return aux.CanActivateSkill(tp) and (b1 or b2)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)

	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.normaldarknesstributefilter,tp,LOCATION_MZONE,0,1,nil)
                         and Duel.IsPlayerCanDiscardDeck(tp, 3)
						and ( (Duel.GetFlagEffect(tp, id+3)==0 and Duel.IsExistingMatchingCard(s.addnondarknessmonsterfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil))
                        or (Duel.GetFlagEffect(tp, id+4)==0 and Duel.IsExistingMatchingCard(s.transamuaddfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil))
                        or (Duel.GetFlagEffect(tp, id+5)==0 and Duel.IsExistingMatchingCard(s.fusionaddfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)))

	local b2=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.tributetyrantfilter,tp,LOCATION_MZONE,0,1,nil)
            and Duel.IsExistingMatchingCard(s.nesstrydertankfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp)
	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,5)},
								  {b2,aux.Stringid(id,3)})
	op=op-1

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	end
end



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
    local b1=Duel.GetFlagEffect(tp, id+3)==0 and Duel.IsExistingMatchingCard(s.addnondarknessmonsterfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
    local b2=Duel.GetFlagEffect(tp, id+4)==0 and Duel.IsExistingMatchingCard(s.transamuaddfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
    local b3=Duel.GetFlagEffect(tp, id+5)==0 and Duel.IsExistingMatchingCard(s.fusionaddfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)

    local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
								  {b2,aux.Stringid(id,1)},
								  {b3,aux.Stringid(id,2)})
	op=op-1

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
    local lildark=Duel.SelectMatchingCard(tp, s.normaldarknesstributefilter, tp, LOCATION_MZONE, 0, 1,1,false,nil)
    Duel.Release(lildark, REASON_RULE)
    Duel.DiscardDeck(tp, 3, REASON_RULE)
	if op==0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local nondarkadd=Duel.SelectMatchingCard(tp, s.addnondarknessmonsterfilter, tp, LOCATION_DECK|LOCATION_GRAVE, 0, 1,1,false,nil)
        Duel.SendtoHand(nondarkadd, tp, REASON_RULE)
        Duel.ConfirmCards(1-tp, nondarkadd)
    


        Duel.RegisterFlagEffect(tp,id+3,0,0,0)
	elseif op==1 then

        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local transamu=Duel.SelectMatchingCard(tp, s.transamuaddfilter, tp, LOCATION_DECK|LOCATION_GRAVE, 0, 1,1,false,nil)
        Duel.SendtoHand(transamu, tp, REASON_RULE)
        Duel.ConfirmCards(1-tp, transamu)

        Duel.RegisterFlagEffect(tp,id+4,0,0,0)
    elseif op==2 then

        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local fusion=Duel.SelectMatchingCard(tp, s.fusionaddfilter, tp, LOCATION_DECK|LOCATION_GRAVE, 0, 1,1,false,nil)
        Duel.SendtoHand(fusion, tp, REASON_RULE)
        Duel.ConfirmCards(1-tp, fusion)

        Duel.RegisterFlagEffect(tp,id+5,0,0,0)
    end


	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
    local tyrant=Duel.SelectMatchingCard(tp, s.tributetyrantfilter, tp, LOCATION_MZONE, 0, 1,1,false,nil)
    Duel.Release(tyrant, REASON_RULE)

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local tank=Duel.SelectMatchingCard(tp, s.nesstrydertankfilter, tp, LOCATION_HAND|LOCATION_GRAVE, 0, 1,1,false,nil,e,tp)
    Duel.SpecialSummon(tank, SUMMON_TYPE_SPECIAL, tp,tp, false,false, POS_FACEUP)



	Duel.RegisterFlagEffect(tp,id+2,0,0,0)
end
