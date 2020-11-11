----------------------------------------------------------------------------------------------------------------------------------------------------
/*create the correct cc activity file with added fields and linked to MPI*/ --please note on start date not day specific
----------------------------------------------------------------------------------------------------------------------------------------------------
--drop table ActivityCC
select SUPatID
	,IP.BB5008_Pseudo_ID
	,'CC' as ActivityType
	,[CC_Start_Date]
    ,[CC_Discharge_Date]
	,Der_Provider_Code --provider code, 3 digits except for private
	,Der_Provider_Site_Code --provider code, 5 digits except for private. don't think will use but just in case I am including for now
	,[Org Type]
	,CC.BB5008_Pseudo_APCS_Ident_Pseudo
	,CC.CC_Total_Cost
	,CC.CC_Days_LOS
	,CC_Days_Tariff
	,CC.Unbundled_HRG
	,CC.CC_Days_Tariff*RCCC.NAUCost as TotalCost
	,PODSubGroup
	,PODSummaryGroup
	,'CC' as PODType
	--,CC_Patient_Type
	--,CC_Days_LOS
	--,Total_Episode_Level_CC_Days_LOS
    ,Total_Episode_Level_CC_Days_Tariff
	--,PBR_Qualified_Indicator
	--,Unbundled_HRG
	--,CC_Level2_days
	--,CC_Level3_Days
	--,CC_Discharge_Status
	--,CC_Discharge_Destination
	--,CC_Discharge_Location
	,NCBFinal_Spell_ServiceLine_Der1819
	,NCBFinal_Spell_NPoC_Der1819
	,Responsible_Purchaser_Type_Der1819
	,Responsible_Purchaser_Assignment_Method_Der1819
	,case when 
		((CC_Discharge_Status in ('08','09','10','11') or CC_Discharge_Destination='06' or CC_Discharge_Location='06') and datediff(d,CC_Discharge_Date,REG_DATE_OF_DEATH) between -1 and 1)
		or 
		(CC_Discharge_Status is null and CC_Discharge_Destination is null and CC_Discharge_Location is null and datediff(d,CC_Discharge_Date,REG_DATE_OF_DEATH) between -1 and 0)
		then 1
		else 0
	end as 'DiedInCriticalCare'
	,case when (Responsible_Purchaser_Type_Der1819='Comm Hub' /*NCBFinal_Spell_ServiceLine_Der1819 like 'NCB%'*/ or HRG_Code_COST1819 in ('SB97Z','SC97Z')) then 'SS'
		when Responsible_Purchaser_Type_Der1819='Region' then 'Region'
		when Responsible_Purchaser_Type_Der1819='CCG' then 'CCG'
		else 'Other'
	end as SSFlag
	,999999 as Der_Provider_Patient_Distance_Miles
	,cast(case 
		when datepart(d,REG_DATE_OF_DEATH)<datepart(d,CC_Start_Date) then cast(datediff(mm,CC_Start_Date,REG_DATE_OF_DEATH)-1 as nvarchar(8))
		when datepart(d,REG_DATE_OF_DEATH)>=datepart(d,CC_Start_Date) then cast(datediff(mm,CC_Start_Date,REG_DATE_OF_DEATH) as nvarchar(8))
	end as int) as ProximityToDeath
	,cast(datediff(d,CC_Start_Date,REG_DATE_OF_DEATH) as int) as ProximityToDeathDays--does this ned to be int?
	,case when cast(datediff(d,CC_Start_Date,REG_DATE_OF_DEATH) as int)=0 then '24hours'
		when cast(datediff(d,CC_Start_Date,REG_DATE_OF_DEATH) as int)=1 then '48hours'
		when cast(datediff(d,CC_Start_Date,REG_DATE_OF_DEATH) as int) between 2 and 6 then '1weeks'
		when cast(datediff(d,CC_Start_Date,REG_DATE_OF_DEATH) as int) between 7 and 13 then '2weeks'
	end as ProximityToDeathDaysCategory
	,REG_DATE_OF_DEATH
	,STP18CD
	,CCGResponsible
	,DER_AGE_AT_DEATH
	,LocationType
	,CauseGroupLL
into ActivityCC 
from [qa].[tbl_SUS_APCS_CC_Extract] as CC
inner join [GEM\JWiltshire].ActivityIP as IP
	on CC.BB5008_Pseudo_APCS_Ident_Pseudo=IP.BB5008_Pseudo_APCS_Ident_Pseudo
left outer join [GEM\JWiltshire].RefNSRCCC as RCCC
	on CC.CC_Unit_Function=RCCC.UnitFunction
	and CC.Unbundled_HRG=RCCC.CurrencyCode
where 
cast(case 
		when datepart(d,REG_DATE_OF_DEATH)<datepart(d,CC_Start_Date) then cast(datediff(mm,CC_Start_Date,REG_DATE_OF_DEATH)-1 as nvarchar(8))
		when datepart(d,REG_DATE_OF_DEATH)>=datepart(d,CC_Start_Date) then cast(datediff(mm,CC_Start_Date,REG_DATE_OF_DEATH) as nvarchar(8))
	end as int)<=23 --between 0 and 23
and CC_Type='ACC' --3+6+146 days that aren't adult. decided to exclude given calculation basis. did not put criteria on PatientType
and Exclusion_Reason is null
--and CC.BB5008_Pseudo_ID='C4762D2C608388FF72C0EE1941DC4520FCF8458C82A37B0099CDE17DB087919B'
		--and BB5008_Pseudo_APCS_Ident_Pseudo='ED1FD910BE640C13BE51F5BDF25167B8C70BB4282DB27AF9B4D5AE90268EC351'
