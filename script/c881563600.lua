--The Demon Seed
local s,id=GetID()
function s.initial_effect(c)
	local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e0:SetCode(EVENT_STARTUP)
    e0:SetCountLimit(1)
    e0:SetRange(0x5f)
    e0:SetOperation(s.flipopextra)
    c:RegisterEffect(e0)

    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

    aux.GlobalCheck(s,function()
        s[0]=0
        s[1]=0
        local ge1=Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
        ge1:SetCode(EVENT_DAMAGE)
        ge1:SetCondition(s.checkcon)
        ge1:SetOperation(s.checkop)
        Duel.RegisterEffect(ge1,0)
    end)

end

function s.checkcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==ep and r&REASON_EFFECT==REASON_EFFECT
end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    s[ep]=s[ep]+ev
end
function s.clear()
    s[0]=0
    s[1]=0
end

function s.getimage(tp)
    return id+Duel.GetFlagEffect(tp, id)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0)==0 end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()

    Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))

    local ge2=Effect.CreateEffect(e:GetHandler())
    ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    ge2:SetCode(EVENT_ADJUST)
    ge2:SetCondition(s.gcon)
    ge2:SetOperation(s.nextstepop)
    Duel.RegisterEffect(ge2,tp)
end

function s.gcon(e,tp,eg,ep,ev,re,r,rp)
    return s[tp]>=3000
end

function s.nextstepop(e,tp,eg,ep,ev,re,r,rp)
    s.clear()
	Duel.Hint(HINT_CARD,tp,s.getimage(tp))

    if Duel.GetFlagEffect(tp, id)<2 then
        Duel.Hint(HINT_SKILL_REMOVE,tp,s.getimage(tp))
        Duel.RegisterFlagEffect(tp, id, 0, 0, 1)
        
		Duel.Hint(HINT_SKILL_FLIP,tp,s.getimage(tp)|(1<<32))
		Duel.Hint(HINT_SKILL,tp,s.getimage(tp))

        Duel.Recover(tp, 2000, REASON_EFFECT)
    else
        Duel.Hint(HINT_SKILL_REMOVE,tp,s.getimage(tp))
        local tamsin=Duel.CreateToken(tp, 881563603)
        Duel.SendtoHand(tamsin, tp, REASON_RULE)
        Duel.ConfirmCards(1-tp, tamsin)
    end
end


function s.flipopextra(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c then
		Duel.MoveSequence(c,0)
	end
end