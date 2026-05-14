--B.E.S. Covered Core MK-2
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x1f)
	--Discard 2 (including this card); Special Summon 2 "B.E.S." monsters with different names from your Deck, and place 3 counters on them
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Place 3 counters on this card
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(s.cttg)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--Destruction replacement
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.reptg)
	e4:SetValue(s.repval)
	c:RegisterEffect(e4)
end

function s.costfilter(c)
	return c:IsDiscardable()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(0x15) and c:IsType(TYPE_MONSTER) and not c:IsCode(id)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		return Duel.GetMZoneCount(tp,e:GetHandler())>=2 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
			and g:GetClassCount(Card.GetCode)>=2
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,6,0,0x1f)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if Duel.GetMZoneCount(tp,e:GetHandler())<2 then return end
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	if not sg then return end
	if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local tc=sg:GetFirst()
		while tc do
			if tc:IsCanAddCounter(0x1f,3) then
				tc:AddCounter(0x1f,3)
			end
			tc=sg:GetNext()
		end
	end
end

function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,3,0,0x1f)
end

function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(0x1f,3)
	end
end

function s.repfilter(c,tp)
	return c:IsControler(tp) and c:IsOnField() and c:IsSetCard(0x15) and c:IsType(TYPE_MONSTER)
		and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return eg:IsExists(s.repfilter,1,nil,tp) and c:IsCanRemoveCounter(tp,0x1f,1,REASON_EFFECT)
	end
	if Duel.SelectEffectYesNo(tp,c,96) then
		c:RemoveCounter(tp,0x1f,1,REASON_EFFECT)
		return true
	end
	return false
end

function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
