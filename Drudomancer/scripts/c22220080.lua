-- Drudomancer Spirit Journey
local s,id,o=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Search a Drudomancer monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Use an opponent's monster as Tribute for a revealed Drudomancer monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_RELEASE_SUM)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.relcon)
	c:RegisterEffect(e2)
	--The monster being Tribute Summoned must itself be a revealed Drudomancer
	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_FIELD)
	e2b:SetCode(EFFECT_UNRELEASABLE_SUM)
	e2b:SetRange(LOCATION_SZONE)
	e2b:SetTargetRange(0,LOCATION_MZONE)
	e2b:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2b:SetValue(s.sumlimit)
	c:RegisterEffect(e2b)
	--Return both monsters to the hand after an Illusion monster battled
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.retcon)
	e3:SetTarget(s.rettg)
	e3:SetOperation(s.retop)
	c:RegisterEffect(e3)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end
function s.thfilter(c)
	return c:IsSetCard(0xdad) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.pubfilter(c)
	return c:IsPublic() and c:IsSetCard(0xdad) and c:IsType(TYPE_MONSTER)
end
function s.relcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.pubfilter,tp,LOCATION_HAND,0,1,nil)
end
function s.sumlimit(e,c)
	return not (c:IsLocation(LOCATION_HAND) and c:IsPublic()
		and c:IsSetCard(0xdad) and c:IsType(TYPE_MONSTER))
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return a and d and ((a:IsControler(tp) and a:IsRace(RACE_ILLUSION))
		or (d:IsControler(tp) and d:IsRace(RACE_ILLUSION)))
end
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if chk==0 then return a and d and a:IsAbleToHand() and d:IsAbleToHand() end
	local g=Group.FromCards(a,d)
	e:SetLabelObject(g)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g then return end
	g=g:Filter(Card.IsRelateToBattle,nil)
	if #g==2 then Duel.SendtoHand(g,nil,REASON_EFFECT) end
end

--[[
During your Main Phase: You can add 1 "Drudomancer" monster from your Deck to
your hand. You can only use this effect of "Drudomancer Spirit Journey" once
per turn. Once per turn, if you would Tribute a monster for the Tribute Summon
of a revealed "Drudomancer" monster, you can Tribute 1 monster your opponent
controls even though you do not control it. At the end of the Damage Step, if
an Illusion monster you control battled a monster: You can return both monsters
to the hand.
]]
