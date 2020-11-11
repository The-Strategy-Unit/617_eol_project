----------------------------------------------------------------------------------------------------------------------------------------------------
/*create the correct outpatient activity file with added fields and linked to MPI*/
----------------------------------------------------------------------------------------------------------------------------------------------------
--drop table ActivityOP	
select SUPatID
	,MPI.BB5008_Pseudo_ID 
	,'OP' as ActivityType
	,Carer_Support_Indicator
	,Ethnic_Category --why not group?? like IP???
	,Appointment_Date
	,Der_Provider_Code --provider code, 3 digits except for private
	,Der_Provider_Site_Code --provider code, 5 digits except for private. don't think will use but just in case I am including for now
	,[Org Type]
	,National_POD_Code_Der1819
	,case --finish when looked at der pod field??
		when National_POD_Code_Der1819 like '%FA%' /*and National_POD_Code_Der1819<>'OPPROCFA'*/ then 'OPFA'
		when National_POD_Code_Der1819 like '%FUP%' /*and National_POD_Code_Der1819<>'OPPROCFUP'*/ then 'OPFUP'
		else 'OP'
	end as PODSubGroup
	,case when National_POD_Code_Der1819 in ('OPFAMPCL','OPFASPCL') and Treatment_Function_Code not in ('360','812') and datediff(d,Referral_Request_Received_Date,Appointment_Date) between 0 and 1 then 'AE' 
		else 'OP' 
	end as PODSummaryGroup
	,case when National_POD_Code_Der1819 in ('OPFAMPCL','OPFASPCL') and Treatment_Function_Code not in ('360','812') and datediff(d,Referral_Request_Received_Date,Appointment_Date) between 0 and 1 then 'Unplanned' 
		else 'PlannedContact' 
	end as PODType
	,Administrative_Category
	,Main_Specialty_Code
	,Treatment_Function_Code
	,Der_Diagnosis_All
	,Der_Procedure_All--just first? or dominant9
	,case when Der_Procedure_All like '%X70%' or Der_Procedure_All like '%X71%' or Der_Procedure_All like '%X72%' or Der_Procedure_All like '%X73%' 
		then 1 else 0 end as ChemotherapyIndicator
	,Attend_Dominant_Procedure_Der1819
	,case
		when HRG_Code_Other_Cost1819 is not null then HRG_Code_Other_Cost1819
	else HRG_Code_OPP_Cost1819 end as HRG --uses 'other' when it's WF% but otherwise it's null so then used OPPROC code
	--,Attend_Core_HRG_Der1819 --the actual derived HRG but not all are OPP
	,Grand_Total_Payment_MFF_Cost1819
	,CO.NAUCost as RefCostPrice
	,Der_Staff_Type
	,pregrp_exclusion_reason_der1819
	,tariff_exclusion_reason_cost1819
	,Cost_Type_Cost1819
	--,NCBFinal_Spell_ServiceLine_Der1819 --IP EQUIVALENT - nneds to be checked
	,NCBFinal_ServiceLine_Der1819
	--,NCBFinal_Spell_NPoC_Der1819--IP EQUIVALENT - nneds to be checked
	,NCBFinal_NPoC_Der1819 --i believe this best field
	,Responsible_Purchaser_Type_Der1819 --summary version
	,Responsible_Purchaser_Assignment_Method_Der1819 --detailed version
	,case when (Responsible_Purchaser_Type_Der1819='Comm Hub' /*NCBFinal_Spell_ServiceLine_Der1819 like 'NCB%'*/ or HRG_Code_OPP_Cost1819 in ('SB97Z','SC97Z')) and Administrative_Category<>'02' then 'SS'
		when Responsible_Purchaser_Type_Der1819='Region' and Administrative_Category<>'02' then 'Region'
		when Responsible_Purchaser_Type_Der1819='CCG' and Administrative_Category<>'02'then 'CCG'
		when Administrative_Category='02' then 'Private'
		else 'Other'
	end as SSFlag
	,Der_Provider_Patient_Distance_Miles
	,cast(case 
		when datepart(d,MPI.REG_DATE_OF_DEATH)<datepart(d,OP.Appointment_Date) then cast(datediff(mm,OP.Appointment_Date,MPI.REG_DATE_OF_DEATH)-1 as nvarchar(8))
		when datepart(d,MPI.REG_DATE_OF_DEATH)>=datepart(d,OP.Appointment_Date) then cast(datediff(mm,OP.Appointment_Date,MPI.REG_DATE_OF_DEATH) as nvarchar(8))
	end as int) as [ProximityToDeath]
	,cast(datediff(d,OP.Appointment_Date,MPI.REG_DATE_OF_DEATH) as int) as ProximityToDeathDays--does this ned to be int?
	,case when cast(datediff(d,OP.Appointment_Date,MPI.REG_DATE_OF_DEATH) as int)=0 then '24hours'
		when cast(datediff(d,OP.Appointment_Date,MPI.REG_DATE_OF_DEATH) as int)=1 then '48hours'
		when cast(datediff(d,OP.Appointment_Date,MPI.REG_DATE_OF_DEATH) as int) between 2 and 6 then '1weeks'
		when cast(datediff(d,OP.Appointment_Date,MPI.REG_DATE_OF_DEATH) as int) between 7 and 13 then '2weeks'
	end as ProximityToDeathDaysCategory
	,STP18CD
	,CCGResponsible
	,DER_AGE_AT_DEATH
	,LocationType
	,CauseGroupLL
	,[Referral_Request_Received_Date]
	,Attend_Core_HRG_Der1819
,Attend_Unbundled_HRGs_Der1819
,HRG_Code_OPP_Cost1819
,HRG_Code_Other_Cost1819
into ActivityOP
from [NHSE_BB_5008].qa.tbl_SUS_OP_Extract as OP
inner join MPI as MPI
	on MPI.BB5008_Pseudo_ID=OP.BB5008_Pseudo_ID
left outer join RefOrganisation as RO
	on OP.Der_Provider_Code=RO.[Org Code]
left outer join RefNSRCOP as CO
	on OP.HRG_Code_Other_Cost1819=CO.CurrencyCode
		and OP.Treatment_Function_Code=CO.ServiceCode
		and OP.Der_Staff_Type=CO.StaffType
where 
cast(case 
		when datepart(d,REG_DATE_OF_DEATH)<datepart(d,Appointment_Date) then cast(datediff(mm,Appointment_Date,REG_DATE_OF_DEATH)-1 as nvarchar(8))
		when datepart(d,REG_DATE_OF_DEATH)>=datepart(d,Appointment_Date) then cast(datediff(mm,Appointment_Date,REG_DATE_OF_DEATH) as nvarchar(8))
	end as int)<=23-- between 0 and 23
and Attendance_Status in ('5','6')
and National_POD_Code_Der1819 is not null --83