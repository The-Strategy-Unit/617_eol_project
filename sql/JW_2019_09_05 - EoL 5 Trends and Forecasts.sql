--drop table ForecastDeathsOutput
select case when CJ.Factor in(1,-1) then CJ.STPCodeUpdated else FD.STPCode end as STPCode
	,case when CJ.Factor in(1,-1) then CJ.STPNameUpdated else FD.STPName end as STPName
	,FD.SEX
	,AGE_GROUP
	,sum(case when LA='Birmingham' and factor=1 then [2019]*WBProportionBirmingham when LA='Birmingham' and factor=-1 then [2019]*(1-WBProportionBirmingham) else [2019] end) as D2019	
	,sum(case when LA='Birmingham' and factor=1 then [2020]*WBProportionBirmingham when LA='Birmingham' and factor=-1 then [2020]*(1-WBProportionBirmingham) else [2020] end) as D2020
	,sum(case when LA='Birmingham' and factor=1 then [2021]*WBProportionBirmingham when LA='Birmingham' and factor=-1 then [2021]*(1-WBProportionBirmingham) else [2021] end) as D2021
	,sum(case when LA='Birmingham' and factor=1 then [2022]*WBProportionBirmingham when LA='Birmingham' and factor=-1 then [2022]*(1-WBProportionBirmingham) else [2022] end) as D2022
	,sum(case when LA='Birmingham' and factor=1 then [2023]*WBProportionBirmingham when LA='Birmingham' and factor=-1 then [2023]*(1-WBProportionBirmingham) else [2023] end) as D2023
	,sum(case when LA='Birmingham' and factor=1 then [2024]*WBProportionBirmingham when LA='Birmingham' and factor=-1 then [2024]*(1-WBProportionBirmingham) else [2024] end) as D2024
	,sum(case when LA='Birmingham' and factor=1 then [2025]*WBProportionBirmingham when LA='Birmingham' and factor=-1 then [2025]*(1-WBProportionBirmingham) else [2025] end) as D2025
	,sum(case when LA='Birmingham' and factor=1 then [2026]*WBProportionBirmingham when LA='Birmingham' and factor=-1 then [2026]*(1-WBProportionBirmingham) else [2026] end) as D2026
	,sum(case when LA='Birmingham' and factor=1 then [2027]*WBProportionBirmingham when LA='Birmingham' and factor=-1 then [2027]*(1-WBProportionBirmingham) else [2027] end) as D2027
	,sum(case when LA='Birmingham' and factor=1 then [2028]*WBProportionBirmingham when LA='Birmingham' and factor=-1 then [2028]*(1-WBProportionBirmingham) else [2028] end) as D2028
	,sum(case when LA='Birmingham' and factor=1 then [2029]*WBProportionBirmingham when LA='Birmingham' and factor=-1 then [2029]*(1-WBProportionBirmingham) else [2029] end) as D2029
	,sum(case when LA='Birmingham' and factor=1 then [2030]*WBProportionBirmingham when LA='Birmingham' and factor=-1 then [2030]*(1-WBProportionBirmingham) else [2030] end) as D2030
	,sum(case when LA='Birmingham' and factor=1 then [2031]*WBProportionBirmingham when LA='Birmingham' and factor=-1 then [2031]*(1-WBProportionBirmingham) else [2031] end) as D2031
	,sum(case when LA='Birmingham' and factor=1 then [2032]*WBProportionBirmingham when LA='Birmingham' and factor=-1 then [2032]*(1-WBProportionBirmingham) else [2032] end) as D2032
	,sum(case when LA='Birmingham' and factor=1 then [2033]*WBProportionBirmingham when LA='Birmingham' and factor=-1 then [2033]*(1-WBProportionBirmingham) else [2033] end) as D2033
	,sum(case when LA='Birmingham' and factor=1 then [2034]*WBProportionBirmingham when LA='Birmingham' and factor=-1 then [2034]*(1-WBProportionBirmingham) else [2034] end) as D2034
	,sum(case when LA='Birmingham' and factor=1 then [2035]*WBProportionBirmingham when LA='Birmingham' and factor=-1 then [2035]*(1-WBProportionBirmingham) else [2035] end) as D2035
	,sum(case when LA='Birmingham' and factor=1 then [2036]*WBProportionBirmingham when LA='Birmingham' and factor=-1 then [2036]*(1-WBProportionBirmingham) else [2036] end) as D2036
	,sum(case when LA='Birmingham' and factor=1 then [2037]*WBProportionBirmingham when LA='Birmingham' and factor=-1 then [2037]*(1-WBProportionBirmingham) else [2037] end) as D2037
	,sum(case when LA='Birmingham' and factor=1 then [2038]*WBProportionBirmingham when LA='Birmingham' and factor=-1 then [2038]*(1-WBProportionBirmingham) else [2038] end) as D2038
	,sum(case when LA='Birmingham' and factor=1 then [2039]*WBProportionBirmingham when LA='Birmingham' and factor=-1 then [2039]*(1-WBProportionBirmingham) else [2039] end) as D2039
	,sum(case when LA='Birmingham' and factor=1 then [2040]*WBProportionBirmingham when LA='Birmingham' and factor=-1 then [2040]*(1-WBProportionBirmingham) else [2040] end) as D2040
	,sum(case when LA='Birmingham' and factor=1 then [2041]*WBProportionBirmingham when LA='Birmingham' and factor=-1 then [2041]*(1-WBProportionBirmingham) else [2041] end) as D2041
		,sum(case when LA='Birmingham' and factor=1 then [2042]*WBProportionBirmingham when LA='Birmingham' and factor=-1 then [2042]*(1-WBProportionBirmingham) else [2042] end) as D2042
		,sum(case when LA='Birmingham' and factor=1 then [2043]*WBProportionBirmingham when LA='Birmingham' and factor=-1 then [2043]*(1-WBProportionBirmingham) else [2043] end) as D2043
into ForecastDeathsOutput
from ForecastDeathsRaw2019 as FD
left outer join	
	(select A.*, Factor, STPNameUpdated, STPCodeUpdated from ForecastDeathsNonCoTerminus AS A
	 cross join ForecastDeathsCrossJoin
	) as CJ
on FD.AREA_NAME=CJ.LA and FD.AGE_GROUP=CJ.Age and FD.SEX=CJ.Gender
group by case when CJ.Factor in(1,-1) then CJ.STPCodeUpdated else FD.STPCode end
	,case when CJ.Factor in(1,-1) then CJ.STPNameUpdated else FD.STPName end
	,FD.SEX
	,AGE_GROUP

--drop table HistoricalDeathsOutput --may need to update with zeros? also remove blanks
select case when CJ.Factor in(1,-1) then CJ.STPCodeUpdated else HD.STPCode end as STPCode
	,case when CJ.Factor in(1,-1) then CJ.STPNameUpdated else HD.STPName end as STPName
	,HD.SEX
	,sum(case when LA='Birmingham' and factor=1 then [2007]*WBProportionBirmingham when LA='Birmingham' and factor=-1 then [2007]*(1-WBProportionBirmingham) else [2007] end) as D2007
	,sum(case when LA='Birmingham' and factor=1 then [2008]*WBProportionBirmingham when LA='Birmingham' and factor=-1 then [2008]*(1-WBProportionBirmingham) else [2008] end) as D2008
	,sum(case when LA='Birmingham' and factor=1 then [2009]*WBProportionBirmingham when LA='Birmingham' and factor=-1 then [2009]*(1-WBProportionBirmingham) else [2009] end) as D2009
	,sum(case when LA='Birmingham' and factor=1 then [2010]*WBProportionBirmingham when LA='Birmingham' and factor=-1 then [2010]*(1-WBProportionBirmingham) else [2010] end) as D2010
	,sum(case when LA='Birmingham' and factor=1 then [2011]*WBProportionBirmingham when LA='Birmingham' and factor=-1 then [2011]*(1-WBProportionBirmingham) else [2011] end) as D2011
	,sum(case when LA='Birmingham' and factor=1 then [2012]*WBProportionBirmingham when LA='Birmingham' and factor=-1 then [2012]*(1-WBProportionBirmingham) else [2012] end) as D2012
	,sum(case when LA='Birmingham' and factor=1 then [2013]*WBProportionBirmingham when LA='Birmingham' and factor=-1 then [2013]*(1-WBProportionBirmingham) else [2013] end) as D2013
	,sum(case when LA='Birmingham' and factor=1 then [2014]*WBProportionBirmingham when LA='Birmingham' and factor=-1 then [2014]*(1-WBProportionBirmingham) else [2014] end) as D2014
	,sum(case when LA='Birmingham' and factor=1 then [2015]*WBProportionBirmingham when LA='Birmingham' and factor=-1 then [2015]*(1-WBProportionBirmingham) else [2015] end) as D2015
	,sum(case when LA='Birmingham' and factor=1 then [2016]*WBProportionBirmingham when LA='Birmingham' and factor=-1 then [2016]*(1-WBProportionBirmingham) else [2016] end) as D2016
	,sum(case when LA='Birmingham' and factor=1 then [2017]*WBProportionBirmingham when LA='Birmingham' and factor=-1 then [2017]*(1-WBProportionBirmingham) else [2017] end) as D2017
	,sum(case when LA='Birmingham' and factor=1 then [2018]*WBProportionBirmingham when LA='Birmingham' and factor=-1 then [2018]*(1-WBProportionBirmingham) else [2018] end) as D2018
	into HistoricalDeathsOutput
from historicaldeathsraw as HD
left outer join	
	(select A.*, Factor, STPNameUpdated, STPCodeUpdated 
	from 
		(select LA, CCG, Gender, sum(PasteValueFormulaeWithReplaceWB)/sum(PasteValueFormulaeWithReplaceAllB) as WBProportionBirmingham
		from ForecastDeathsNonCoTerminus
		where Age>=50
		group by LA, CCG, Gender) as A
	 cross join ForecastDeathsCrossJoin
	) as CJ
on HD.AREA_NAME=CJ.LA and HD.SEX=CJ.Gender
where STPName<>'(blank)'
group by case when CJ.Factor in(1,-1) then CJ.STPCodeUpdated else HD.STPCode end
	,case when CJ.Factor in(1,-1) then CJ.STPNameUpdated else HD.STPName end
	,HD.SEX

--for reporting
select STPCode, sum(D2020) as D202, SUM (D2030) as D2030 from ForecastDeathsOutput group by STPCode order by STPCode

--this was my testing for Tom. can delete/tidy
select * from forecastdeathsstporig

 select STP18CD, DER_AGE_AT_DEATH, PODSubGroup, PODType, ur
 ,UR*A20 AS FA20
 ,UR*A21 AS FA21
  ,UR*A22 AS FA22
   ,UR*A23 AS FA23
    ,UR*A24 AS FA24
	 ,UR*A25 AS FA25
	  ,UR*A26 AS FA26
	   ,UR*A27 AS FA27
	    ,UR*A28 AS FA28
		 ,UR*A29 AS FA29
		  ,UR*A30 AS FA30
		   ,UR*A31 AS FA31
		    ,UR*A32 AS FA32
			 ,UR*A33 AS FA33
			  ,UR*A34 AS FA34
			   ,UR*A35 AS FA35
			    ,UR*A36 AS FA36
				 ,UR*A37 AS FA37
				  ,UR*A38 AS FA38
				   ,UR*A39 AS FA39
				    ,UR*A40 AS FA40
					 ,UR*A41 AS FA41
 from 

 (select STP18CD, der_age_at_death, PODSubGroup,PODType, sum(act) AS ACTING, count(distinct BB5008_Pseudo_ID) AS COUNTING, cast(sum(act) as float)/cast(count(distinct BB5008_Pseudo_ID) as float) AS ur
 from Activity0AllMIDS
 where ProximityToDeath<12
 group by STP18CD, der_age_at_death, PODSubGroup,PODType
 ) as A
 right outer join 
 (select STPCode, AGE_GROUP
 ,sum(D2020) as A20
  ,sum(D2021) as A21
   ,sum(D2022) as A22
    ,sum(D2023) as A23
	 ,sum(D2024) as A24
	  ,sum(D2025) as A25
	   ,sum(D2026) as A26
	    ,sum(D2027) as A27
		 ,sum(D2028) as A28
		  ,sum(D2029) as A29
 ,sum(D2030) as A30
  ,sum(D2031) as A31
   ,sum(D2032) as A32
    ,sum(D2033) as A33
	 ,sum(D2034) as A34
	  ,sum(D2035) as A35
	   ,sum(D2036) as A36
	    ,sum(D2037) as A37
		 ,sum(D2038) as A38
		  ,sum(D2039) as A39
		   ,sum(D2040) as A40
  ,sum(D2041) as A41
from forecastdeathsoutput
group by STPCode, AGE_GROUP
) AS B
on A.STP18CD=B.STPCode
	and A.DER_AGE_AT_DEATH=B.AGE_GROUP

SELECT * FROM FORECASTDEATHSOUTPUT
 select PODType from 
 (select STP18CD, der_age_at_death, PODType, sum(act), count(distinct BB5008_Pseudo_ID), cast(sum(act) as float)/cast(count(distinct BB5008_Pseudo_ID) as float)
 from Activity0AllMIDS
 where ProximityToDeath<12
 group by STP18CD, der_age_at_death, PODType