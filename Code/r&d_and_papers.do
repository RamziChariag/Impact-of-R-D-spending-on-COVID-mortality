clear

import excel "Data\Transformed\mean BMI.xlsx", firstrow clear
drop if Year!=.
drop CountryRegionWorld Year MeanBMImen MeanBMIwomen
save "Data\Derived\BMI.dta", replace

import excel "Data\Transformed\obesity.xlsx", firstrow clear
drop if year!=.
drop entity year
save "Data\Derived\obesity.dta", replace

import excel "Data\Transformed\r&d.xlsx", firstrow clear
drop if Indicator!=""
drop INDICATOR Indicator Country TIME Time
save "Data\Derived\r&d.dta", replace

import delimited "Data\Transformed\Mortality.csv", clear
rename code Code
drop if Code=="NA"
drop deaths population cases
save "Data\Derived\mortality.dta", replace

import excel "Data\Transformed\research_papers.xlsx", firstrow clear
drop Country Indicator IndicatorCode n_reseach_papers
save "Data\Derived\research_papers.dta", replace

import excel "Data\Transformed\GDPPC.xlsx", firstrow clear
drop Country Indicator IndicatorCode
save "Data\Derived\GDPPC.dta", replace

import delimited "Data\Transformed\diabetes.csv", clear
drop country indicator indicatorcode
rename code Code
save "Data\Derived\diabetes.dta", replace

import delimited "Data\Transformed\median-age.csv", clear
drop if year!=.
rename code Code
drop entity year
save "Data\Derived\m_age.dta", replace

import excel "Data\Transformed\HAQ.xlsx", firstrow clear
drop if Entity!=""
drop Entity Year
drop if Code=="OWID_WRL Average"
drop if Code=="Grand Average"
save "Data\Derived\HAQ.dta", replace

merge 1:1 Code using "Data\Derived\r&d.dta", keep(match) nogenerate
merge 1:1 Code using "Data\Derived\BMI.dta", keep(match) nogenerate
merge 1:1 Code using "Data\Derived\obesity.dta", keep(match) nogenerate
merge 1:1 Code using "Data\Derived\m_age.dta", keep(match) nogenerate
replace Code = subinstr(Code," Average","",.)
merge 1:1 Code using "Data\Derived\research_papers.dta", keep(match) nogenerate
merge 1:1 Code using "Data\Derived\diabetes.dta", keep(match) nogenerate
merge 1:1 Code using "Data\Derived\GDPPC.dta", keep(match) nogenerate
merge 1:1 Code using "Data\Derived\mortality.dta", keep(match) nogenerate

*Regression
gen lGDPPC=log(GDPPC)
gen lrd=log(rd)
gen lmortality=log(mortality)
gen lpapers=log(yr_papers)

*ssc install asdoc
asdoc summarize mortality lrd lpapers lGDPPC m_age HAQ BMI diabetes, replace


*first stage
reg lrd lpapers lGDPPC m_age HAQ BMI diabetes
outreg2 using "Results\first_stage.xls", replace
*second stage
ivregress 2sls lmortality lGDPPC m_age HAQ BMI diabetes (lrd = lpapers), robust
outreg2 using "Results\second_stage.xls", replace
