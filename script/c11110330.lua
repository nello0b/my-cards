-- Garden of Blue Tears
local s,id,o=GetID()
function s.initial_effect(c)
	-- Activate: Set 1 "Trickstar" Spell from Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SSET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.acttg)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)
	-- Extra Normal Summon for "Trickstar"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xfb))
	c:RegisterEffect(e2)
	-- If effect damage is inflicted: Set 1 "Trickstar" Trap from Deck, can be activated this turn
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DAMAGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCategory(CATEGORY_SSET)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.setcon)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end

function s.actfilter(c)
	return c:IsSetCard(0xfb) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SSET,nil,1,tp,LOCATION_DECK)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectYesNo(tp,aux.Stringid(id,3)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.actfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g:GetFirst())
	end
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and Duel.GetCurrentPhase()~=PHASE_DAMAGE and Duel.GetCurrentPhase()~=PHASE_DAMAGE_CAL
end
function s.setfilter(c)
	return c:IsSetCard(0xfb) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SSET,nil,1,tp,LOCATION_DECK)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc and Duel.SSet(tp,tc)~=0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,4))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end

--[[
When this card is activated: You can Set 1 "Trickstar" Spell from your Deck.
During your Main Phase, you can Normal Summon 1 "Trickstar" monster in addition to your Normal Summon/Set. (You can only gain this effect once per turn.)
If effect damage is inflicted (except during the Damage Step): You can Set 1 "Trickstar" Trap from your Deck. It can be activated this turn.
You can only use this effect of "Garden of Blue Tears" once per turn.
You can only activate 1 "Garden of Blue Tears" per turn.
]]