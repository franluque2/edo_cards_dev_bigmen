--Healthstone
local s,id=GetID()
function s.initial_effect(c)
	
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)

    aux.GlobalCheck(s,function()
        s[0]=0
        s[1]=0
        local ge1=Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
        ge1:SetCode(EVENT_DAMAGE)
        ge1:SetOperation(s.checkop)
        Duel.RegisterEffect(ge1,0)

        local ge2=Effect.CreateEffect(c)
			ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			ge2:SetCode(EVENT_ADJUST)
			ge2:SetCountLimit(1)
			ge2:SetOperation(s.clear)
			Duel.RegisterEffect(ge2,0)
    end)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0)==0
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local e0=Duel.IsPlayerCanDraw(tp,1) and not Duel.HasFlagEffect(tp,id+1)
    local e1=s[tp]>0 and not Duel.HasFlagEffect(tp,id)
	if chk==0 then return e0 or e1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
	local op=Duel.SelectEffect(tp,{e0,aux.Stringid(id,0)},{e1,aux.Stringid(id,1)})
	e:SetLabel(op)
	if op==2 then
		e:SetCategory(CATEGORY_RECOVER)
		Duel.SetTargetPlayer(tp)
		Duel.SetTargetParam(s[tp])
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,s[tp])
        Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	else
		e:SetCategory(CATEGORY_DRAW)
		Duel.SetTargetPlayer(tp)
		Duel.SetTargetParam(1)
        Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
        Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if e:GetLabel()==2 then
        if d>8000 then d=8000 end
		Duel.Recover(p,d,REASON_EFFECT)
	else 
        Duel.Draw(p, d, REASON_EFFECT)
        local c=e:GetHandler()
        if c:IsRelateToEffect(e) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
            if c:IsHasEffect(EFFECT_CANNOT_TO_DECK) then return end
            c:CancelToGrave()
            Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        end
    end
end



function s.clear(e,tp,eg,ep,ev,re,r,rp)
    s[0]=0
    s[1]=0
end


function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    s[ep]=s[ep]+ev
end