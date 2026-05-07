--Adventure into the Spirit Realm
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)
	local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,
		nil, nil, true, nil)
	c:RegisterEffect(e1)
	c:RegisterEffect(e2)

end
function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.isormentionsafdfilter(c)
    return c:IsCode(CARD_ANCIENT_FAIRY_DRAGON) or c:ListsCode(CARD_ANCIENT_FAIRY_DRAGON)
end

function s.isormentionsadventurerfilter(c)
    return c:IsCode(TOKEN_ADVENTURER) or c:ListsCode(TOKEN_ADVENTURER)
end

function s.isormentionsfairytaleprologuefilter(c)
    return c:IsCode(CARD_FAIRY_TALE_PROLOGUE) or c:ListsCode(CARD_FAIRY_TALE_PROLOGUE)
end


function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
	Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
	s.rewritecards(e, tp)
	Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))

	local c = e:GetHandler()

    local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetCode(EFFECT_ADD_CODE)
        e2:SetTargetRange(LOCATION_MZONE,0)
        e2:SetTarget(function(_,c) return c:IsOriginalCode(TOKEN_ADVENTURER) end)
        e2:SetValue(CARD_ANCIENT_FAIRY_DRAGON)
        Duel.RegisterEffect(e2, tp)
end

function s.rewritecards(c,tp)
local g=Duel.GetMatchingGroup(s.isormentionsafdfilter, tp, LOCATION_ALL, 0, nil)
    local g2=Duel.GetMatchingGroup(s.isormentionsadventurerfilter, tp, LOCATION_ALL, 0, nil)
    local g3=Duel.GetMatchingGroup(s.isormentionsfairytaleprologuefilter, tp, LOCATION_ALL, 0, nil)
    for tc in g:Iter() do
        local metatable=tc:GetMetatable()
        if metatable.listed_names and #metatable.listed_names>0 then
            table.insert(metatable.listed_names,TOKEN_ADVENTURER)
            table.insert(metatable.listed_names,CARD_FAIRY_TALE_PROLOGUE)
        else
            metatable.listed_names={TOKEN_ADVENTURER,CARD_ANCIENT_FAIRY_DRAGON, CARD_FAIRY_TALE_PROLOGUE}
        end
    end

    for tc in g2:Iter() do
        local metatable=tc:GetMetatable()
        if metatable.listed_names and #metatable.listed_names>0 then
            table.insert(metatable.listed_names,CARD_ANCIENT_FAIRY_DRAGON)
            table.insert(metatable.listed_names,CARD_FAIRY_TALE_PROLOGUE)
        else
            metatable.listed_names={TOKEN_ADVENTURER,CARD_ANCIENT_FAIRY_DRAGON, CARD_FAIRY_TALE_PROLOGUE}
        end
    end

    local g3=Duel.GetMatchingGroup(s.isormentionsfairytaleprologuefilter, tp, LOCATION_ALL, 0, nil)
    for tc in g3:Iter() do
        local metatable=tc:GetMetatable()
        if metatable.listed_names and #metatable.listed_names>0 then
            table.insert(metatable.listed_names,TOKEN_ADVENTURER)
            table.insert(metatable.listed_names,CARD_ANCIENT_FAIRY_DRAGON)
        else
            metatable.listed_names={TOKEN_ADVENTURER, CARD_FAIRY_TALE_PROLOGUE, CARD_ANCIENT_FAIRY_DRAGON}
        end
    end
end