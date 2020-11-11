----------------------------------------------------------------------------------------------------------------------------------------------------
/*patient MPI additional information creation*/
----------------------------------------------------------------------------------------------------------------------------------------------------
/*inpatient*/
----------------------------------------------------------------------------------------------------------------------------------------------------
--drop table #MPIAdditionalRaw
select BB5008_Pseudo_ID
	,Admission_Date as ActivityDate
	,left(Ethnic_Group,1) as Ethnic
	,Carer_Support_Indicator
	,case 
		when Der_Diagnosis_All like '%Z602%' then 1 else 0 
			end as LivesAloneIndicator -- actually could take this off if I wanted. Can only be 0 or 1 instance per spell
	/*,sum(case 
		when Der_Diagnosis_All like '%' + Diag + '%' and Age_At_Start_of_Spell_SUS>=65 then 1 else 0
			end) as FrailtyIndicator*/
into #MPIAdditionalRaw
from ActivityIP 
cross join RefGeriatricGiants as GG
group by BB5008_Pseudo_ID
	,Admission_Date
	,Ethnic_Group
	,Carer_Support_Indicator
	,case 
		when Der_Diagnosis_All like '%Z602%' then 1 else 0 
	end 

----------------------------------------------------------------------------------------------------------------------------------------------------
/*outpatient*/
----------------------------------------------------------------------------------------------------------------------------------------------------
insert into #MPIAdditionalRaw
select BB5008_Pseudo_ID
	,Appointment_Date as ActivityDate
	,left(Ethnic_Category,1) as Ethnic
	,Carer_Support_Indicator
	,case 
		when Der_Diagnosis_All like '%Z602%' then 1 else 99 -- can match more than on diagnosis in the list, hence causing duplicate rows
			end as LivesAloneIndicator -- actually could take this off if I wanted. Can only be 0 or 1 instance per spell
	/*,sum(case 
		when Der_Diagnosis_All like '%' + Diag + '%' and Age_at_CDS_Activity_Date>=65 then 1 else 0
			end) as FrailtyIndicator*/
from ActivityOP
cross join RefGeriatricGiants as GG
group by BB5008_Pseudo_ID
	,Appointment_Date
	,Ethnic_Category
	,Carer_Support_Indicator
	,case 
		when Der_Diagnosis_All like '%Z602%' then 1 else 99
	end
	
----------------------------------------------------------------------------------------------------------------------------------------------------
/*a&e*/
----------------------------------------------------------------------------------------------------------------------------------------------------
insert into #MPIAdditionalRaw
select BB5008_Pseudo_ID
	,Arrival_Date as ActivityDate
	,left(Ethnic_Category,1) as Ethnic
	,Carer_Support_Indicator
	,99 as LivesAloneIndicator
	--,0 as FrailtyIndicator
from ActivityAE
group by BB5008_Pseudo_ID
	,Arrival_Date
	,Ethnic_Category
	,Carer_Support_Indicator

----------------------------------------------------------------------------------------------------------------------------------------------------
/*MH*/
----------------------------------------------------------------------------------------------------------------------------------------------------
insert into #MPIAdditionalRaw
select BB5008_Pseudo_ID
	,max(case when RecordEndDate is not null then RecordEndDate else RecordStartDate end) as ActivityDate
	,left(NHSDEthnicity,1) as Ethnic
	,null as Carer_Support_Indicator
	,99 as LivesAloneIndicator
	--,0 as FrailtyIndicator
from [qa].[tbl_MHSDS_MHS001MPI_Extract] as a
group by BB5008_Pseudo_ID
	,NHSDEthnicity

----------------------------------------------------------------------------------------------------------------------------------------------------
/*IAPT so small I didn't bother*/
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
/*CC would only replicate IP*/
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
/*IPBD would only replicate IP*/
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
/*Community - when available*/
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
/*create unique files (3) from the raw data*/
----------------------------------------------------------------------------------------------------------------------------------------------------
--drop table #MPIAdditional --max is 20
select BB5008_Pseudo_ID
	,case when sum(LAI1)=1 then 1
		when sum(LAI2)=1 then 0
		when sum(LAI3)=1 then 99 
	end as LivesAlone
	/*,case 
		when sum(FrailtyIndicator)>=1 then 1 else 0
	end as FrailtyIndicator*/
into #MPIAdditional
from
	(select BB5008_Pseudo_ID
		,LivesAloneIndicator
		,case when LivesAloneIndicator=1 then 1 else 0 end as LAI1
		,case when LivesAloneIndicator=0 then 1 else 0 end as LAI2
		,case when LivesAloneIndicator=99 then 1 else 0 end as LAI3
		/*,sum(FrailtyIndicator) as FrailtyIndicator*/
	from #MPIAdditionalRaw
	--where BB5008_Pseudo_ID='000CC980542B48E7DF0815D34FEEED3B5978E93CA8E47AB9661D503841C2CF79'
	group by BB5008_Pseudo_ID,LivesAloneIndicator
	--order by BB5008_Pseudo_ID,LivesAloneIndicator
	) as A
group by BB5008_Pseudo_ID

--drop table #MPIAdditionalEthnic
select BB5008_Pseudo_ID
	,ActivityDate
	,Ethnic
	,row_number() over (partition by BB5008_Pseudo_ID order by case when Ethnic in ('A','B','C','D','E','F','G','H','J','K','L','M','N','P','R','S') then 1 when Ethnic='Z' then 2 else 3 end, ActivityDate desc) as EthnicRefIndex
into #MPIAdditionalEthnic
from #MPIAdditionalRaw
where left(Ethnic,1) in ('A','B','C','D','E','F','G','H','J','K','L','M','N','P','R','S','Z')
group by BB5008_Pseudo_ID
	,ActivityDate
	,Ethnic

--drop table #MPIAdditionalCarer
select BB5008_Pseudo_ID
	,ActivityDate
	,Carer_Support_Indicator
	,row_number() over (partition by BB5008_Pseudo_ID order by ActivityDate desc) as CarerRefIndex
into #MPIAdditionalCarer
from #MPIAdditionalRaw
where Carer_Support_Indicator in ('01','02')

----------------------------------------------------------------------------------------------------------------------------------------------------
/*bring files back together, joining into unique patient information*/
----------------------------------------------------------------------------------------------------------------------------------------------------
--drop table MPIAddition
select A.BB5008_Pseudo_ID
	,B.Ethnic
	,C.Carer_Support_Indicator
	,LivesAlone
	--,FrailtyIndicator
into MPIAddition
from #MPIAdditional as A
left outer join --every one in this list even if no valid ethnic code
	(select BB5008_Pseudo_ID
	,Ethnic
	from #MPIAdditionalEthnic
	where EthnicRefIndex=1) as B
		on A.BB5008_Pseudo_ID=B.BB5008_Pseudo_ID
left outer join --everyone ditto
	(select BB5008_Pseudo_ID
	,Carer_Support_Indicator
	from #MPIAdditionalCarer
	where CarerRefIndex=1) as C
		on A.BB5008_Pseudo_ID=C.BB5008_Pseudo_ID

select count(*) from MPIAddition
select count(*) from MPI

update MPI
set Ethnic=isnull(MPIA.Ethnic,9)
	,CarerSuport=isnull(MPIA.Carer_Support_Indicator,'99')
	,LivesAlone=isnull(MPIA.LivesAlone,99)
	--,FrailtyMarker=isnull(MPIA.FrailtyIndicator,0)
from MPI as MPI
left outer join MPIAddition as MPIA
	on MPI.BB5008_Pseudo_ID=MPIA.BB5008_Pseudo_ID
/*set back as was
update MPI
set Ethnic='99'
,CarerSuport='00'
,LivesAlone=0
,FrailtyMarker=0
*/

select count(distinct BB5008_Pseudo_ID), count(*)
from MPIAddition

----------------------------------------------------------------------------------------------------------------------------------------------------
/*FrailtyCOD*/
----------------------------------------------------------------------------------------------------------------------------------------------------
select BB5008_Pseudo_ID
	,1 as FrailtyIndicator
into #CODFrail
from MPI as MPI
cross join RefGeriatricGiants as GG
where CODCodes like '%' + Diag + '%'
	and DER_AGE_AT_DEATH>=65
group by BB5008_Pseudo_ID

select count(distinct BB5008_Pseudo_ID), count(*)
from #CODFrail

update MPI
set FrailtyCODCodes=1
from MPI as MPI
inner join 
		(select BB5008_Pseudo_ID
			,1 as FrailtyIndicator
		from MPI as MPI
		cross join RefGeriatricGiants as GG
		where CODCodes like '%' + Diag + '%'
			and DER_AGE_AT_DEATH>=65
		group by BB5008_Pseudo_ID) as A
	on MPI.BB5008_Pseudo_ID=A.BB5008_Pseudo_ID

select count(distinct BB5008_Pseudo_ID), count(*)
from MPI

select count(*)
from MPI
where FrailtyCODCodes=1