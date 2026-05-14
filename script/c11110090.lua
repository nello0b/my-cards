--Vic Viper Beginning
local s,id,o=GetID()
function s.initial_effect(c)
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	--(Hand only) Mark that this card was in hand when the Summon resolved
	local e00=Effect.CreateEffect(c)
	e00:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e00:SetCode(EVENT_SUMMON_SUCCESS)
	e00:SetRange(LOCATION_HAND)
	e00:SetCondition(s.fgcon)
	e00:SetOperation(s.fgop)
	c:RegisterEffect(e00)
	local e00b=e00:Clone()
	e00b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e00b)
	--If a "B.E.S." monster(s) is Summoned to your field: Special Summon this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetLabelObject(e0)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	--If this card is Summoned: Set 1 "Boss Rush" or 1 Spell/Trap that mentions it
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end

local BOSS_RUSH=68468459

function s.besfilter(c,tp)
	return c:IsSetCard(0x15) and c:IsType(TYPE_MONSTER) and c:IsControler(tp)
end

function s.besfilter2(c,tp,se)
	return s.besfilter(c,tp) and (se==nil or c:GetReasonEffect()~=se)
end

function s.fgcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsDamageStep() and eg:IsExists(s.besfilter,1,nil,tp)
end
function s.fgop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsDamageStep() then return false end
	local se=e:GetLabelObject():GetLabelObject()
	if not eg:IsExists(s.besfilter2,1,nil,tp,se) then return false end
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_HAND) then
		return c:GetFlagEffect(id)>0
	end
	return true
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end

function s.setfilter(c)
	return c:IsSSetable() and (c:IsCode(BOSS_RUSH) or (c:IsType(TYPE_SPELL+TYPE_TRAP) and aux.IsCodeOrListed(c,BOSS_RUSH)))
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local hp=e:GetHandler():GetOwner()
	if chk==0 then
		return Duel.GetLocationCount(hp,LOCATION_SZONE)>0
			and Duel.IsExistingMatchingCard(s.setfilter,hp,LOCATION_DECK,0,1,nil)
	end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local hp=e:GetHandler():GetOwner()
	if Duel.GetLocationCount(hp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,hp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(hp,s.setfilter,hp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.SSet(hp,tc)
	end
end
