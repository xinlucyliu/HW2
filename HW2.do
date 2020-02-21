***1. Load the data. 
ssc install estout
insheet using ~/Documents/GitHub/ResearchMethods-Repository/HW2/vaping-ban-panel.csv,clear

***2. Use a regression to evaluate the "parallel trends" requirement of a difference-in-difference ("DnD") estimate. 
gen time = (year>=2021) & !missing(year)
gen treated = (stateid<24) & !missing(stateid)

sort year stateid
egen avg0 = mean(lunghospitalizations), by(year treated)
twoway scatter avg0 year

reg avg0 year i.stateid if time==0
eststo reg_parallel_treat

***3. Create the canonical DnD line graph. 
sort year stateid

graph twoway scatter lunghospitalizations year if treated == 0 || scatter lunghospitalizations year if treated == 1 || line avg0 year if treated == 0 || line avg0 year if treated == 1 ,title("Diff-in-Diff Lung Hospitalization") ytitle("Hospitalizations") legend(order(4 "Treatment Average" 3 "Control Average" 2 "Treatment Scatter" 1 "Control Scatter")) xline(2021)

***4. Runs a regression to estimate the treatment effect of the laws. 
gen did = treated*time
label variable did "Diff-in-Diff"
reg lunghospitalizations time treated did i.stateid i.year, r
eststo reg_DiD

testparm i.stateid

***5. Output your from regressions #1 and #4 into a publication-quality table. 
global tableoptions "bf(%15.3gc) sfmt(%15.3gc) se label noisily noeqlines nonumbers varlabels(_cons Constant, end("" ) nolast)  starlevels(* 0.1 ** 0.05 *** 0.01) replace r2"
esttab reg_parallel_treat using vaping-ban-parallel-test.rtf, $tableoptions keep(year)

global tableoptions "bf(%15.3gc) sfmt(%15.3gc) se label noisily noeqlines nonumbers varlabels(_cons Constant, end("" ) nolast)  starlevels(* 0.1 ** 0.05 *** 0.01) replace r2"
esttab reg_DiD using vaping-ban-effect.rtf, $tableoptions keep(time treated did)

