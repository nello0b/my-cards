-- Argostars - Brave Amphi
local s,id,o=GetID()
local SET_ARGOSTARS=0x1c1
local HOME_STADIUM=2674965

function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.prottg)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.placetg)
	e3:SetOperation(s.placeop)
	c:RegisterEffect(e3)
end

function s.prottg(e,c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_FZONE,0,1,nil,HOME_STADIUM)
end
function s.banishfilter(c)
	return c:IsSetCard(SET_ARGOSTARS) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsPlayerCanSpecialSummonMonster(tp,id,SET_ARGOSTARS,TYPES_EFFECT_TRAP_MONSTER,1500,1500,4,RACE_WARRIOR,ATTRIBUTE_LIGHT)
			and Duel.IsExistingMatchingCard(s.banishfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_SZONE)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,SET_ARGOSTARS,TYPES_EFFECT_TRAP_MONSTER,1500,1500,4,RACE_WARRIOR,ATTRIBUTE_LIGHT) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	if Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,s.banishfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then Duel.Remove(g,POS_FACEUP,REASON_EFFECT) end
	end
end

function s.placetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and e:GetHandler():IsCanBePlacedOnField() end
end
function s.placeop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:IsRelateToEffect(e)
		and Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		local ce=Effect.CreateEffect(c)
		ce:SetCode(EFFECT_CHANGE_TYPE)
		ce:SetType(EFFECT_TYPE_SINGLE)
		ce:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		ce:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		ce:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
		c:RegisterEffect(ce)
	end
end
