-- Drudomancer Soul Echo
local s,id,o=GetID()
function s.initial_effect(c)
	--Activate from the hand while a Drudomancer monster is revealed
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e0:SetCondition(s.handcon)
	c:RegisterEffect(e0)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Normal Summon an Illusion monster during the Main Phase
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.nscon)
	e2:SetTarget(s.nstg)
	e2:SetOperation(s.nsop)
	c:RegisterEffect(e2)
	--Illusion monsters inflict piercing battle damage
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_PIERCE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.piertg)
	c:RegisterEffect(e3)
	--Return a high-Level Illusion monster or destroy this card during the End Phase
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.eptg)
	e4:SetOperation(s.epop)
	c:RegisterEffect(e4)
end
function s.pubfilter(c)
	return c:IsPublic() and c:IsSetCard(0xdad) and c:IsType(TYPE_MONSTER)
end
function s.handcon(e)
	return Duel.IsExistingMatchingCard(s.pubfilter,e:GetHandlerPlayer(),LOCATION_HAND,0,1,nil)
end
function s.nscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end
function s.nsfilter(c)
	return c:IsRace(RACE_ILLUSION) and c:IsSummonable(true,nil)
end
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.nsfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
end
function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,s.nsfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	if #g>0 then Duel.Summon(tp,g:GetFirst(),true,nil) end
end
function s.piertg(e,c)
	return c:IsRace(RACE_ILLUSION)
end
function s.retfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ILLUSION) and c:IsLevelAbove(5)
		and c:IsAbleToHand()
end
function s.eptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.epop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local canret=Duel.IsExistingMatchingCard(s.retfilter,tp,LOCATION_MZONE,0,1,nil)
	if canret and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local g=Duel.SelectMatchingCard(tp,s.retfilter,tp,LOCATION_MZONE,0,1,1,nil)
		if #g>0 then Duel.SendtoHand(g,nil,REASON_EFFECT) end
	else
		Duel.Destroy(c,REASON_EFFECT)
	end
end

--[[
During the Main Phase, you can: Immediately after this effect resolves, Normal
Summon 1 Illusion monster. You can only use this effect of "Drudomancer Soul
Echo" once per turn. If your Illusion monster attacks a Defense Position
monster, inflict piercing battle damage to your opponent. Once per turn,
during the End Phase: Return 1 Level 5 or higher Illusion monster you control
to the hand or destroy this card. If a "Drudomancer" monster is revealed in
your hand, you can activate this card from your hand.
]]
