-------------------------------------------------------------------------------------------------
/*add cause to created as FIXED. ONLY EVER DO THIS ONCE*/
-------------------------------------------------------------------------------------------------
--drop table MPIFixedCause
select *
	,case 
		when DER_AGE_AT_DEATH between 65 and 74 and RAND(CAST(NEWID() AS varbinary)) > 0.9 then 'Frailty'
		when DER_AGE_AT_DEATH between 75 and 84 and RAND(CAST(NEWID() AS varbinary)) > 0.7 then 'Frailty'
		when DER_AGE_AT_DEATH between 85 and 120 and RAND(CAST(NEWID() AS varbinary)) > 0.2 then 'Frailty'
		when S_UNDERLYING_COD_ICD10 like 'A0%' then 'Sudden Death'
		when S_UNDERLYING_COD_ICD10 like 'A39%' then 'Sudden Death'
		when S_UNDERLYING_COD_ICD10 like 'A4[01]%' then 'Sudden Death'
		when S_UNDERLYING_COD_ICD10 like 'B2[0-4]%' then 'Other Terminal Illness'
		when S_UNDERLYING_COD_ICD10 like 'D[0-3]%' then 'Cancer'
		when S_UNDERLYING_COD_ICD10 like 'D4[0-8]%' then 'Cancer'
		when S_UNDERLYING_COD_ICD10 like 'F0[13]%' then 'Frailty'
		when S_UNDERLYING_COD_ICD10 like 'G0[0-3]%' then 'Sudden Death'
		when S_UNDERLYING_COD_ICD10 like 'G30%' then 'Frailty'
		when S_UNDERLYING_COD_ICD10 like 'H[0-5]%' then 'Sudden Death'
		when S_UNDERLYING_COD_ICD10 like 'H[6-9]%' then 'Sudden Death'
		when S_UNDERLYING_COD_ICD10 like 'I2[12]%' then 'Sudden Death'
		when S_UNDERLYING_COD_ICD10 like 'I63%' then 'Sudden Death'
		when S_UNDERLYING_COD_ICD10 like 'I64%' then 'Sudden Death'
		when S_UNDERLYING_COD_ICD10 like 'I6[0-2]%' then 'Sudden Death'
		when S_UNDERLYING_COD_ICD10 like 'I71%' then 'Sudden Death'	
		when S_UNDERLYING_COD_ICD10 like 'J1[2-8]%' then 'Sudden Death'
		when S_UNDERLYING_COD_ICD10 like 'K2[5-7]%' then 'Sudden Death'
		when S_UNDERLYING_COD_ICD10 like 'K4[0-6]%' then 'Sudden Death'
		when S_UNDERLYING_COD_ICD10 like 'K57%' then 'Organ Failure'
		when S_UNDERLYING_COD_ICD10 like 'K7[0-6]%' then 'Organ Failure'
		when S_UNDERLYING_COD_ICD10 like 'L%' then 'Organ Failure'
		when S_UNDERLYING_COD_ICD10 like 'O%' then 'Sudden Death'
		when S_UNDERLYING_COD_ICD10 like 'P%' then 'Sudden Death'
		when S_UNDERLYING_COD_ICD10 like 'Q[2-8]%' then 'Organ Failure'
		when S_UNDERLYING_COD_ICD10 like 'R54%' then 'Frailty'
		when S_UNDERLYING_COD_ICD10 like 'R%' then 'Sudden Death'
		when S_UNDERLYING_COD_ICD10 like 'R99%' then 'Sudden Death'	
		when S_UNDERLYING_COD_ICD10 like 'U509%' then 'Sudden Death'
		when S_UNDERLYING_COD_ICD10 like 'W6[5-9]%' then 'Sudden Death'
		when S_UNDERLYING_COD_ICD10 like 'W7[0-4]%' then 'Sudden Death'
		when S_UNDERLYING_COD_ICD10 like 'W[01]%' then 'Sudden Death'
		when S_UNDERLYING_COD_ICD10 like 'X0%' then 'Sudden Death'
		when S_UNDERLYING_COD_ICD10 like 'X41%' then 'Sudden Death'
		when S_UNDERLYING_COD_ICD10 like 'X42%' then 'Sudden Death'
		when S_UNDERLYING_COD_ICD10 like 'X44%' then 'Sudden Death'
		when S_UNDERLYING_COD_ICD10 like 'X59%' then 'Sudden Death'
		when S_UNDERLYING_COD_ICD10 like 'X8[0-4]%' then 'Sudden Death'
		when S_UNDERLYING_COD_ICD10 like 'X8[5-9]%' then 'Sudden Death'
		when S_UNDERLYING_COD_ICD10 like 'X9%' then 'Sudden Death'
		when S_UNDERLYING_COD_ICD10 like 'X[67]%' then 'Sudden Death'
		when S_UNDERLYING_COD_ICD10 like 'Y0%' then 'Sudden Death'
		when S_UNDERLYING_COD_ICD10 like 'Y3[0-4]%' then 'Sudden Death'
		when S_UNDERLYING_COD_ICD10 like 'Y[12]%' then 'Sudden Death'	
		--Catch all
		when S_UNDERLYING_COD_ICD10 like 'A%' then 'Organ Failure'
		when S_UNDERLYING_COD_ICD10 like 'B%' then 'Organ Failure'
		when S_UNDERLYING_COD_ICD10 like 'C%' then 'Cancer'
		when S_UNDERLYING_COD_ICD10 like 'D[5-8]%' then 'Organ Failure'
		when S_UNDERLYING_COD_ICD10 like 'E%' then 'Other Terminal Illness'
		when S_UNDERLYING_COD_ICD10 like 'F%' then 'Other Terminal Illness'
		when S_UNDERLYING_COD_ICD10 like 'G%' then 'Other Terminal Illness'
		when S_UNDERLYING_COD_ICD10 like 'I%' then 'Organ Failure'
		when S_UNDERLYING_COD_ICD10 like 'J%' then 'Organ Failure'
		when S_UNDERLYING_COD_ICD10 like 'K%' then 'Other Terminal Illness'
		when S_UNDERLYING_COD_ICD10 like 'M%' then 'Frailty'
		when S_UNDERLYING_COD_ICD10 like 'N%' then 'Organ Failure'
		when S_UNDERLYING_COD_ICD10 like 'Q%' then 'Other Terminal Illness'
		when S_UNDERLYING_COD_ICD10 like 'V%' then 'Organ Failure'
		when S_UNDERLYING_COD_ICD10 like 'W%' then 'Organ Failure'
		when S_UNDERLYING_COD_ICD10 like 'X%' then 'Organ Failure'
		when S_UNDERLYING_COD_ICD10 like 'Y%' then 'Organ Failure'
	else null end as 'CauseGroupLL'
into MPIFixedCause
from qa.tbl_Mortality_Extract as ME
where REG_DATE_OF_DEATH>='2018-04-01' 
	and REG_DATE_OF_DEATH<='2019-03-31'
	and ((CCG_OF_RESIDENCE_CODE not like '7%' or CCG_OF_RESIDENCE_CODE is null) --england resi whether can find CCG or not
		or (CCG_OF_RESIDENCE_CODE like '7%'and (DER_NHAIS_CCG_OF_REGISTRATION is not null or CCG_OF_REGISTRATION_CODE is not null))) --wales resi but eng ccg resp
	and CANCELLED_FLAG<>'Y' --only 37 records
	and DER_AGE_AT_DEATH>=18
	and BB5008_Pseudo_ID is not null

-------------------------------------------------------------------------------------------------
/*create the decedent MPI with further added fields*/
-------------------------------------------------------------------------------------------------
--drop table MPI
select row_number() over(order by BB5008_Pseudo_ID)as SUPatID
	,BB5008_Pseudo_ID
	,DER_AGE_AT_DEATH
	,DEC_SEX
	,case 
		when DER_NHAIS_CCG_OF_REGISTRATION is not null then DER_NHAIS_CCG_OF_REGISTRATION
		when DER_NHAIS_CCG_OF_REGISTRATION is null and CCG_OF_REGISTRATION_CODE is not null then CCG_OF_REGISTRATION_CODE else null end as CCGResponsible
	,STP.STP18CD
	,LSOA_OF_RESIDENCE_CODE
	,IndexofMultipleDeprivationIMDDecile
	,COUNTY_DISTRICT_OF_RES_CODE
	,REG_DATE_OF_DEATH
	--,POD_CODE just in when checking DQ
	--,POD_NHS_ESTABLISHMENT just in when checking DQ
	--,POD_ESTABLISHMENT_TYPE just in when checking DQ
	,case 
		when POD_CODE='H' then 'Home'
		when POD_CODE='E' then 'Elsewhere/Other'
		when POD_NHS_ESTABLISHMENT=1 and POD_ESTABLISHMENT_TYPE in ('02','04','07','10','21','2','4','7') then 'Care Home'
		when POD_NHS_ESTABLISHMENT=1 and POD_ESTABLISHMENT_TYPE in ('01','03','18','99','1','3') then 'Hospital' --CHECK POD ESTABLISHMENT TYPE =1/01 DO A GROUP AND CHECK OUT COMMUNAL_ESTABLISHMENT TOO. ARE THESE ALL BLANK? BY
		when POD_NHS_ESTABLISHMENT=2 and POD_ESTABLISHMENT_TYPE in ('03','04','07','10','14','20','22','32','33','99','3','4','7') then 'Care Home'
		when POD_NHS_ESTABLISHMENT=2 and POD_ESTABLISHMENT_TYPE in ('01','18','19','1') then 'Hospital'
		when POD_ESTABLISHMENT_TYPE in ('83') then 'Hospice'
		when POD_NHS_ESTABLISHMENT=1 and POD_ESTABLISHMENT_TYPE in ('5','6','8','9','11','05','06','08','09') then 'Elsewhere/Other'
		when POD_NHS_ESTABLISHMENT=2 and 
		(POD_ESTABLISHMENT_TYPE in ('5','8','9','11','12','13','15','16','17','05','08','09') or POD_ESTABLISHMENT_TYPE between '23' and '31' or POD_ESTABLISHMENT_TYPE between '34' and '82') then 'Elsewhere/Other'
	else 'Unknown' end as LocationType
	,S_UNDERLYING_COD_ICD10
	,S_COD_CODE_1
	,S_COD_CODE_2
	,S_COD_CODE_3
	,S_COD_CODE_4
	,S_COD_CODE_5
	,S_COD_CODE_6
	,S_COD_CODE_7
	,S_COD_CODE_8
	,S_COD_CODE_9
	,S_COD_CODE_10
	,S_COD_CODE_11
	,S_COD_CODE_12
	,S_COD_CODE_13
	,S_COD_CODE_14
	,S_COD_CODE_15
	,CauseGroupLL
	,'99' as Ethnic
	,'00' as CarerSuport
	,99 as LivesAlone
	,0 as FrailtyMarker 
	,0 as FrailtyCODCodes
	,concat(S_COD_CODE_1,' | ', S_COD_CODE_2,' | ', S_COD_CODE_3,' | ', S_COD_CODE_4,' | ', S_COD_CODE_5,' | ', S_COD_CODE_6,' | ', S_COD_CODE_7,' | ', S_COD_CODE_8,' | ', S_COD_CODE_9,' | ', S_COD_CODE_10,' | ', S_COD_CODE_11,' | ', S_COD_CODE_12,' | ', S_COD_CODE_13,' | ', S_COD_CODE_14,' | ', S_COD_CODE_15) as CODCodes
	,null as DiedInCriticalCare
into MPI	
from MPIFixedCause as ME
left join RefCCGToSTP as STP --NHAIS is open exeter version. CCG is CCG usual registration of deceased
	on case 
		when DER_NHAIS_CCG_OF_REGISTRATION is not null then DER_NHAIS_CCG_OF_REGISTRATION
		when DER_NHAIS_CCG_OF_REGISTRATION is null and CCG_OF_REGISTRATION_CODE is not null then CCG_OF_REGISTRATION_CODE else null end=STP.CCG18CDH
left outer join dbo.RefIMD2019 as IMD
	on ME.LSOA_OF_RESIDENCE_CODE=IMD.LSOAcode2011
		
delete MPI 
from MPI
inner join (select BB5008_Pseudo_ID, count(*) as count
			from MPI
			group by BB5008_Pseudo_ID
			having count(*)>1) as DUPS
	on MPI.BB5008_Pseudo_ID=DUPS.BB5008_Pseudo_ID

select count(*) from MPI
select * from MPI

update MPI
set MPI.DiedInCriticalCare=case when (A.DiedInCriticalCare=1 and LocationType='Hospital') or A.DiedInCriticalCare=0  then A.DiedInCriticalCare end
from MPI as MPI
inner join 
		(select BB5008_Pseudo_ID, case when sum(DiedInCriticalCare)>=1 then 1 else 0 end as DiedInCriticalCare
		from ActivityCC
		group by BB5008_Pseudo_ID
		) as A
	on MPI.BB5008_Pseudo_ID=A.BB5008_Pseudo_ID
where A.BB5008_Pseudo_ID is not null

select count (*) from MPI

-------------------------------------------------------------------------------------------------
/*Remember to deal with duplicates as currently manual*/
-------------------------------------------------------------------------------------------------