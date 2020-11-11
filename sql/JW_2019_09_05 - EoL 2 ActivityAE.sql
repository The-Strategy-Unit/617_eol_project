----------------------------------------------------------------------------------------------------------------------------------------------------
/*create the correct a&e activity file with added fields and linked to MPI*/
----------------------------------------------------------------------------------------------------------------------------------------------------
--drop table ActivityAE	
select SUPatID
	,MPI.BB5008_Pseudo_ID 
	,'AE' as ActivityType
	,Carer_Support_Indicator
	,Ethnic_Category --why not group?? like IP???
	,Arrival_Date
	,Der_Provider_Code --provider code, 3 digits except for private
	,Der_Provider_Site_Code --provider code, 5 digits except for private. don't think will use but just in case I am including for now
	,[Org Type]
	,ET.TrustType as TrustType
	,ES.TrustType as SiteType
	,National_POD_Code_Der1819
	,'AE' as PODSubGroup
	,case when AEA_Attendance_Category like 2 then 'OP' else 'AE' end as PODSummaryGroup
	,case when AEA_Attendance_Category like 2 then 'PlannedContact' else 'Unplanned' end as PODType
	,Der_Diagnosis_All
	,Der_Investigation_All
	,Der_Treatment_All
	,AEA_Arrival_Mode
	,Tariff_Type_Cost1819
	,HRG_Code_Cost1819
	,Grand_Total_Payment_MFF_Cost1819
	,NULL as NCBPST_ServiceLine_Der1819 --na to spec services
	,NULL as NCBPST_NPoC_Der1819 --na to spec services
	,Responsible_Purchaser_Type_Der1819 --summary version
	,Responsible_Purchaser_Assignment_Method_Der1819 --detailed version
	,'CCG'as SSFlag
	,Der_Provider_Patient_Distance_Miles
	,cast(case 
		when datepart(d,REG_DATE_OF_DEATH)<datepart(d,Arrival_Date) then cast(datediff(mm,Arrival_Date,REG_DATE_OF_DEATH)-1 as nvarchar(8))
		when datepart(d,REG_DATE_OF_DEATH)>=datepart(d,Arrival_Date) then cast(datediff(mm,Arrival_Date,REG_DATE_OF_DEATH) as nvarchar(8))
	end as int) as [ProximityToDeath]
	,cast(datediff(d,Arrival_Date,MPI.REG_DATE_OF_DEATH) as int) as ProximityToDeathDays
	,case when cast(datediff(d,Arrival_Date,MPI.REG_DATE_OF_DEATH) as int)=0 then '24hours'
		when cast(datediff(d,Arrival_Date,MPI.REG_DATE_OF_DEATH) as int)=1 then '48hours'
		when cast(datediff(d,Arrival_Date,MPI.REG_DATE_OF_DEATH) as int) between 2 and 6 then '1weeks'
		when cast(datediff(d,Arrival_Date,MPI.REG_DATE_OF_DEATH) as int) between 7 and 13 then '2weeks'
	end as ProximityToDeathDaysCategory
	,STP18CD
	,CCGResponsible
	,DER_AGE_AT_DEATH
	,LocationType
	,CauseGroupLL
into ActivityAE
from [NHSE_BB_5008].qa.tbl_SUS_AEA_Extract as AE 
inner join MPI as MPI
	on MPI.BB5008_Pseudo_ID=AE.BB5008_Pseudo_ID
left outer join RefOrganisation as RO
	on AE.Der_Provider_Code=RO.[Org Code]
left outer join RefERICSiteLevelData as ES
	on AE.Der_Provider_Site_Code=ES.SiteCode
left outer join RefERICTrustLevelData as ET
	on AE.Der_Provider_Code=ET.TrustCode
where 
cast(case 
		when datepart(d,REG_DATE_OF_DEATH)<datepart(d,Arrival_Date) then cast(datediff(mm,Arrival_Date,MPI.REG_DATE_OF_DEATH)-1 as nvarchar(8))
		when datepart(d,REG_DATE_OF_DEATH)>=datepart(d,Arrival_Date) then cast(datediff(mm,Arrival_Date,MPI.REG_DATE_OF_DEATH) as nvarchar(8))
	end as int)<=23-- between 0 and 23

