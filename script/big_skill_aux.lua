if not BSkillaux then
    BSkillaux = {}
end



BSkillaux.CreateBasicSkill = (function()
    return function(c, id, flipconpassive, flipoppassive, flippassiveevent, flipconactive, flipopactive, major, minorskillstring)
        local function op(e, tp, eg, ep, ev, re, r, rp)
            if e:GetLabel() == 0 then
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
