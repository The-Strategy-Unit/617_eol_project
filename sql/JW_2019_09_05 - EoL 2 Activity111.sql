----------------------------------------------------------------------------------------------------------------------------------------------------
/*create the correct 111 activity file with added fields and linked to MPI*/
------------------------------------------------------------------------------------------------------------------------------------------------------drop table activity111
--drop table Activity111
select SUPatID
	,MPI.BB5008_Pseudo_ID 
	,'111' as ActivityType
	,Call_Connect_Date					
	,'111' as PODSubGroup
	,'111' as PODSummaryGroup	
	,'Unplanned' as PODType		
    ,[ORGANISATION_CODE_(CODE_OF_PROVIDER)]	as Provider	
    ,CareHome								
	,''as SSFlag
	,'999999' as Der_Provider_Patient_Distance_Miles
	,cast(case 
		when datepart(d,MPI.REG_DATE_OF_DEATH)<datepart(d,IUC.Call_Connect_Date) then cast(datediff(mm, IUC.Call_Connect_Date,MPI.REG_DATE_OF_DEATH)-1 as nvarchar(8))
		when datepart(d,MPI.REG_DATE_OF_DEATH)>=datepart(d, IUC.Call_Connect_Date) then cast(datediff(mm, IUC.Call_Connect_Date,MPI.REG_DATE_OF_DEATH) as nvarchar(8))
	end as int) as ProximityToDeath
	,cast(datediff(d, IUC.Call_Connect_Date,MPI.REG_DATE_OF_DEATH) as int) as ProximityToDeathDays--does this need to be int?
	,case when cast(datediff(d, IUC.Call_Connect_Date,MPI.REG_DATE_OF_DEATH) as int)=0 then '24hours'
		when cast(datediff(d, IUC.Call_Connect_Date,MPI.REG_DATE_OF_DEATH) as int)=1 then '48hours'
		when cast(datediff(d, IUC.Call_Connect_Date,MPI.REG_DATE_OF_DEATH) as int) between 2 and 6 then '1weeks'
		when cast(datediff(d, IUC.Call_Connect_Date,MPI.REG_DATE_OF_DEATH) as int) between 7 and 13 then '2weeks'
	end as ProximityToDeathDaysCategory
	,REG_DATE_OF_DEATH	
	,STP18CD
	,CCGResponsible
	,DER_AGE_AT_DEATH
	,LocationType
	,CauseGroupLL
into Activity111
from qa.tbl_111_Extract as IUC
inner join [GEM\Jwiltshire].MPI as MPI
	on MPI.BB5008_Pseudo_ID=IUC.BB5008_Pseudo_ID
where 
cast(case 
		when datepart(d,MPI.REG_DATE_OF_DEATH)<datepart(d,IUC.Call_Connect_Date) then cast(datediff(mm, IUC.Call_Connect_Date,MPI.REG_DATE_OF_DEATH)-1 as nvarchar(8))
		when datepart(d,MPI.REG_DATE_OF_DEATH)>=datepart(d, IUC.Call_Connect_Date) then cast(datediff(mm, IUC.Call_Connect_Date,MPI.REG_DATE_OF_DEATH) as nvarchar(8))
	end as int)<=23-- between 0 and 23

select count(*) from Activity111
select distinct PODType
from Activity111

--simplified logic n.b. 
datediff(mm, IUC.Call_Connect_Date,MPI.REG_DATE_OF_DEATH)-
	(case when datepart(d,MPI.REG_DATE_OF_DEATH) < datepart(d, IUC.Call_Connect_Date) then 1 else 0
		end) between 0 and 23