----------------------------------------------------------------------------------------------------------------------------------------------------
/*IAPT file with added fields and linked to MPI*/
----------------------------------------------------------------------------------------------------------------------------------------------------
--drop table ActivityIAPT
select SUPatID
	,MPI.BB5008_Pseudo_ID 
	,'IAPT' as ActivityType
	,APPOINTMENT
	,'IAPT' as PODSubGroup
	,'IAPT' as PODSummaryGroup
	,'PlannedContact' as PODType
	,''as SSFlag
	,999999 as Der_Provider_Patient_Distance_Miles
	,cast(case 
		when datepart(d,MPI.REG_DATE_OF_DEATH)<datepart(d,IAPTA.APPOINTMENT) then cast(datediff(mm,IAPTA.APPOINTMENT,MPI.REG_DATE_OF_DEATH)-1 as nvarchar(8))
		when datepart(d,MPI.REG_DATE_OF_DEATH)>=datepart(d,IAPTA.APPOINTMENT) then cast(datediff(mm,IAPTA.APPOINTMENT,MPI.REG_DATE_OF_DEATH) as nvarchar(8))
	end as int) as ProximityToDeath
	,cast(datediff(d,IAPTA.APPOINTMENT,MPI.REG_DATE_OF_DEATH) as int) as ProximityToDeathDays--does this ned to be int?
	,case when cast(datediff(d,IAPTA.APPOINTMENT,MPI.REG_DATE_OF_DEATH) as int)=0 then '24hours'
		when cast(datediff(d,IAPTA.APPOINTMENT,MPI.REG_DATE_OF_DEATH) as int)=1 then '48hours'
		when cast(datediff(d,IAPTA.APPOINTMENT,MPI.REG_DATE_OF_DEATH) as int) between 2 and 6 then '1weeks'
		when cast(datediff(d,IAPTA.APPOINTMENT,MPI.REG_DATE_OF_DEATH) as int) between 7 and 13 then '2weeks'
	end as ProximityToDeathDaysCategory
	,STP18CD
	,CCGResponsible
	,DER_AGE_AT_DEATH
	,LocationType
	,CauseGroupLL
into ActivityIAPT
from (select BB5008_Pseudo_ID, BB5008_Pseudo_IAPT_PERSON_ID
	  from qa.tbl_IAPT_Person_Extract 
	  group by BB5008_Pseudo_ID, BB5008_Pseudo_IAPT_PERSON_ID) as IAPTP
inner join qa.tbl_IAPT_Appointment_Extract as IAPTA
	on IAPTP.BB5008_Pseudo_IAPT_PERSON_ID=IAPTA.BB5008_Pseudo_IAPT_PERSON_ID
inner join MPI as MPI
	on MPI.BB5008_Pseudo_ID=IAPTP.BB5008_Pseudo_ID
where 
cast(case 
		when datepart(d,MPI.REG_DATE_OF_DEATH)<datepart(d,IAPTA.APPOINTMENT) then cast(datediff(mm,IAPTA.APPOINTMENT,MPI.REG_DATE_OF_DEATH)-1 as nvarchar(8))
		when datepart(d,MPI.REG_DATE_OF_DEATH)>=datepart(d,IAPTA.APPOINTMENT) then cast(datediff(mm,IAPTA.APPOINTMENT,MPI.REG_DATE_OF_DEATH) as nvarchar(8))
	end as int)<=23-- between 0 and 23
and ATTENDANCE in ('5','6')