-- Fabled Andwrailswarm
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x35),1,1,Synchro.NonTuner(nil),1,99)
	--If this card is Synchro Summoned: during the End Phase, add up to 2 "Fabled" cards from your GY to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Once per turn, when your opponent activates a Spell/Trap Card or effect (Quick Effect): discard 2; negate, destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.negcon)
	e2:SetCost(s.negcost)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
	--If this card is in your GY: target 1 other "Fabled" monster in your GY; return this to Extra; Special Summon it
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOEXTRA)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)

end

s.listed_series={0x35}

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.thfilter(c)
	return c:IsSetCard(0x35) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,nil) end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetLabel(tp)
	e1:SetTarget(s.epthtg)
	e1:SetOperation(s.epthop)
	Duel.RegisterEffect(e1,tp)
end
function s.epthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local p=e:GetLabel()
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),p,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,p,LOCATION_GRAVE)
end
function s.epthop(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(p,aux.NecroValleyFilter(s.thfilter),p,LOCATION_GRAVE,0,1,2,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-p,g)
		Duel.ShuffleHand(p)
	end
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp then return false end
	if not Duel.IsChainNegatable(ev) then return false end
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,2,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,2,2,REASON_COST+REASON_DISCARD)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(0x35) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc~=c and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsAbleToExtra()
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,c,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,c,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_EXTRA)
		and tc and tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

--[[
1 "Fabled" Tuner + 1+ non-Tuner monsters
If this card is Synchro Summoned: You can activate this effect; during the End Phase of this turn, add up to 2 "Fabled" cards from your GY to your hand.
Once per turn, when your opponent activates a Spell/Trap Card or effect (Quick Effect): You can discard 2 cards, and if you do, negate the activation, and if you do that, destroy it.
If this card is in your GY: You can target 1 other "Fabled" monster in your GY; return this card to the Extra Deck, and if you do, Special Summon that target.
You can only use this effect of "Fabled Andwrailswarm" once per turn.
]]