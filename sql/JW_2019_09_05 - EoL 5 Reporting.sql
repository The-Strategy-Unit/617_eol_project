----------------------------------------------------------------------------------------------------------------------------------------------------
/*create main activity table*/
----------------------------------------------------------------------------------------------------------------------------------------------------
--select * into Activity0AllMIDSBKUP1 from Activity0AllMIDS 
--drop table Activity0AllMIDS
select *,case when DER_AGE_AT_DEATH between 18 and 64 then '18-64' when DER_AGE_AT_DEATH between 65 and 74 then '65-74'	when DER_AGE_AT_DEATH between 75 and 84 then '75-84' when DER_AGE_AT_DEATH between 85 and 120 then '85+'
	 end as AgeGroup
into Activity0AllMIDS
from
	(
	select SUPatID, BB5008_Pseudo_ID, '' as BB5008_Pseudo_APCS_Ident_Pseudo,ProximityToDeath, ProximityToDeathDays, ProximityToDeathDaysCategory, 1 as Act, ActivityType, cast(PODSubGroup as varchar(11)) as PODSubGroup, PODSummaryGroup, CauseGroupLL, STP18CD, LocationType, DER_AGE_AT_DEATH, Administrative_Category, PODType, Der_Provider_Code, [Org Type], Der_Provider_Site_Code, Spell_Dominant_Procedure_Der1819, Admission_Date, Discharge_Date, null as ActivityDay, ChemotherapyIndicator,HRG_Code_COST1819 as HRG,'' as DiedInCriticalCare, Tariff_Exclusion_Reason_Cost1819,Cost_Type_Cost1819,Spell_PreGrp_Exc_Reason_Der1819,SSFlag,'' as Treatment_Function_Code,Responsible_Purchaser_Type_Der1819
	,Grand_Total_Payment_MFF_Cost1819, refcostprice, 0 AS SSCOST, case when SSFlag='SS' then 0 when isnull(Grand_Total_Payment_MFF_Cost1819,0)=0 then RefCostPrice else Grand_Total_Payment_MFF_Cost1819 end as FinalCost
	,Der_Provider_Patient_Distance_Miles
	from ActivityIP 
		union all
	select SUPatID,BB5008_Pseudo_ID, '' as BB5008_Pseudo_APCS_Ident_Pseudo,ProximityToDeath, ProximityToDeathDays, ProximityToDeathDaysCategory, 1 as Act, ActivityType, PODSubGroup, PODSummaryGroup, CauseGroupLL, STP18CD, LocationType, DER_AGE_AT_DEATH, Administrative_Category, PODType, Der_Provider_Code, [Org Type], Der_Provider_Site_Code,'' as Spell_Dominant_Procedure_Der1819, Admission_Date, Discharge_Date, ActivityDay, 0 as ChemotherapyIndicator,'' as HRG,'' as DiedInCriticalCare, '' as Tariff_Exclusion_Reason_Cost1819, '' as Cost_Type_Cost1819, '' as Spell_PreGrp_Exc_Reason_Der1819,SSFlag,'' as Treatment_Function_Code,Responsible_Purchaser_Type_Der1819
	,0 as Grand_Total_Payment_MFF_Cost1819, 0 as refcostprice, 0 AS SSCOST,0 as FinalCost
	,Der_Provider_Patient_Distance_Miles
	from ActivityIPBDDAYS
		union all
	select SUPatID,BB5008_Pseudo_ID, '' as BB5008_Pseudo_APCS_Ident_Pseudo,ProximityToDeath, ProximityToDeathDays, ProximityToDeathDaysCategory, 1 as Act, ActivityType, PODSubGroup, PODSummaryGroup, CauseGroupLL, STP18CD, LocationType, DER_AGE_AT_DEATH, Administrative_Category, PODType, Der_Provider_Code, [Org Type], Der_Provider_Site_Code,'' as Spell_Dominant_Procedure_Der1819, '' as Admission_Date, '' as Discharge_Date, null as ActivityDay,ChemotherapyIndicator,HRG as HRG,'' as DiedInCriticalCare, Tariff_Exclusion_Reason_Cost1819,Cost_Type_Cost1819,pregrp_exclusion_reason_der1819,SSFlag,Treatment_Function_Code,Responsible_Purchaser_Type_Der1819
	,Grand_Total_Payment_MFF_Cost1819, refcostprice, 0 AS SSCOST, case when SSFlag='SS' then 0 when isnull(Grand_Total_Payment_MFF_Cost1819,0)=0 then RefCostPrice else Grand_Total_Payment_MFF_Cost1819 end as FinalCost
	,Der_Provider_Patient_Distance_Miles
	from ActivityOP 
		union all
	select SUPatID,BB5008_Pseudo_ID, '' as BB5008_Pseudo_APCS_Ident_Pseudo,ProximityToDeath, ProximityToDeathDays, ProximityToDeathDaysCategory, 1 as Act, ActivityType, PODSubGroup, PODSummaryGroup, CauseGroupLL, STP18CD, LocationType, DER_AGE_AT_DEATH, '' as Administrative_Category, PODType, Der_Provider_Code, [Org Type], Der_Provider_Site_Code,'' as Spell_Dominant_Procedure_Der1819, '' as Admission_Date, '' as Discharge_Date, null as ActivityDay, 0 as ChemotherapyIndicator,'' as HRG, '' as DiedInCriticalCare, '' as Tariff_Exclusion_Reason_Cost1819, '' as Cost_Type_Cost1819, '' as Spell_PreGrp_Exc_Reason_Der1819,SSFlag,'' as Treatment_Function_Code,Responsible_Purchaser_Type_Der1819
	,Grand_Total_Payment_MFF_Cost1819, 0 as refcostprice, 0 AS SSCOST, isnull(Grand_Total_Payment_MFF_Cost1819,0) as FinalCost
	,Der_Provider_Patient_Distance_Miles
	from ActivityAE 
		union all
	select SUPatID, BB5008_Pseudo_ID, BB5008_Pseudo_APCS_Ident_Pseudo, '' as ProximityToDeath, datediff(d,Day, REG_DATE_OF_DEATH) as ProximityToDeathDays, '' as ProximityToDeathDaysCategory, 1 as Act, 'CC' as ActivityType, PODSubGroup, PODSummaryGroup, CauseGroupLL, STP18CD, LocationType, DER_AGE_AT_DEATH, '' as Administrative_Category, 'Critical Care Bed Day' as PODType, Der_Provider_Code, '' as [Org Type], '' as Der_Provider_Site_Code,'' as Spell_Dominant_Procedure_Der1819, CC_Start_Date as Admission_Date, CC_Discharge_Date as Discharge_Date, null as ActivityDay, 0 as ChemotherapyIndicator,'' as HRG, case when DiedInCriticalCare>=1 then 1 else 0 end as DiedInCriticalCare, '' as Tariff_Exclusion_Reason_Cost1819, '' as Cost_Type_Cost1819, '' as Spell_PreGrp_Exc_Reason_Der1819,SSFlag,'' as Treatment_Function_Code,Responsible_Purchaser_Type_Der1819
	, 0 AS TotalCost, 0 as RefCostPrice, 0 AS SSCOST,0 as FinalCost
	,999999 as Der_Provider_Patient_Distance_Miles
	from
		(select SUPatID, BB5008_Pseudo_ID, BB5008_Pseudo_APCS_Ident_Pseudo, CC_Start_Date, CC_Discharge_Date, PODSubGroup, PODSummaryGroup,REG_DATE_OF_DEATH,CauseGroupLL, STP18CD, LocationType, DER_AGE_AT_DEATH, Der_Provider_Code, sum(DiedInCriticalCare) as DiedInCriticalCare, sum(TotalCost) as TotalCost, ssflag,'' as Treatment_Function_Code,Responsible_Purchaser_Type_Der1819
		from ActivityCC
		where 1=1
		--and BB5008_Pseudo_ID='C4762D2C608388FF72C0EE1941DC4520FCF8458C82A37B0099CDE17DB087919B'
		--and BB5008_Pseudo_APCS_Ident_Pseudo='ED1FD910BE640C13BE51F5BDF25167B8C70BB4282DB27AF9B4D5AE90268EC351'
		group by SUPatID, BB5008_Pseudo_ID, BB5008_Pseudo_APCS_Ident_Pseudo, CC_Start_Date, CC_Discharge_Date, PODSubGroup, PODSummaryGroup, REG_DATE_OF_DEATH,CauseGroupLL, STP18CD, LocationType, DER_AGE_AT_DEATH, Der_Provider_Code, ssflag,Responsible_Purchaser_Type_Der1819
		) as CC
	cross join dbo.RefMonthYearDay as MYD
	where  Day>=CC_Start_Date and Day<=CC_Discharge_Date
	--union all
	--select SUPatID,BB5008_Pseudo_ID,ProximityToDeath, ProximityToDeathDays, ProximityToDeathDaysCategory, 1 as Act, ActivityType, PODSubGroup, PODSummaryGroup, CauseGroupLL, STP18CD, LocationType, DER_AGE_AT_DEATH, '' as Administrative_Category, PODType, '' as Der_Provider_Code, '' as [Org Type], '' as Der_Provider_Site_Code,'' as Spell_Dominant_Procedure_Der1819, '' as Admission_Date, '' as Discharge_Date, null as ActivityDay, 0 as ChemotherapyIndicator,'' as HRG
	--from ActivityDD
		union all
	select SUPatID,BB5008_Pseudo_ID, '' as BB5008_Pseudo_APCS_Ident_Pseudo,ProximityToDeath, ProximityToDeathDays, ProximityToDeathDaysCategory, 1 as Act, ActivityType, PODSubGroup, PODSummaryGroup, CauseGroupLL, STP18CD, LocationType, DER_AGE_AT_DEATH, '' as Administrative_Category, PODType, '' as Der_Provider_Code, '' as [Org Type], '' as Der_Provider_Site_Code,'' as Spell_Dominant_Procedure_Der1819, '' as Admission_Date, '' as Discharge_Date, null as ActivityDay, 0 as ChemotherapyIndicator,'' as HRG, '' as DiedInCriticalCare, '' as Tariff_Exclusion_Reason_Cost1819, '' as Cost_Type_Cost1819, '' as Spell_PreGrp_Exc_Reason_Der1819,SSFlag,'' as Treatment_Function_Code,'' as Responsible_Purchaser_Type_Der1819
		,0 as Grand_Total_Payment_MFF_Cost1819, 0 as refcostprice, 0 AS SSCOST, 0 as FinalCost
	,Der_Provider_Patient_Distance_Miles
	from ActivityIAPT
		union all
	select SUPatID,BB5008_Pseudo_ID, '' as BB5008_Pseudo_APCS_Ident_Pseudo,ProximityToDeath, ProximityToDeathDays, ProximityToDeathDaysCategory, 1 as Act, ActivityType, PODSubGroup, PODSummaryGroup, CauseGroupLL, STP18CD, LocationType, DER_AGE_AT_DEATH, AdminCatCode, PODType, '' as Der_Provider_Code, '' as [Org Type], '' as Der_Provider_Site_Code,'' as Spell_Dominant_Procedure_Der1819, '' as Admission_Date, '' as Discharge_Date, null as ActivityDay, 0 as ChemotherapyIndicator,'' as HRG,'' as DiedInCriticalCare, '' as Tariff_Exclusion_Reason_Cost1819, '' as Cost_Type_Cost1819, '' as Spell_PreGrp_Exc_Reason_Der1819,SSFlag,'' as Treatment_Function_Code,'' as Responsible_Purchaser_Type_Der1819
	,0 as Grand_Total_Payment_MFF_Cost1819, 0 as refcostprice, 0 AS SSCOST, 0 as FinalCost
	,Der_Provider_Patient_Distance_Miles
	from ActivityMH
		union all
	select SUPatID,BB5008_Pseudo_ID, '' as BB5008_Pseudo_APCS_Ident_Pseudo,ProximityToDeath, ProximityToDeathDays, ProximityToDeathDaysCategory, 1 as Act, ActivityType, PODSubGroup, PODSummaryGroup, CauseGroupLL, STP18CD, LocationType, DER_AGE_AT_DEATH, '' as Administrative_Category, PODType, '' as Der_Provider_Code, '' as [Org Type], '' as Der_Provider_Site_Code,'' as Spell_Dominant_Procedure_Der1819, '' as Admission_Date, '' as Discharge_Date, null as ActivityDay, 0 as ChemotherapyIndicator,'' as HRG, '' as DiedInCriticalCare, '' as Tariff_Exclusion_Reason_Cost1819, '' as Cost_Type_Cost1819, '' as Spell_PreGrp_Exc_Reason_Der1819,SSFlag,'' as Treatment_Function_Code,'' as Responsible_Purchaser_Type_Der1819
	,0 as Grand_Total_Payment_MFF_Cost1819, 0 as refcostprice, 0 AS SSCOST, 0 as FinalCost
	,Der_Provider_Patient_Distance_Miles
	from Activity111 
	--  union all
	--select SUPatID,BB5008_Pseudo_ID, '' as BB5008_Pseudo_APCS_Ident_Pseudo,ProximityToDeath, ProximityToDeathDays, ProximityToDeathDaysCategory, 0 as Act, 'CCSPELLS' as ActivityType, PODSubGroup, PODSummaryGroup, CauseGroupLL, STP18CD, LocationType, DER_AGE_AT_DEATH, '' as Administrative_Category, PODType, Der_Provider_Code, [Org Type], Der_Provider_Site_Code,'' as Spell_Dominant_Procedure_Der1819, '' as Admission_Date, '' as Discharge_Date, null as ActivityDay, 0 as ChemotherapyIndicator,'' as HRG, '' as DiedInCriticalCare, '' as Tariff_Exclusion_Reason_Cost1819, '' as Cost_Type_Cost1819, '' as Spell_PreGrp_Exc_Reason_Der1819,SSFlag,'' as Treatment_Function_Code,Responsible_Purchaser_Type_Der1819
	--,0 as Grand_Total_Payment_MFF_Cost1819, sum(TotalCost) as RefCost, 0 AS SSCOST,sum(case when SSFlag='SS' then 0 else TotalCost end) as FinalCost
	--from ActivityCC
	--group by SUPatID,BB5008_Pseudo_ID, ProximityToDeath, ProximityToDeathDays, ProximityToDeathDaysCategory,  ActivityType, PODSubGroup, PODSummaryGroup, CauseGroupLL, STP18CD, LocationType, DER_AGE_AT_DEATH,  PODType, Der_Provider_Code, [Org Type], Der_Provider_Site_Code,SSFlag,Responsible_Purchaser_Type_Der1819
	--	union all
	--select SUPatID,BB5008_Pseudo_ID, '' as BB5008_Pseudo_APCS_Ident_Pseudo,'' as ProximityToDeath, ProximityToDeathDays, ''as ProximityToDeathDaysCategory, 0 as Act, ActivityType, PODSubGroup, PODSummaryGroup, CauseGroupLL, STP18CD, LocationType, DER_AGE_AT_DEATH, '' as Administrative_Category, PODType, Der_Provider_Code, '' [Org Type], '' Der_Provider_Site_Code,'' as Spell_Dominant_Procedure_Der1819, '' as Admission_Date, '' as Discharge_Date, ActivityDay, 0 as ChemotherapyIndicator,'' as HRG, '' as DiedInCriticalCare, '' as Tariff_Exclusion_Reason_Cost1819, '' as Cost_Type_Cost1819, '' as Spell_PreGrp_Exc_Reason_Der1819,SSFlag,'' as Treatment_Function_Code,'' as Responsible_Purchaser_Type_Der1819
	--,0 as Grand_Total_Payment_MFF_Cost1819, 0 as RefCost, sum(SSCost) AS SSCOST,sum(SSCost) AS FinalCost
	--from ActivitySS
	--group by SUPatID,BB5008_Pseudo_ID, ProximityToDeathDays,  ActivityType, PODSubGroup, PODSummaryGroup, CauseGroupLL, STP18CD, LocationType, DER_AGE_AT_DEATH,  PODType, Der_Provider_Code,  ActivityDay,SSFlag
	) as A
where STP18CD IN ('E54000010','E54000011','E54000016','E54000017','E54000018','E54000019','E54000012','E54000013','E54000014','E54000015','E54000020')
	and ProximityToDeathDays>=0


--drop table Activity1AllMIDSCost
select * 
into Activity1AllMidsCost
from Activity0AllMIDS --5436572

insert into Activity1AllMidsCost
select  *
	,case when DER_AGE_AT_DEATH between 18 and 64 then '18-64'		when DER_AGE_AT_DEATH between 65 and 74 then '65-74'		when DER_AGE_AT_DEATH between 75 and 84 then '75-84' when DER_AGE_AT_DEATH between 85 and 120 then '85+'
	 end as AgeGroup
--into tempf
from
	(select SUPatID
		,BB5008_Pseudo_ID
		,'' as BB5008_Pseudo_APCS_Ident_Pseudo
		,ProximityToDeath
		,ProximityToDeathDays
		,ProximityToDeathDaysCategory
		,0 as Act
		,'CCSPELLS' as ActivityType
		,PODSubGroup
		,PODSummaryGroup
		,CauseGroupLL
		,STP18CD
		,LocationType
		,DER_AGE_AT_DEATH
		,'' as Administrative_Category
		,PODType
		,Der_Provider_Code
		,[Org Type]
		,Der_Provider_Site_Code
		,'' as Spell_Dominant_Procedure_Der1819
		,null as Admission_Date
		,null as Discharge_Date
		,null as ActivityDay
		,0 as ChemotherapyIndicator
		,'' as HRG
		,0 as DiedInCriticalCare
		,'' as Tariff_Exclusion_Reason_Cost1819
		,'' as Cost_Type_Cost1819
		,'' as Spell_PreGrp_Exc_Reason_Der1819
		,SSFlag
		,'' as Treatment_Function_Code
		,'' as Responsible_Purchaser_Type_Der1819
		,0 as Grand_Total_Payment_MFF_Cost1819
		,sum(TotalCost) as RefCostPrice
		,0 as SSCost
		,sum(case when SSFlag='SS' then 0 else TotalCost end) as FinalCost
	from ActivityCC
	group by SUPatID
		,BB5008_Pseudo_ID
		,ProximityToDeath
		,ProximityToDeathDays
		,ProximityToDeathDaysCategory
		,PODSubGroup
		,PODSummaryGroup
		,CauseGroupLL
		,STP18CD
		,LocationType
		,DER_AGE_AT_DEATH
		,PODType
		,Der_Provider_Code
		,[Org Type]
		,Der_Provider_Site_Code
		,SSFlag
	union all
	select SUPatID
		,BB5008_Pseudo_ID
		,'' as BB5008_Pseudo_APCS_Ident_Pseudo
		,ProximityToDeath
		,ProximityToDeathDays
		,ProximityToDeathDaysCategory
		,0 as Act
		,ActivityType
		,SS.PODSubGroup
		,PODSummaryGroup
		,CauseGroupLL
		,STP18CD
		,LocationType
		,DER_AGE_AT_DEATH
		,'' as Administrative_Category
		,case when P.F3 is not null then P.F3 end as PODType
		,Der_Provider_Code
		,'' as [Org Type]
		,'' as Der_Provider_Site_Code
		,'' as Spell_Dominant_Procedure_Der1819
		,null as Admission_Date
		,null as Discharge_Date
		,null as ActivityDay
		,0 as ChemotherapyIndicator
		,'' as HRG
		,0 as DiedInCriticalCare
		,'' as Tariff_Exclusion_Reason_Cost1819
		,'' as Cost_Type_Cost1819
		,'' as Spell_PreGrp_Exc_Reason_Der1819
		,SSFlag
		,'' as Treatment_Function_Code
		,'' as Responsible_Purchaser_Type_Der1819
		,0 as Grand_Total_Payment_MFF_Cost1819
		,0 as RefCostPrice
		,sum(SSCost) as SSCost
		,sum(SSCost) as FinalCost
	from ActivitySS as SS
	left outer join RefSSPODs as P
		on SS.PODsubGroup=P.PODSS
	group by SUPatID
		,BB5008_Pseudo_ID
		,ProximityToDeath
		,ProximityToDeathDays
		,ProximityToDeathDaysCategory
		,ActivityType
		,SS.PODSubGroup
		,PODSummaryGroup
		,CauseGroupLL
		,STP18CD
		,LocationType
		,DER_AGE_AT_DEATH
		,case when P.F3 is not null then P.F3 end
		,Der_Provider_Code
		,SSFlag
	) as A
where STP18CD IN ('E54000010','E54000011','E54000016','E54000017','E54000018','E54000019','E54000012','E54000013','E54000014','E54000015','E54000020')
	and ProximityToDeathDays>=0