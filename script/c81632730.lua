--Doodle Beast - Ankylo Raptor
local s,id=GetID()
function s.initial_effect(c)
    Fusion.AddProcMix(c,true,true,81632729,{81632727,s.ffilter})

	
end

s.material={81632729,81632727}
s.listed_names={81632729,81632727}
s.material_setcode={SET_DOODLE_BEAST}
function s.ffilter(c,fc,sumtype,tp)
	return c:IsRace(RACE_DINOSAUR,fc,sumtype,tp)
end