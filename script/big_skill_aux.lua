if not BSkillaux then
    BSkillaux = {}
end



BSkillaux.CreateBasicSkill = (function()
    return function(c, id, flipconpassive, flipoppassive, flippassiveevent, flipconactive, flipopactive, major, minorskillstring)
        local function op(e, tp, eg, ep, ev, re, r, rp)
            if e:GetLabel() == 0 then
                Duel.DisableShuffleCheck()
                Duel.Hint(HINT_CARD, tp, id)
                Duel.SendtoDeck(e:GetHandler(), tp, -2, REASON_EFFECT)
                if e:GetHandler():GetPreviousLocation() == LOCATION_HAND then
                    Duel.Draw(tp, 1, REASON_EFFECT)
                end
                if major then
                    Duel.Hint(HINT_SKILL_COVER, tp, id|(300000000 << 32))
                end

                if flipconpassive and flipoppassive then
                    local e1 = Effect.CreateEffect(e:GetHandler())
                    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
                    e1:SetCode(flippassiveevent or EVENT_ADJUST)
                    e1:SetCountLimit(1,{id,99})
                    e1:SetCondition(flipconpassive)
                    e1:SetOperation(flipoppassive)
                    Duel.RegisterEffect(e1, tp)

                    if not flippassiveevent then
                        local e2=e1:Clone()
                        e2:SetCode(EVENT_STARTUP)
                        Duel.RegisterEffect(e2, tp)
                    end

                else
                    if major then
                        Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
                    else
                        if minorskillstring then
                            aux.RegisterClientHint(e:GetHandler(), nil, tp, 1, 0, minorskillstring, nil)
                        end
                    end
                end

                if flipconactive and flipopactive then
                    local e1 = Effect.CreateEffect(e:GetHandler())
                    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
                    e1:SetCode(EVENT_FREE_CHAIN)
                    e1:SetCondition(flipconactive)
                    e1:SetOperation(flipopactive)
                    Duel.RegisterEffect(e1, tp)
                end
            end
            e:SetLabel(1)
        end

        local e1 = Effect.CreateEffect(c)
        e1:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_STARTUP)
        e1:SetCountLimit(1, {id, 98})
        e1:SetLabel(0)
        e1:SetRange(LOCATION_ALL)
        e1:SetOperation(op)

        local e2=e1:Clone()
        e2:SetCode(EVENT_ADJUST)

        return e1, e2
    end
end
)()

if not BSkillaux.RushProcedure then
	BSkillaux.RushProcedure = {}
	BRush = BSkillaux.RushProcedure
end
if not BRush then
	BRush = BSkillaux.RushProcedure
end

function BRush.addrules()
  return function(e,tp,eg,ep,ev,re,r,rp)
    --Disable left and right-most zones
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_DISABLE_FIELD)
    e2:SetOperation(BRush.disabledzones)
    Duel.RegisterEffect(e2,tp)

    --Draw till you have 5 cards in hand
    local e3=Effect.CreateEffect(e:GetHandler())
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_DRAW_COUNT)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetTargetRange(1,0)
    e3:SetValue(BRush.getcarddraw)
    Duel.RegisterEffect(e3,tp)

    --Give almost infinite normal summons
    local e4=Effect.CreateEffect(e:GetHandler())
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_SET_SUMMON_COUNT_LIMIT)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e4:SetTargetRange(1,0)
    e4:SetValue(999999999)
    Duel.RegisterEffect(e4,tp)

    --skip MP2

    local e5=Effect.CreateEffect(e:GetHandler())
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e5:SetCode(EFFECT_SKIP_M2)
    e5:SetTargetRange(1,0)
    Duel.RegisterEffect(e5,tp)

    --skip SP

    --local e7=Effect.CreateEffect(e:GetHandler())
    --e7:SetType(EFFECT_TYPE_FIELD)
    --e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    --e7:SetCode(EFFECT_SKIP_SP)
    --e7:SetTargetRange(1,0)
    --Duel.RegisterEffect(e7,tp)

    --disable EMZs
    local e6=Effect.CreateEffect(e:GetHandler())
    e6:SetType(EFFECT_TYPE_FIELD)
    e6:SetCode(EFFECT_FORCE_MZONE)
    e6:SetRange(LOCATION_MZONE)
    e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
    e6:SetTargetRange(1,0)
    e6:SetValue(BRush.znval)
    Duel.RegisterEffect(e6,tp)

    --give infinite hand size
    local e7=Effect.CreateEffect(e:GetHandler())
    e7:SetType(EFFECT_TYPE_FIELD)
    e7:SetCode(EFFECT_HAND_LIMIT)
    e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e7:SetTargetRange(1,0)
    e7:SetValue(100)
    Duel.RegisterEffect(e7,tp)
  end
end


function BRush.getcarddraw(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0) < 5 then
		return 5-Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)
	else
		return 1
end
end

function BRush.znval(e)
	return ~(0x60)
end


function BRush.disabledzones(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandlerPlayer()==tp then
			return 0x00001111
	else
			return 0x11110000
	end
end
