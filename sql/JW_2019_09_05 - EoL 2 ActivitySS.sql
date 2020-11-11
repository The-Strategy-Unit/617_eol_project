----------------------------------------------------------------------------------------------------------------------------------------------------
/*create the correct SS activity file with added fields and linked to MPI*/
----------------------------------------------------------------------------------------------------------------------------------------------------
--drop table ActivitySS
select SUPatID
	,MPI.BB5008_Pseudo_ID
	,0 as Act
	,case when CLN_Activity_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_Date as date)	
		when CLN_Activity_End_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_End_Date as date)
		else '20'+cast(case when DER_Activity_Month between 1 and 9 then substring(DER_Activity_Year,1,2) else substring(DER_Activity_Year,4,2) end as varchar(4)) +'-'+ cast('0'+ case when DER_Activity_Month between 1 and 9 then DER_Activity_Month+3 else DER_Activity_Month-9 end as varchar(2)) +'-15' 
	end as ActivityDay
	,'SS' as ActivityType
	,'SS' as SSFlag
	,SS.PODsubGroup
	,'' PODSummaryGroup
	,case when SS.PODsubGroup is not null then F3 else 'Unknown' end as PODType
	,DER_NHSE_ServiceLine
	,Service_Line_Code
    ,Service_Line_Desc
    ,NPoC_CRG_Code
    ,NPoC_CRG_Desc
    ,PoC
    ,Highly_Spec
	,CauseGroupLL
	,STP18CD
	,LocationType
	,DER_AGE_AT_DEATH
	,Der_Provider_Code
	,cast(case 
		when datepart(d,REG_DATE_OF_DEATH)<datepart(d,case when CLN_Activity_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_Date as date)	
		when CLN_Activity_End_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_End_Date as date)
		else '20'+cast(case when DER_Activity_Month between 1 and 9 then substring(DER_Activity_Year,1,2) else substring(DER_Activity_Year,4,2) end as varchar(4)) +'-'+ cast('0'+ case when DER_Activity_Month between 1 and 9 then DER_Activity_Month+3 else DER_Activity_Month-9 end as varchar(2)) +'-15' 
		end) then cast(datediff(mm,case when CLN_Activity_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_Date as date)	
		when CLN_Activity_End_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_End_Date as date)
		else '20'+cast(case when DER_Activity_Month between 1 and 9 then substring(DER_Activity_Year,1,2) else substring(DER_Activity_Year,4,2) end as varchar(4)) +'-'+ cast('0'+ case when DER_Activity_Month between 1 and 9 then DER_Activity_Month+3 else DER_Activity_Month-9 end as varchar(2)) +'-15' 
		end,REG_DATE_OF_DEATH)-1 as nvarchar(8))
		when datepart(d,REG_DATE_OF_DEATH)>=datepart(d,case when CLN_Activity_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_Date as date)	
		when CLN_Activity_End_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_End_Date as date)
		else '20'+cast(case when DER_Activity_Month between 1 and 9 then substring(DER_Activity_Year,1,2) else substring(DER_Activity_Year,4,2) end as varchar(4)) +'-'+ cast('0'+ case when DER_Activity_Month between 1 and 9 then DER_Activity_Month+3 else DER_Activity_Month-9 end as varchar(2)) +'-15' 
		end) then cast(datediff(mm,case when CLN_Activity_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_Date as date)	
		when CLN_Activity_End_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_End_Date as date)
		else '20'+cast(case when DER_Activity_Month between 1 and 9 then substring(DER_Activity_Year,1,2) else substring(DER_Activity_Year,4,2) end as varchar(4)) +'-'+ cast('0'+ case when DER_Activity_Month between 1 and 9 then DER_Activity_Month+3 else DER_Activity_Month-9 end as varchar(2)) +'-15' 
		end,REG_DATE_OF_DEATH) as nvarchar(8))
	end as int) as ProximityToDeath
	,datediff(d,case when CLN_Activity_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_Date as date) when CLN_Activity_End_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_End_Date as date) else '20'+cast(case when DER_Activity_Month between 1 and 9 then substring(DER_Activity_Year,1,2) else substring(DER_Activity_Year,4,2) end as varchar(4)) +'-'+ cast('0'+ case when DER_Activity_Month between 1 and 9 then DER_Activity_Month+3 else DER_Activity_Month-9 end as varchar(2)) + '-15' end,MPI.REG_DATE_OF_DEATH) 
	as ProximityToDeathDays
	,case when cast(datediff(d,case when CLN_Activity_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_Date as date)	
		when CLN_Activity_End_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_End_Date as date)
		else '20'+cast(case when DER_Activity_Month between 1 and 9 then substring(DER_Activity_Year,1,2) else substring(DER_Activity_Year,4,2) end as varchar(4)) +'-'+ cast('0'+ case when DER_Activity_Month between 1 and 9 then DER_Activity_Month+3 else DER_Activity_Month-9 end as varchar(2)) +'-15' 
		end,MPI.REG_DATE_OF_DEATH) as int)=0 then '24hours'
		when cast(datediff(d,case when CLN_Activity_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_Date as date)	
		when CLN_Activity_End_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_End_Date as date)
		else '20'+cast(case when DER_Activity_Month between 1 and 9 then substring(DER_Activity_Year,1,2) else substring(DER_Activity_Year,4,2) end as varchar(4)) +'-'+ cast('0'+ case when DER_Activity_Month between 1 and 9 then DER_Activity_Month+3 else DER_Activity_Month-9 end as varchar(2)) +'-15' 
		end,MPI.REG_DATE_OF_DEATH) as int)=1 then '48hours'
		when cast(datediff(d,case when CLN_Activity_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_Date as date)	
		when CLN_Activity_End_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_End_Date as date)
		else '20'+cast(case when DER_Activity_Month between 1 and 9 then substring(DER_Activity_Year,1,2) else substring(DER_Activity_Year,4,2) end as varchar(4)) +'-'+ cast('0'+ case when DER_Activity_Month between 1 and 9 then DER_Activity_Month+3 else DER_Activity_Month-9 end as varchar(2)) +'-15' 
		end,MPI.REG_DATE_OF_DEATH) as int) between 2 and 6 then '1weeks'
		when cast(datediff(d,case when CLN_Activity_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_Date as date)	
		when CLN_Activity_End_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_End_Date as date)
		else '20'+cast(case when DER_Activity_Month between 1 and 9 then substring(DER_Activity_Year,1,2) else substring(DER_Activity_Year,4,2) end as varchar(4)) +'-'+ cast('0'+ case when DER_Activity_Month between 1 and 9 then DER_Activity_Month+3 else DER_Activity_Month-9 end as varchar(2)) +'-15' 
		end,MPI.REG_DATE_OF_DEATH) as int) between 7 and 13 then '2weeks'
	end as ProximityToDeathDaysCategory
	,sum(CLN_Total_Cost) as SSCost
into ActivitySS
from 
	--select SS.* into #tempss from
	(select BB5008_Pseudo_ID
		,BB5008_Pseudo_PLD_STP_Hospital_Spell_no
		,BB5008_Pseudo_PLD_CLN_Attendance_Identifier
		,case when DER_National_POD_Code is null or DER_National_POD_Code='UNKNOWN' then DER_National_POD_Code_2018 else DER_National_POD_Code end as PODsubGroup
		,DER_Provider_Code
		,CLN_Activity_Date
		,DER_Activity_Month
		,DER_Activity_Year
		,DER_NHSE_ServiceLine
		,DER_CCG_Code
		,DER_Commissioner_Code
		,CLN_Activity_End_Date 
		,CLN_Total_Cost
	from [qa].[SLAM_PLD_Extract_20200318]
	where CLN_Total_Cost<>0 and CLN_Total_Cost is not null
		union all
	select BB5008_Pseudo_ID
		,BB5008_Pseudo_Device_STP_Hospital_Spell_no
		,BB5008_Pseudo_Device_CLN_Attendance_Identifier
		,'DEVICE-FILE' as PODsubGroup
		,DER_Provider_Code
		,CLN_Activity_Date
		,DER_Activity_Month
		,DER_Activity_Year
		,DER_NHSE_ServiceLine
		,DER_CCG_Code
		,DER_Commissioner_Code
		,'' as CLN_Activity_End_Date
		,CLN_Total_Cost 
	from [qa].[tbl_SLAM_Devices_Extract_20200318]
	where CLN_Total_Cost<>0 and CLN_Total_Cost is not null
		union all
	select BB5008_Pseudo_ID
		,BB5008_Pseudo_Drug_STP_Hospital_Spell_no
		,BB5008_Pseudo_Drug_CLN_Attendance_Identifier
		,'DRUG-FILE' as PODsubGroup
		,DER_Provider_Code
		,CLN_Activity_Date
		,DER_Activity_Month
		,DER_Activity_Year
		,DER_NHSE_ServiceLine
		,DER_CCG_Code
		,DER_Commissioner_Code
		,'' as CLN_Activity_End_Date 
		,CLN_Total_Cost
	from [qa].[tbl_SLAM_Drugs_Extract_20200318]
	where CLN_Total_Cost<>0 and CLN_Total_Cost is not null
	) as SS
inner join MPI as MPI
	on SS.BB5008_Pseudo_ID=MPI.BB5008_Pseudo_ID
left outer join [NHSE_Reference].[dbo].[tbl_Ref_NCB_NPoC_Map] as PC
	on SS.DER_NHSE_ServiceLine=PC.Service_Line_Code
left outer join RefSSPODs as P
	on SS.PODsubGroup=P.PODSS
where cast(case 
		when datepart(d,REG_DATE_OF_DEATH)<datepart(d,case when CLN_Activity_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_Date as date)	
		when CLN_Activity_End_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_End_Date as date)
		else '20'+cast(case when DER_Activity_Month between 1 and 9 then substring(DER_Activity_Year,1,2) else substring(DER_Activity_Year,4,2) end as varchar(4)) +'-'+ cast('0'+ case when DER_Activity_Month between 1 and 9 then DER_Activity_Month+3 else DER_Activity_Month-9 end as varchar(2)) +'-15' 
		end) then cast(datediff(mm,case when CLN_Activity_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_Date as date)	
		when CLN_Activity_End_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_End_Date as date)
		else '20'+cast(case when DER_Activity_Month between 1 and 9 then substring(DER_Activity_Year,1,2) else substring(DER_Activity_Year,4,2) end as varchar(4)) +'-'+ cast('0'+ case when DER_Activity_Month between 1 and 9 then DER_Activity_Month+3 else DER_Activity_Month-9 end as varchar(2)) +'-15' 
		end,REG_DATE_OF_DEATH)-1 as nvarchar(8))
		when datepart(d,REG_DATE_OF_DEATH)>=datepart(d,case when CLN_Activity_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_Date as date)	
		when CLN_Activity_End_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_End_Date as date)
		else '20'+cast(case when DER_Activity_Month between 1 and 9 then substring(DER_Activity_Year,1,2) else substring(DER_Activity_Year,4,2) end as varchar(4)) +'-'+ cast('0'+ case when DER_Activity_Month between 1 and 9 then DER_Activity_Month+3 else DER_Activity_Month-9 end as varchar(2)) +'-15' 
		end) then cast(datediff(mm,case when CLN_Activity_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_Date as date)	
		when CLN_Activity_End_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_End_Date as date)
		else '20'+cast(case when DER_Activity_Month between 1 and 9 then substring(DER_Activity_Year,1,2) else substring(DER_Activity_Year,4,2) end as varchar(4)) +'-'+ cast('0'+ case when DER_Activity_Month between 1 and 9 then DER_Activity_Month+3 else DER_Activity_Month-9 end as varchar(2)) +'-15' 
		end,REG_DATE_OF_DEATH) as nvarchar(8))
	end as int)<=23
group by SUPatID
	,MPI.BB5008_Pseudo_ID
	,case when CLN_Activity_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_Date as date)	
		when CLN_Activity_End_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_End_Date as date)
		else '20'+cast(case when DER_Activity_Month between 1 and 9 then substring(DER_Activity_Year,1,2) else substring(DER_Activity_Year,4,2) end as varchar(4)) +'-'+ cast('0'+ case when DER_Activity_Month between 1 and 9 then DER_Activity_Month+3 else DER_Activity_Month-9 end as varchar(2)) +'-15' 
	end 
	,SS.PODsubGroup
	,case when SS.PODsubGroup is not null then F3 else 'Unknown' end
	,DER_NHSE_ServiceLine
	,Service_Line_Code
    ,Service_Line_Desc
    ,NPoC_CRG_Code
    ,NPoC_CRG_Desc
    ,PoC
    ,Highly_Spec
	,CauseGroupLL
	,STP18CD
	,LocationType
	,DER_AGE_AT_DEATH
	,Der_Provider_Code
	,cast(case 
		when datepart(d,REG_DATE_OF_DEATH)<datepart(d,case when CLN_Activity_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_Date as date)	
		when CLN_Activity_End_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_End_Date as date)
		else '20'+cast(case when DER_Activity_Month between 1 and 9 then substring(DER_Activity_Year,1,2) else substring(DER_Activity_Year,4,2) end as varchar(4)) +'-'+ cast('0'+ case when DER_Activity_Month between 1 and 9 then DER_Activity_Month+3 else DER_Activity_Month-9 end as varchar(2)) +'-15' 
		end) then cast(datediff(mm,case when CLN_Activity_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_Date as date)	
		when CLN_Activity_End_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_End_Date as date)
		else '20'+cast(case when DER_Activity_Month between 1 and 9 then substring(DER_Activity_Year,1,2) else substring(DER_Activity_Year,4,2) end as varchar(4)) +'-'+ cast('0'+ case when DER_Activity_Month between 1 and 9 then DER_Activity_Month+3 else DER_Activity_Month-9 end as varchar(2)) +'-15' 
		end,REG_DATE_OF_DEATH)-1 as nvarchar(8))
		when datepart(d,REG_DATE_OF_DEATH)>=datepart(d,case when CLN_Activity_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_Date as date)	
		when CLN_Activity_End_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_End_Date as date)
		else '20'+cast(case when DER_Activity_Month between 1 and 9 then substring(DER_Activity_Year,1,2) else substring(DER_Activity_Year,4,2) end as varchar(4)) +'-'+ cast('0'+ case when DER_Activity_Month between 1 and 9 then DER_Activity_Month+3 else DER_Activity_Month-9 end as varchar(2)) +'-15' 
		end) then cast(datediff(mm,case when CLN_Activity_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_Date as date)	
		when CLN_Activity_End_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_End_Date as date)
		else '20'+cast(case when DER_Activity_Month between 1 and 9 then substring(DER_Activity_Year,1,2) else substring(DER_Activity_Year,4,2) end as varchar(4)) +'-'+ cast('0'+ case when DER_Activity_Month between 1 and 9 then DER_Activity_Month+3 else DER_Activity_Month-9 end as varchar(2)) +'-15' 
		end,REG_DATE_OF_DEATH) as nvarchar(8))
	end as int) 
	,datediff(d,case when CLN_Activity_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_Date as date) when CLN_Activity_End_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_End_Date as date) else '20'+cast(case when DER_Activity_Month between 1 and 9 then substring(DER_Activity_Year,1,2) else substring(DER_Activity_Year,4,2) end as varchar(4)) +'-'+ cast('0'+ case when DER_Activity_Month between 1 and 9 then DER_Activity_Month+3 else DER_Activity_Month-9 end as varchar(2)) + '-15' end,MPI.REG_DATE_OF_DEATH) 
	,case when cast(datediff(d,case when CLN_Activity_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_Date as date)	
		when CLN_Activity_End_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_End_Date as date)
		else '20'+cast(case when DER_Activity_Month between 1 and 9 then substring(DER_Activity_Year,1,2) else substring(DER_Activity_Year,4,2) end as varchar(4)) +'-'+ cast('0'+ case when DER_Activity_Month between 1 and 9 then DER_Activity_Month+3 else DER_Activity_Month-9 end as varchar(2)) +'-15' 
		end,MPI.REG_DATE_OF_DEATH) as int)=0 then '24hours'
		when cast(datediff(d,case when CLN_Activity_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_Date as date)	
		when CLN_Activity_End_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_End_Date as date)
		else '20'+cast(case when DER_Activity_Month between 1 and 9 then substring(DER_Activity_Year,1,2) else substring(DER_Activity_Year,4,2) end as varchar(4)) +'-'+ cast('0'+ case when DER_Activity_Month between 1 and 9 then DER_Activity_Month+3 else DER_Activity_Month-9 end as varchar(2)) +'-15' 
		end,MPI.REG_DATE_OF_DEATH) as int)=1 then '48hours'
		when cast(datediff(d,case when CLN_Activity_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_Date as date)	
		when CLN_Activity_End_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_End_Date as date)
		else '20'+cast(case when DER_Activity_Month between 1 and 9 then substring(DER_Activity_Year,1,2) else substring(DER_Activity_Year,4,2) end as varchar(4)) +'-'+ cast('0'+ case when DER_Activity_Month between 1 and 9 then DER_Activity_Month+3 else DER_Activity_Month-9 end as varchar(2)) +'-15' 
		end,MPI.REG_DATE_OF_DEATH) as int) between 2 and 6 then '1weeks'
		when cast(datediff(d,case when CLN_Activity_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_Date as date)	
		when CLN_Activity_End_Date between '2016-04-01' and '2019-03-31' then cast(CLN_Activity_End_Date as date)
		else '20'+cast(case when DER_Activity_Month between 1 and 9 then substring(DER_Activity_Year,1,2) else substring(DER_Activity_Year,4,2) end as varchar(4)) +'-'+ cast('0'+ case when DER_Activity_Month between 1 and 9 then DER_Activity_Month+3 else DER_Activity_Month-9 end as varchar(2)) +'-15' 
		end,MPI.REG_DATE_OF_DEATH) as int) between 7 and 13 then '2weeks' end

