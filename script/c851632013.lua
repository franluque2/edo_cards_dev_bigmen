--Triple Tactics Treaty
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    --activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
    e1:SetCategory(CATEGORY_CONJURE)
    e1:SetOperation(s.adop)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)

    aux.GlobalCheck(s,function()

		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_STARTUP)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
	
end

s.GenCards={[0]={},[1]={}}


local disruptioncards={14087893,35480699,31834488,19739265,25789292,3259760,14602126,19230407,97120394,51706604,54261514,88369727}
local extensioncards={43422537,1845204,11481610,35261759,58577036,83764719,28958464,84211599,9622164}
local removalcards={9322133,2263869,89801755,15735108,24081957,42598242,25955749,99550630,18591904,43898403,8267140}

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    for i = 0, 1, 1 do
        for j = 1, 3, 1 do
            s.GenCards[i][j]=Group.CreateGroup()
            s.GenCards[i][j]:KeepAlive()
        end
        for index, value in ipairs(removalcards) do
            local token=Duel.CreateToken(i, value)
            Group.AddCard(s.GenCards[i][1], token)
        end

        for index, value in ipairs(disruptioncards) do
            local token=Duel.CreateToken(i, value)
            Group.AddCard(s.GenCards[i][2], token)
        end

        for index, value in ipairs(extensioncards) do
            local token=Duel.CreateToken(i, value)
            Group.AddCard(s.GenCards[i][3], token)
        end
    end
    e:Reset()

end

function s.chainfilter(re,tp,cid)
	return not (re:IsActiveType(TYPE_MONSTER) and Duel.IsMainPhase())
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)~=0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
	local op=Duel.SelectEffect(tp,
		{true, aux.Stringid(id,0)},
		{true, aux.Stringid(id,1)},
		{true, aux.Stringid(id,2)})
	e:SetLabel(op)
end

function s.adop(e,tp,eg,ep,ev,re,r,rp)
    local num=e:GetLabel()

    local num1=Duel.GetRandomNumber(1, #s.GenCards[tp][num] )
    local num2=Duel.GetRandomNumber(1, #s.GenCards[tp][num] )
    while num2==num1 do
        num2=Duel.GetRandomNumber(1, #s.GenCards[tp][num] )
    end
    local num3=Duel.GetRandomNumber(1, #s.GenCards[tp][num] )
    while num3==num2 or num3==num1 do
        num3=Duel.GetRandomNumber(1, #s.GenCards[tp][num] )
    end

    num1,num2,num3=num1-1,num2-1,num3-1

    local tc1=Group.TakeatPos(s.GenCards[tp][num], num1)
    local tc2=Group.TakeatPos(s.GenCards[tp][num], num2)
    local tc3=Group.TakeatPos(s.GenCards[tp][num], num3)

    local sel=Group.FromCards(tc1,tc2,tc3)

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local tc=sel:Select(tp, 1,1,nil):GetFirst()
    if tc then
        local token=Duel.CreateToken(tp, tc:GetOriginalCode())
        Duel.SendtoHand(token, tp, REASON_EFFECT)
        Duel.ConfirmCards(1-tp, token)
    end

end