--Santa Claws Comes to Town!
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

end



function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)





	end
	e:SetLabel(1)
end

local ChristmasPresentIds={81632309,81632310,81632311,81632312,81632313,
                            81632314,81632315,81632316,81632317,81632318}

local ChristmasPresents={}
ChristmasPresents[0]={}
ChristmasPresents[1]={}


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,0),nil)

	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id-1000)<2
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.SendtoDeck(e:GetHandler(), tp, -2, REASON_EFFECT)
    Duel.RegisterFlagEffect(tp,id-1000,0,0,0)
    Duel.RegisterFlagEffect(1-tp,id-1000,0,0,0)

	if e:GetHandler():GetPreviousLocation()==LOCATION_HAND then
		Duel.Draw(tp, 1, REASON_EFFECT)
	end

    if Duel.GetFlagEffect(tp, id-1000)==1 then

        local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_DRAW)
		e1:SetCondition(s.flipcon2)
		e1:SetOperation(s.flipop2)
		Duel.RegisterEffect(e1,tp)


        local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
		e2:SetCondition(s.flipcon3)
		e2:SetOperation(s.flipop3)
		Duel.RegisterEffect(e2,tp)

        s.GeneratePresents()

    end
end

function s.GeneratePresents()

    for i = 0, 1, 1 do

        for key,value in ipairs(ChristmasPresentIds) do

            local newcard=Duel.CreateToken(i, value)

            table.insert(ChristmasPresents[i],newcard)

        end

    end

end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetFlagEffect(ep, id-1000+1)==0
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)

        Duel.Hint(HINT_CARD,tp,id)

        local g=Group.CreateGroup()

        local numbers={}

        numbers[1]=Duel.GetRandomNumber(1,#ChristmasPresents[ep])
        numbers[2]=Duel.GetRandomNumber(1,#ChristmasPresents[ep])
        while numbers[2]==numbers[1] do

            numbers[2]=Duel.GetRandomNumber(1,#ChristmasPresents[ep])
        end
        numbers[3]=Duel.GetRandomNumber(1,#ChristmasPresents[ep])

        while numbers[3]==numbers[2] or numbers[3]==numbers[1] do

            numbers[3]=Duel.GetRandomNumber(1,#ChristmasPresents[ep])
        end
        --numbers[4]=Duel.GetRandomNumber(1,#ChristmasPresents[ep])

        --while numbers[4]==numbers[3] or numbers[4]==numbers[2] or numbers[4]==numbers[1] do

          --  numbers[4]=Duel.GetRandomNumber(1,#ChristmasPresents[ep])
        --end
        --numbers[5]=Duel.GetRandomNumber(1,#ChristmasPresents[ep])

        --while numbers[5]==numbers[4] or numbers[5]==numbers[3] or numbers[5]==numbers[2] or numbers[5]==numbers[1] do

          --  numbers[5]=Duel.GetRandomNumber(1,#ChristmasPresents[ep])
        --end

        g:AddCard(ChristmasPresents[ep][numbers[1]])
        g:AddCard(ChristmasPresents[ep][numbers[2]])
        g:AddCard(ChristmasPresents[ep][numbers[3]])
        --g:AddCard(ChristmasPresents[ep][numbers[4]])
        --g:AddCard(ChristmasPresents[ep][numbers[5]])

        local g2=aux.SelectUnselectGroup(g, e, ep, 2, 2, nil, 1, ep, HINTMSG_CONFIRM, nil, nil,false)

        if g2 then
			Duel.DisableShuffleCheck(true)
			
			Duel.SendtoDeck(g2, ep, SEQ_DECKBOTTOM, REASON_RULE)

			Duel.ConfirmCards(1-ep,g2)
            Duel.Hint(HINT_SELECTMSG, 1-ep, HINTMSG_ATOHAND)
            local tc=g2:Select(1-ep, 1, 1,nil)
            if tc then
                local card=Duel.CreateToken(ep, tc:GetFirst():GetOriginalCode())
                Duel.SendtoHand(card, ep, REASON_RULE)

                local card2=Duel.CreateToken(1-ep, tc:GetFirst():GetOriginalCode())
                Duel.SendtoHand(card2, 1-ep, REASON_RULE)

            end

			Duel.SendtoDeck(g2, ep, -2, REASON_RULE)

			Duel.DisableShuffleCheck(false)


        end

        Duel.RegisterFlagEffect(ep,id-1000+1,RESET_PHASE+PHASE_END,0,0)
end


function s.flipcon3(e,tp,eg,ep,ev,re,r,rp)
    local num=Duel.GetRandomNumber(1,10)
	return Duel.GetCurrentChain()==0 and Duel.GetFlagEffect(tp, id-1000+2)==0 and num<2 and Duel.GetLocationCount(ep, LOCATION_MZONE)>0
        and Duel.GetLocationCount(ep, LOCATION_SZONE)>0 and Duel.GetLocationCount(1-ep, LOCATION_SZONE)>0
end
function s.flipop3(e,tp,eg,ep,ev,re,r,rp)

        Duel.Hint(HINT_CARD,tp,id)

        local sclaws=Duel.CreateToken(ep, 46565218)
        Duel.SpecialSummon(sclaws, SUMMON_TYPE_SPECIAL, ep, ep, false, false, POS_FACEUP_DEFENSE)
        Duel.Hint(HINT_OPSELECTED,tp,aux.Stringid(id, 1))
        Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id, 1))



        local giftcard1=Duel.CreateToken(ep, 39526584)
        local giftcard2=Duel.CreateToken(1-ep, 39526584)

        Duel.SSet(ep, giftcard1)
        Duel.SSet(1-ep, giftcard2)

        local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		giftcard1:RegisterEffect(e1)
		giftcard2:RegisterEffect(e1)


        s.activatetrap(e,ep,eg,ep,ev,re,r,rp,giftcard1)
        s.activatetrap(e,1-ep,eg,1-ep,ev,re,r,rp,giftcard2)

        Duel.SendtoDeck(giftcard1, ep, -2, REASON_RULE)
        Duel.SendtoDeck(giftcard2, 1-ep, -2, REASON_RULE)

        Duel.SendtoDeck(sclaws, ep, -2, REASON_RULE)


        Duel.RegisterFlagEffect(tp,id-1000+2,0,0,0)
end


function s.activatetrap(e,tp,eg,ep,ev,re,r,rp,card)
    local tc=card
		local tpe=tc:GetType()
		local te=tc:GetActivateEffect()
		local tg=te:GetTarget()
		local co=te:GetCost()
		local op=te:GetOperation()
		e:SetCategory(te:GetCategory())
		e:SetProperty(te:GetProperty())
		Duel.ClearTargetCard()
		Duel.ChangePosition(tc,POS_FACEUP)

		Duel.Hint(HINT_CARD,0,tc:GetCode())
		tc:CreateEffectRelation(te)
		if (tpe&TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD)==0 then
			tc:CancelToGrave(false)
		end
		if te:GetCode()==EVENT_CHAINING then
			local te2=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_EFFECT)
			local tc=te2:GetHandler()
			local g=Group.FromCards(tc)
			local p=tc:GetControler()
			if co then co(te,tp,g,p,chain,te2,REASON_EFFECT,p,1) end
			if tg then tg(te,tp,g,p,chain,te2,REASON_EFFECT,p,1) end
		elseif te:GetCode()==EVENT_FREE_CHAIN then
			if co then co(te,tp,eg,ep,ev,re,r,rp,1) end
			if tg then tg(te,tp,eg,ep,ev,re,r,rp,1) end
		else
			local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(te:GetCode(),true)
			if co then co(te,tp,teg,tep,tev,tre,tr,trp,1) end
			if tg then tg(te,tp,teg,tep,tev,tre,tr,trp,1) end
		end
		Duel.BreakEffect()
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		if g then
			local etc=g:GetFirst()
			while etc do
				etc:CreateEffectRelation(te)
				etc=g:GetNext()
			end
		end
		tc:SetStatus(STATUS_ACTIVATED,true)
		if not tc:IsDisabled() then
			if te:GetCode()==EVENT_CHAINING then
				local te2=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_EFFECT)
				local tc=te2:GetHandler()
				local g=Group.FromCards(tc)
				local p=tc:GetControler()
				if op then op(te,tp,g,p,chain,te2,REASON_EFFECT,p) end
			elseif te:GetCode()==EVENT_FREE_CHAIN then
				if op then op(te,tp,eg,ep,ev,re,r,rp) end
			else
				local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(te:GetCode(),true)
				if op then op(te,tp,teg,tep,tev,tre,tr,trp) end
			end
		else
			--insert negated animation here
		end
		Duel.RaiseEvent(Group.CreateGroup(tc),EVENT_CHAIN_SOLVED,te,0,tp,tp,Duel.GetCurrentChain())
		if g and tc:IsType(TYPE_EQUIP) and not tc:GetEquipTarget() then
			Duel.Equip(tp,tc,g:GetFirst())
		end
		tc:ReleaseEffectRelation(te)
		if etc then
			etc=g:GetFirst()
			while etc do
				etc:ReleaseEffectRelation(te)
				etc=g:GetNext()
			end
		end
end