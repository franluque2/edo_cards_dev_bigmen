--Battle Constant (CT)

	-- While this card is in your GY, except the turn it was sent there: You can banish this card from your GY,
	-- 		then target 3 of your banished cards, except "Battle Constant"; Shuffle those targets into the Deck, and if you do, draw 1 card.
	-- 			You can only use one effect of "Battle Constant" once per turn, and only once that turn.


    local s,id=GetID()
    function s.initial_effect(c)
        --Activate
    
        -- Banish 1 Monster Card, Continuous Spell Card, and Continuous Trap Card from your field and/or GY;
        --  Special Summon 1 "Brain Dragon" from your Hand or Deck,
    
        local e1=Effect.CreateEffect(c)
        e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
        e1:SetType(EFFECT_TYPE_ACTIVATE)
        e1:SetCode(EVENT_FREE_CHAIN)
        e1:SetCountLimit(1,{id,2})
        e1:SetCost(s.cost)
        e1:SetTarget(s.target)
        e1:SetOperation(s.activate)
        c:RegisterEffect(e1)
    
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_IGNITION)
        e2:SetRange(LOCATION_GRAVE)
        e2:SetCountLimit(1,{id,0})
        e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
        e2:SetCondition(aux.exccon)
        e2:SetCost(aux.bfgcost)
        e2:SetTarget(s.rettg)
        e2:SetOperation(s.retop)
        c:RegisterEffect(e2)

        
	    local e3=Effect.CreateEffect(c)
	    e3:SetDescription(aux.Stringid(id,1))
	    e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	    e3:SetProperty(EFFECT_FLAG_DELAY)
	    e3:SetCode(EVENT_TO_GRAVE)
	    e3:SetCountLimit(1,{id,1})
	    e3:SetCondition(s.thcon2)
	    e3:SetTarget(s.thtg2)
	    e3:SetOperation(s.thop2)
	    c:RegisterEffect(e3)
    
    end
    s.listed_names={511001235}
    function s.cfilter(c,tpe)
        return c:IsFaceup() and c:GetType()&tpe==tpe and c:IsAbleToRemoveAsCost()
    end
    
    function s.cfilter2(c,tar)
        return c:IsAbleToDeck() and not c:IsCode(tar:GetCode())
    end
    
    function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
        if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) end
        if chk==0 then return Duel.IsExistingTarget(s.cfilter2,tp,LOCATION_REMOVED,0,1,nil,e:GetHandler()) end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local g=Duel.SelectTarget(tp,s.cfilter2,tp,LOCATION_REMOVED,0,1,3,nil,e:GetHandler())
        Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
    end
    
    function s.retop(e,tp,eg,ep,ev,re,r,rp)
        local g=Duel.GetTargetCards(e)
        if #g>0 then
            if Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT) then
                Duel.ShuffleDeck(tp)
                Duel.Draw(tp, 1, REASON_EFFECT)
            end
        end
    end
    
    
    
    function s.rescon(sg,e,tp,mg)
        return aux.ChkfMMZ(1)(sg,e,tp,mg) and sg:IsExists(s.chk,1,nil,sg,Group.CreateGroup(),TYPE_MONSTER,TYPE_SPELL+TYPE_CONTINUOUS,TYPE_TRAP+TYPE_CONTINUOUS)
    end
    function s.chk(c,sg,g,tpe,...)
        if c:GetType()&tpe~=tpe then return false end
        local res
        if ... then
            g:AddCard(c)
            res=sg:IsExists(s.chk,1,g,sg,g,...)
            g:RemoveCard(c)
        else
            res=true
        end
        return res
    end
    function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
        local g1=Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
        local g2=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil,TYPE_SPELL+TYPE_CONTINUOUS)
        local g3=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil,TYPE_TRAP+TYPE_CONTINUOUS)
        local g=g1:Clone()
        g:Merge(g2)
        g:Merge(g3)
        if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-3 and #g1>0 and #g2>0 and #g3>0
            and aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,0) end
        local sg=aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,1,tp,HINTMSG_REMOVE)
        Duel.Remove(sg,POS_FACEUP,REASON_COST)
    end
    function s.filter(c,e,tp)
        return c:IsCode(511001235, 72880377) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
    end
    function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
        if chk==0 then
            if e:GetLabel()==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
            e:SetLabel(0)
            return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
        end
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
        Duel.IsExistingMatchingCard(s.relavfieldfilter, tp, LOCATION_FZONE, 0, 1, nil)
    end
    
    --then if you control "Relativity Field", all "Brain Dragon" you control
    -- 	  gain 1000 ATK.
    
    function s.relavfieldfilter(c)
        return c:IsCode(511000479) and c:IsFaceup()
    end
    
    function s.bdragonfilter(c)
        return c:IsRace(RACE_DRAGON) and c:IsFaceup()
    end
    
    function s.activate(e,tp,eg,ep,ev,re,r,rp)
        if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
        Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
    end
    function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
        return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
    end
    function s.tgfilter(c)
        return (c:IsCode(53129443, 72880377) or ((c:IsType(TYPE_CONTINUOUS) and c:IsSpellTrap()) and not c:IsType(TYPE_FIELD)) and c:IsAbleToGrave())
    end
    function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
        if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
        Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
    end
    function s.thop2(e,tp,eg,ep,ev,re,r,rp)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.SendtoGrave(g,REASON_EFFECT)
                    Duel.SSet(tp,c)
                    -- Banish it if it leaves the field
                    local e1=Effect.CreateEffect(c)
                    e1:SetDescription(3300)
                    e1:SetType(EFFECT_TYPE_SINGLE)
                    e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
                    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
                    e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
                    e1:SetValue(LOCATION_REMOVED)
                    c:RegisterEffect(e1)
        end
    end