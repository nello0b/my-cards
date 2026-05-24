-- The Fabled Waira
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x35),1,1,Synchro.NonTuner(nil),1,99)
	--If this card is Special Summoned: destroy up to # of "Fabled" monsters discarded this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--GY Quick Effect (opponent's turn): discard 2; Special Summon this card, banish it when it leaves
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)

	--Global discard counter (both players, this turn)
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_REMOVE)
		Duel.RegisterEffect(ge2,0)
	end

end

s.listed_series={0x35}

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:IsPreviousLocation(LOCATION_HAND) and bit.band(r,REASON_DISCARD)~=0
			and tc:IsSetCard(0x35) and tc:IsType(TYPE_MONSTER) then
			Duel.RegisterFlagEffect(tc:GetPreviousControler(),id,RESET_PHASE+PHASE_END,0,1)
		end
		tc=eg:GetNext()
	end
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	local ct=Duel.GetFlagEffect(tp,id)+Duel.GetFlagEffect(1-tp,id)
	if chk==0 then return ct>0 and Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local tg=g:Select(tp,1,math.min(ct,#g),nil)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,#tg,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,2,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,2,2,REASON_COST+REASON_DISCARD)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
	Duel.SpecialSummonComplete()
end

--[[
1 “Fabled” Tuner + 1+ non-Tuner monsters
If this card is Special Summoned: You can target cards your opponent controls up to the number of "Fabled" monsters discarded this turn; destroy them.
During your opponent's turn, if this card is in your GY (Quick Effect): You can discard 2 cards, and if you do, Special Summon this card, but banish it when it leaves the field.
You can only use each effect of "The Fabled Waira" once per turn.
]]