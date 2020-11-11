----------------------------------------------------------------------------------------------------------------------------------------------------
/*create the correct inpatient activity file with added fields and linked to MPI*/
----------------------------------------------------------------------------------------------------------------------------------------------------
--drop table ActivityIP
select SUPatID 
	,MPI.BB5008_Pseudo_ID --Der_Pseudo_NHS_Number
	,'IP' as ActivityType
	,Carer_Support_Indicator
	,Ethnic_Group
	,Admission_Date
	,Discharge_Date
	,Der_Provider_Code --provider code, 3 digits except for private
	,Der_Provider_Site_Code --provider code, 5 digits except for private. don't think will use but just in case I am including for now
	,[Org Type]
	,ET.TrustType as TrustType
	,ES.TrustType as SiteType
	,BB5008_Pseudo_APCS_Ident_Pseudo
	,National_POD_Code_Der1819
	,case when National_POD_Code_Der1819='NELNE' then 'NEL'
		when National_POD_Code_Der1819='NELST' then 'NES'
		when National_POD_Code_Der1819 in ('RDAY','RNIGHT') then 'RP'
	else National_POD_Code_Der1819 end as PODNSRC
	,[Tariff_Total_Payment_Cost1819]
	,[Local_Total_Payment_Cost1819]
	,[Local_Contractual_Adj_Cost1819]
	,case 
		when Der_Management_Type in ('EM','NE') then 'EM'
		when Der_Management_Type in ('RDA','RNA') then 'RA'
		else Der_Management_Type 
	end as PODSubGroup
	,case 
		when Der_Management_Type in ('EM','NE') then 'EM'
		when Der_Management_Type in ('RDA','RNA') then 'RA'
		else Der_Management_Type 
	end as PODSummaryGroup
	,case 
		when Der_Management_Type in ('EM','NE') then 'Unplanned'
		when Der_Management_Type in ('RDA','RNA','EL','DC') then 'PlannedEvent'
		else Der_Management_Type 
	end as PODType
	,Administrative_Category
	,Der_Diagnosis_All
	,case when Der_Procedure_All like '%X70%' or Der_Procedure_All like '%X71%' or Der_Procedure_All like '%X72%' or Der_Procedure_All like '%X73%' 
		then 1 else 0 end as ChemotherapyIndicator
	,Spell_Dominant_Procedure_Der1819
	,case when Der_Procedure_All like '%X503%' or Der_Procedure_All like '%X508%' or Der_Procedure_All like '%X509%' then 1 else 0 end as ReceivedCPR
	,HRG_Code_COST1819
	,Grand_Total_Payment_MFF_Cost1819
	,Cost_Type_Cost1819
	,case when Grand_Total_Payment_MFF_Cost1819=0 or Grand_Total_Payment_MFF_Cost1819 is null then CO.NAUCost*1 end as RefCostPrice
	,Spell_PreGrp_Exc_Reason_Der1819
	,Tariff_Exclusion_Reason_Cost1819
	--If found in SS (and in…) then £SS else if Grand=0/null then RC*cummulativeRC*MFF else GrandIf found in SS (and in…) then £SS else if Grand=0/null then RC*cummulativeRC*MFF else Grand
	,NCBFinal_Spell_ServiceLine_Der1819 --i believe this best field
	,NCBFinal_Spell_NPoC_Der1819 --i believe this best field
	,Responsible_Purchaser_Type_Der1819 --summary version
	,Responsible_Purchaser_Assignment_Method_Der1819 --detailed version
	,case when (Responsible_Purchaser_Type_Der1819='Comm Hub' /*NCBFinal_Spell_ServiceLine_Der1819 like 'NCB%'*/ or Der_Management_Type in ('RDA','RNA') or HRG_Code_COST1819 in ('SB97Z','SC97Z')) and Administrative_Category<>'02' then 'SS'
		when Responsible_Purchaser_Type_Der1819='Region' and Administrative_Category<>'02' then 'Region'
		when Responsible_Purchaser_Type_Der1819='CCG' and Administrative_Category<>'02'then 'CCG'
		when Administrative_Category='02' then 'Private'
		else 'Other'
	end as SSFlag
	,Der_Provider_Patient_Distance_Miles
	,cast(case 
		when datepart(d,MPI.REG_DATE_OF_DEATH)<datepart(d,APCS.Admission_Date) then cast(datediff(mm,APCS.Admission_Date,MPI.REG_DATE_OF_DEATH)-1 as nvarchar(8))
		when datepart(d,MPI.REG_DATE_OF_DEATH)>=datepart(d,APCS.Admission_Date) then cast(datediff(mm,APCS.Admission_Date,MPI.REG_DATE_OF_DEATH) as nvarchar(8))
	end as int) as ProximityToDeath
	,cast(datediff(d,APCS.Admission_Date,MPI.REG_DATE_OF_DEATH) as int) as ProximityToDeathDays--does this ned to be int?
	,case when cast(datediff(d,APCS.Admission_Date,MPI.REG_DATE_OF_DEATH) as int)=0 then '24hours'
		when cast(datediff(d,APCS.Admission_Date,MPI.REG_DATE_OF_DEATH) as int)=1 then '48hours'
		when cast(datediff(d,APCS.Admission_Date,MPI.REG_DATE_OF_DEATH) as int) between 2 and 6 then '1weeks'
		when cast(datediff(d,APCS.Admission_Date,MPI.REG_DATE_OF_DEATH) as int) between 7 and 13 then '2weeks'
	end as ProximityToDeathDaysCategory
	,REG_DATE_OF_DEATH --used in CC
	,STP18CD
	,CCGResponsible
	,DER_AGE_AT_DEATH
	,LocationType
	,CauseGroupLL
	--,BB5008_Pseudo_Hospital_Spell_No
	--,PLD.CLN_Total_Cost
	--,AllCost, [NCBPS29E], [NCBPS14Z], [NCBPS01Q], [NCBPS08R], [NCBPS33C], [NCBPS34T], [NCBPS24Y], [NCBPSMOL], [NCBPS01R], [NCBPS32D], [NCBPS33B], [NCBPS27Z],	[NCBPS33A],	[NCBPS11B],	[NCBPS26Z],	[NCBPS23W],	[NCBPS01M],	[NCBPS01X],	[NCBPS01T],	[NCBPS01V],	[NCBPS08S],	[NCBPS08Y],	[NCBPS01I],	[NCBPS09Z],	[NCBPS13M],	[NCBPS13H],	[99999999],	[NCBPS01S],	[NCBPS01Y],	[NCBPS23H],	[NCBPS24A],	[NCBPS08O],	[NCBPS04F],	[NCBPS23S],	[NCBPS36C],	[NCBPS20Z],	[NCBPS01W],	[NCBPS11C],	[NCBPS34R],	[NCBPS35Z],	[NCBPS23Q],	[NCBPS01O],	[NCBPS01L],	[NCBPS19Z],	[NCBPS13B],	[NCBPS41P],	[EMPTY],	[NCBPS32B],	[NCBPS32A],	[NCBPS12C],	[NCBPS15A],	[NCBPS13E],	[NCBPS37Z],	[NCBPS01G],	[NCB_Dent],	[NCBPS36Z],	[NCBPS29B],	[NCBPS19T],	[NCBPS38T],	[NCBPS23T],	[NCBPS01J],	[NCBPS07Z],	[NCBPS38S],	[NCBPS18C],	[NCBPS13Z],	[NCBPS29V],	[NCBPS41U],	[NCBPSNIC],	[NCBPS18A],	[NCBPS01K],	[NCBPS34A],	[NCBPS29S],	[NCBPS30Z],	[NCBPS13C],	[NCBPS06Z],	[NCBPS23M],	[NCBPS23F],	[NCBPS13X],	[NCBPS99Z],	[NCBPS04E],	[NCBPS05P],	[NCBPS13J],	[NCBPS02Z],	[NCBPS23X],	[NCBPS08P],	[NCBPS29Z],	[NCBPS31Z],	[NCBPS13A],	[NCBPS13N],	[NCBPSECP],	[NCBPSPIC],	[NCBPS23N],	[NCBPS04A],	[NCBPS13F],	[NCBPS29R],	[NCBPS23Y],	[NCBPS10Z],	[NCBPS01P],	[NCBPS13K],	[NCBPS27C],	[NCBPS23A],	[NCBPS16Z],	[NCBPS00Z],	[NCBPS15Z],	[NCBPS23P],	[NCBPS17Z],	[NCBPS13G],	[NCBPS12Z],	[NCBPSXXX],	[NCBPS24Z],	[NCBPS23D],	[NCBPS01Z],	[NCBPS03Z],	[NCBPS01H],	[NCBPS19V],	[NCBPS02B],	[NCBPS01N],	[NCBPS23B],	[NCBPS01C],	[NCBPS11T],	[NCBPS01E],	[NCBPS29F],	[NCBPS29M],	[NCBPS01U],	[NCBPS06A],	[NCBPS23C],	[NCBPS23E]
into ActivityIP 
from qa.tbl_SUS_APCS_Extract as APCS
inner join MPI as MPI
	on MPI.BB5008_Pseudo_ID=APCS.BB5008_Pseudo_ID
left outer join RefOrganisation as RO
	on APCS.Der_Provider_Code=RO.[Org Code]
left outer join RefERICSiteLevelData as ES
	on APCS.Der_Provider_Site_Code=ES.SiteCode
left outer join RefERICTrustLevelData as ET
	on APCS.Der_Provider_Code=ET.TrustCode
left outer join RefNSRCIP as CO
	on case when National_POD_Code_Der1819='NELNE' then 'NEL'
		when National_POD_Code_Der1819='NELST' then 'NES'
		when National_POD_Code_Der1819 in ('RDAY','RNIGHT') then 'RP'
	else National_POD_Code_Der1819 end=CO.PODNSRC and APCS.HRG_Code_COST1819=CO.CurrencyCode
--left outer join (select ActivityType, BB5008_Pseudo_ID, BB5008_Pseudo_PLD_STP_Hospital_Spell_no, sum(CLN_Total_Cost) as CLN_Total_Cost from ActivitySSBASE group by ActivityType, BB5008_Pseudo_ID, BB5008_Pseudo_PLD_STP_Hospital_Spell_no) as PLD
	--on APCS.BB5008_Pseudo_ID=PLD.BB5008_Pseudo_ID
		--and APCS.BB5008_Pseudo_Hospital_Spell_No=PLD.BB5008_Pseudo_PLD_STP_Hospital_Spell_no
		--and PLD.ActivityType='IP'
where cast(case 
		when datepart(d,MPI.REG_DATE_OF_DEATH)<datepart(d,APCS.Admission_Date) then cast(datediff(mm,APCS.Admission_Date,MPI.REG_DATE_OF_DEATH)-1 as nvarchar(8))
		when datepart(d,MPI.REG_DATE_OF_DEATH)>=datepart(d,APCS.Admission_Date) then cast(datediff(mm,APCS.Admission_Date,MPI.REG_DATE_OF_DEATH) as nvarchar(8))
	end as int) <=23--between 0 and 23
and National_POD_Code_Der1819<>'APCUNK'


----------------------------------------------------------------------------------------------------------------------------------------------------
/*create the correct inpatient bed days file with added fields and linked to MPI*/
----------------------------------------------------------------------------------------------------------------------------------------------------
--drop table ActivityIPBDDAYS
select SUPatID 
	,MPI.BB5008_Pseudo_ID
	,'IPBDDAYS' as ActivityType
	,Admission_Date
	,Discharge_Date
	,Day as ActivityDay
	,Der_Provider_Code --provider code, 3 digits except for private
	,Der_Provider_Site_Code --provider code, 5 digits except for private. don't think will use but just in case I am including for now
	--,Der_Provider_Patient_Distance_Miles stupid to include here as already been travelled
	,[Org Type]
	,ET.TrustType as TrustType
	,ES.TrustType as SiteType
	,BB5008_Pseudo_APCS_Ident_Pseudo
	,case 
		when Der_Management_Type in ('EM','NE') then 'EM'
		when Der_Management_Type in ('RDA','RNA') then 'RA'
		else Der_Management_Type 
	end as PODSubGroup
	,case 
		when Der_Management_Type in ('EM','NE') then 'EM'
		when Der_Management_Type in ('RDA','RNA') then 'RA'
		else Der_Management_Type 
	end as PODSummaryGroup
	,'BED' as PODType
	,Administrative_Category
	,Der_Diagnosis_All
	,Spell_Dominant_Procedure_Der1819
	,0 as HRG_Code_COST1819
	,NCBFinal_Spell_ServiceLine_Der1819 --i believe this best field
	,NCBFinal_Spell_NPoC_Der1819 --i believe this best field
	,Responsible_Purchaser_Type_Der1819 --summary version
	,Responsible_Purchaser_Assignment_Method_Der1819 --detailed version
	,case when NCBFinal_Spell_ServiceLine_Der1819 like 'NCB%' or Der_Management_Type in ('RDA','RNA') or HRG_Code_COST1819 in ('SB97Z','SC97Z') then 'SS' else ''
		end as SSFlag
	,999999 as Der_Provider_Patient_Distance_Miles
	,cast(datediff(d,Discharge_Date,MPI.REG_DATE_OF_DEATH) as int) as DischargeDays--does this ned to be int?
	,cast(case 
		when datepart(d,REG_DATE_OF_DEATH)<datepart(d,Day) then cast(datediff(mm,Day,REG_DATE_OF_DEATH)-1 as nvarchar(8))
		when datepart(d,REG_DATE_OF_DEATH)>=datepart(d,Day) then cast(datediff(mm,Day,REG_DATE_OF_DEATH) as nvarchar(8))
	end as int) as ProximityToDeath
	,cast(datediff(d,Day,MPI.REG_DATE_OF_DEATH) as int) as ProximityToDeathDays--does this ned to be int?
	,case when cast(datediff(d,Day,MPI.REG_DATE_OF_DEATH) as int)=0 then '24hours'
		when cast(datediff(d,Day,MPI.REG_DATE_OF_DEATH) as int)=1 then '48hours'
		when cast(datediff(d,Day,MPI.REG_DATE_OF_DEATH) as int) between 2 and 6 then '1weeks'
		when cast(datediff(d,Day,MPI.REG_DATE_OF_DEATH) as int) between 7 and 13 then '2weeks'
	end as ProximityToDeathDaysCategory
	,STP18CD
	,CCGResponsible
	,DER_AGE_AT_DEATH
	,LocationType
	,CauseGroupLL
into ActivityIPBDDAYS
from [qa].[tbl_SUS_APCS_Extract] as APCS
inner join MPI as MPI
	on MPI.BB5008_Pseudo_ID=APCS.BB5008_Pseudo_ID
left outer join RefOrganisation as RO
	on APCS.Der_Provider_Code=RO.[Org Code]
cross join dbo.RefMonthYearDay as MYD
left outer join RefERICSiteLevelData as ES
	on APCS.Der_Provider_Site_Code=ES.SiteCode
left outer join RefERICTrustLevelData as ET
	on APCS.Der_Provider_Code=ET.TrustCode
where Day>=Admission_Date and Day<=Discharge_Date
and Der_Management_Type in ('EM','NE','EL')
and cast(case 
		when datepart(d,REG_DATE_OF_DEATH)<datepart(d,Day) then cast(datediff(mm,Day,MPI.REG_DATE_OF_DEATH)-1 as nvarchar(8))
		when datepart(d,REG_DATE_OF_DEATH)>=datepart(d,Day) then cast(datediff(mm,Day,MPI.REG_DATE_OF_DEATH) as nvarchar(8))
end as int)<=23--between 0 and 23
and National_POD_Code_Der1819<>'APCUNK'
--and REG_DATE_OF_DEATH<Discharge_Date - just here for checking