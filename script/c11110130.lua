--Infernal Rising Dragon
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,70902743)
	
	--Synchro Summon procedure (1+ "Resonator" Tuners + 1+ non-Tuner monsters)
	aux.AddSynchroMixProcedure(c,aux.Tuner(Card.IsSetCard,0x57),aux.NonTuner(nil),nil,s.matfilter,0,99)
	c:EnableReviveLimit()
	
	--Effect 1: Target destroy and Special Summon (Quick Effect, Once per Chain)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	
	--Material Check for E1 & Double Tuner Effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.matcon)
	e2:SetOperation(s.matop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(s.valcheck)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	
	--Effect 2: Quick Synchro Summon during Main/Battle Phase
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.sccon)
	e4:SetTarget(s.sctg)
	e4:SetOperation(s.scop)
	c:RegisterEffect(e4)
end

-- Synchro Material remainder filter: allows more "Resonator" Tuners or non-Tuner monsters
function s.matfilter(c,syncard)
	return (c:IsTuner(syncard) and c:IsSetCard(0x57)) or c:IsNotTuner(syncard)
end

-- Material Check Helpers
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and e:GetLabel()>0
end

function s.matop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,e:GetLabel())
end

function s.valcheck(e,c)
	local g=c:GetMaterial()
	local ct=g:FilterCount(Card.IsType,nil,TYPE_TUNER)
	e:GetLabelObject():SetLabel(ct)
	-- Register official Double Tuner effect (Red Nova effect code 21142671) if 2 or more Tuners used
	if ct>=2 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(21142671)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end

-- Effect 1 (Destroy and Special Summon)
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x57) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local c=e:GetHandler()
	local ct=c:GetFlagEffectLabel(id)
	if not ct then ct=0 end
	local used=c:GetFlagEffect(id+1)
	if chk==0 then
		return used<ct and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingTarget(Card.IsDestructable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
			and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	
	-- Register usage flag for the turn
	c:RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectTarget(tp,Card.IsDestructable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g2=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,1,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local hc=e:GetLabelObject() -- Card on field to destroy
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not g or #g<2 then return end
	local sg=g:Clone()
	sg:RemoveCard(hc)
	local tc=sg:GetFirst() -- Resonator in GY (the target that is NOT the field target)
	if hc and hc:IsRelateToEffect(e) and Duel.Destroy(hc,REASON_EFFECT)>0 then
		if tc and tc:IsRelateToEffect(e) then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

-- Effect 2 (Quick Synchro Summon)
function s.sccon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2
end

function s.syncheck(g,tp,syncard)
	if not g:IsExists(Card.IsCode,1,nil,70902743) then return false end
	return syncard:IsSynchroSummonable(nil,g)
end

function s.spfilter2(c,tp,mg)
	if not c:IsType(TYPE_SYNCHRO) then return false end
	aux.GCheckAdditional=aux.SynGroupCheckLevelAddition(c)
	local res=mg:CheckSubGroup(s.syncheck,2,#mg,tp,c)
	aux.GCheckAdditional=nil
	return res
end

function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetSynchroMaterial(tp):Filter(Card.IsLocation,nil,LOCATION_MZONE)
		return Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,tp,mg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetSynchroMaterial(tp):Filter(Card.IsLocation,nil,LOCATION_MZONE)
	local g=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_EXTRA,0,nil,tp,mg)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		local sc=sg:GetFirst()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
		local tg=mg:SelectSubGroup(tp,s.syncheck,false,2,#mg,tp,sc)
		if tg and #tg>0 then
			Duel.SynchroSummon(tp,sc,nil,tg)
		end
	end
end