--Iron Chain Warden
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	--Synchro Summon procedure
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(Card.IsAttribute,ATTRIBUTE_EARTH),1,99)

    --Cannot be Destroyed by Battle
    
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)

    -- Monsters must attack, if able, and can attack twice during each Battle Phase.

    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCode(EFFECT_MUST_ATTACK)
	c:RegisterEffect(e2)

    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(1)
	c:RegisterEffect(e1)

    --If a player would take Battle Damage, send the top 2 cards of your opponent's deck to the GY, instead.
    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e4:SetTargetRange(1,1)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(s.value)
	c:RegisterEffect(e4)
end


function s.value(e)
        local damp=0
        if Duel.GetBattleDamage(0)==0 then
            damp=1
        end
		local val=Duel.GetBattleDamage(damp)
		if (val>0) and (Duel.GetFieldGroupCount(1-e:GetOwnerPlayer(), LOCATION_DECK,0)>1) then
			if Duel.GetFlagEffect(damp, id)==0 then
			Duel.RegisterFlagEffect(damp, id, RESET_PHASE+PHASE_DAMAGE, 0, 0)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_ADJUST)
			e1:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
			e1:SetLabel(2)
			e1:SetOperation(s.millop)
			Duel.RegisterEffect(e1,damp)
		end
		return 0

		else
            return -1

        end

end


function s.millop(e,tp,eg,ep,ev,re,r,rp)
	local val=e:GetLabel()
	if val>0 then
		e:SetLabel(0)
		Duel.DiscardDeck(tp, val, REASON_EFFECT)
		e:Reset()

	end
end
