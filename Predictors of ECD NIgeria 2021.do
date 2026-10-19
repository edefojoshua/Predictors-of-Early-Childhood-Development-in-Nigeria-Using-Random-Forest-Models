********************************
*Nigeria records 2021
* Early Child Development Index
* Data Cleaning / analysis
* 17 November 2025 
*J W Edefo
********************************


******MICS

cd "C:\Users\edefoj\Documents\Per\MICS\Nigeria _2021"

import spss using "ch.sav", clear
save "children.dta", replace
use "children.dta"

tab CAGE, mi
*** Use MICS type only
keep if survey == 0   // keep only MICS cases

** keep only above 23 months
drop if CAGE < 24

*set maxvar 10000

************* Age
gen agegrp = .   // initialize

replace agegrp = 1 if inrange(CAGE,24,29)
replace agegrp = 2 if inrange(CAGE,30,35)
replace agegrp = 3 if inrange(CAGE,36,41)
replace agegrp = 4 if inrange(CAGE,42,47)
replace agegrp = 5 if inrange(CAGE,48,59)

label define agegrp_lbl ///
    1 "24–29 months" ///
    2 "30–35 months" ///
    3 "36–41 months" ///
    4 "42–47 months" ///
    5 "48–59 months"

label values agegrp agegrp_lbl

***********Health Domain
******EC1 (EC21)
numlabel, add
tab agegrp EC21, row

******EC22
tab agegrp EC22, row

******EC23
tab agegrp EC23, row

******EC24
tab agegrp EC24, row


**********Learning domain
******EC25
tab agegrp EC25, row

******EC26
tab agegrp EC26, row

******EC27
tab agegrp EC27, row

******EC28
tab agegrp EC28, row

******EC29
tab agegrp EC29, row

******EC30
tab agegrp EC30, row


******EC31
tab agegrp EC31, row

******EC32
tab agegrp EC32, row

******EC33
tab agegrp EC33, row

******EC34
tab agegrp EC34, row

******EC35
tab agegrp EC35, row


**************** Psychosocial well-Being domain
******EC36
tab agegrp EC36, row

******EC37
tab agegrp EC37, row

******EC38
tab agegrp EC38, row

******EC39
tab agegrp EC39, row

******EC40
tab agegrp EC40, row


gen EC27b = 0
gen EC27_comb = (EC26==1 & EC27==1)

* --- Simple ECALL: count every EC21..EC40 that equals 1 ---
local ecvars EC21 EC22 EC23 EC24 EC25 EC26 EC27_comb EC28 EC29 EC30 EC31 EC32 EC33 EC34 EC35 EC36 EC37 EC38 EC39 EC40

local ilist ""

foreach v of local ecvars {
    capture confirm variable `v'
    if _rc == 0 {
        capture drop `v'_i
        gen `v'_i = (`v' == 1)
        local ilist "`ilist' `v'_i"
    }
    else {
        di as error "NOTE: variable `v' not found — skipping"
    }
}

* create ECALL only if indicators exist
if "`ilist'" != "" {
    egen ECALL = rowtotal(`ilist')
    di as result "ECALL created successfully."
}
else {
    di as error "No indicator variables found. ECALL NOT created."
}


tab agegrp ECALL

*1153, 955, 1011, 581, 1442 = 5142, 5142/19463 = 26.4%

count if ECALL >= 7 & agegrp == 1 
count if ECALL >= 9 & agegrp == 2 

count if ECALL >= 11 & agegrp == 3 
count if ECALL >= 13 & agegrp == 4 

count if ECALL >= 15 & agegrp == 5 


gen agegrp1_cat =0  

replace agegrp1_cat = 1 if agegrp == 1 & ECALL >= 7
replace agegrp1_cat = 1 if agegrp == 2 & ECALL >= 9
replace agegrp1_cat = 1 if agegrp == 3 & ECALL >= 11
replace agegrp1_cat = 1 if agegrp == 4 & ECALL >= 13
replace agegrp1_cat = 1 if agegrp == 5 & ECALL >= 15

tab agegrp agegrp1_cat, row  


save "children_pro.dta", replace
use "children_pro.dta", 


*********Respondent language
*gen UF14 
numlabel,add
tab UF14 if CAGE > 23, mi

describe UF14
replace UF14 = 104 if UF14 == .
label define labels5 104 "Unknown", add
label values UF14 labels5
tab UF14 if CAGE > 23, mi
drop if CAGE < 24
tab UF14, mi

tab UF14  agegrp , row 

tab UF14  agegrp1_cat, row 


**********Area (urban vs rural)
 tab HH6 agegrp1_cat, row
 
 ********** Geopolitical zone
 tab zone, mi


keep if survey == 0   // keep only MICS cases


/*

UF1 for under five children cluster number
chweightMICS - children MICS

*/


********* Ethnicity
tab ethnicity, mi



********* Disability
replace cdisability = 8 if missing(cdisability)
label define labels437 8 "Unknown", add
tab cdisability, mi
drop if cdisability == 8


********** Wealth index
replace windex5MICS = 8 if windex5MICS == 0
label define labels441 8 "Uncategorised", add
tab windex5MICS, mi


********* Maternal Edeucation
 tab melevel, mi
gen melevel_comb = melevel
replace melevel_comb = 0 if inlist(melevel, 0, 9)

label define labels435_comb ///
    0 "None / Missing" ///
    1 "Primary" ///
    2 "Junior secondary" ///
    3 "Senior secondary" ///
    4 "Higher/tertiary"

label values melevel_comb labels435_comb

tab melevel_comb, mi



*****************Sex
 tab HL4, mi
 
 
 ************Child ever been breatfed
 tab BD2, mi
 replace BD2 = 10 if missing(BD2)
 label define labels111 10 "Unknown", add
 tab BD2, mi

gen BD2_merge = BD2
replace BD2_merge = 3 if inlist(BD2, 8, 9, 10)
label define BD2merge_lbl ///
    1 "Yes" ///
    2 "No" ///
    3 "Don't know, No response, Unknown"
label values BD2_merge BD2merge_lbl

numlabel, add
tab BD2_merge, mi


**************Household number
tab UF2, missing

gen UF2_grp = .
replace UF2_grp = 1 if inrange(UF2, 1, 5)
replace UF2_grp = 2 if inrange(UF2, 6, 10)
replace UF2_grp = 3 if inrange(UF2, 11, 15)
replace UF2_grp = 4 if inrange(UF2, 16, 20)

label define UF2grp_lbl ///
    1 "1–5" ///
    2 "6–10" ///
    3 "11–15" ///
    4 "16–20"

label values UF2_grp UF2grp_lbl

tab UF2_grp, mi

save "children_pro.dta", replace
use "children_pro.dta", 


***************Covered by health insurance
 tab UB9, mi
recode UB9 (. = 11)
label define labels18 11 "unknown", add
tab UB9, mi


**************ECDI stimulation
numlabel, add
 tab EC1, mi
 recode EC1 (. = 100)
 label define labels28 100 "unknown", add
 tab EC1, mi
 
drop if EC1 == 99
recode EC1 (5/10 = 55)
 
label define labels28 0 "NONE" 1 "ONE" 2 "TWO" 3 "THREE" 4 "FOUR" ///
                     55 "5.5–10", modify

tab EC1, missing

 **************harsh discpline
tab UCD2G, mi
recode UCD2G (. = 11)
label define labels90 11 "unknown", add
tab UCD2G, mi

 **************harsh discpline
 tab UCD2K, mi
 recode UCD2K (. = 11)
label define labels94 11 "unknown", add
 tab UCD2K, mi


*************Learning with difficulty
tab UCF17, mi
recode UCF17 ///
    (1 = 1) /// no difficulty
    (2 3 4 = 2) /// difficulty
    (9 . = 4)   /// no response/unknown
	
label define labels109 ///
    1 "no difficulty" ///
    2 "difficulty" ///
    4 "no response/unknown", modify
	
drop if UCF17 == 4
	
tab UCF17, mi
***************difficulty playing

tab UCF18, mi
recode UCF18 ///
    (1 = 1) /// no difficulty
    (2 3 4 = 2) /// difficulty
    (9 . = 4)   /// no response/unknown
	
label define labels110 ///
    1 "no difficulty" ///
    2 "difficulty" ///
    4 "no response/unknown", modify

drop if UCF18 == 4

tab UCF18, mi


************** Immunisation
tab IM2, mi

recode IM2 ///
    (1 2 3 = 1) /// yes
    (4 = 2)     /// no
    (9 . = 3)   /// no response / unknown
	
	label define labels142 ///
    1 "yes" ///
    2 "no" ///
    3 "no response / unknown", modify

tab IM2, mi

************ Child had diarrhea in the last 2 weeks
tab CA1, mi
recode CA1 ///
    (8 9 . = 3) ///
	
label define labels259 ///
    3 "dont known, no response, unknown", modify

drop if CA1 ==3

tab CA1, mi
************ Child cough in the last 2 weeks
tab CA16, mi
recode CA16 ///
    (8 9 . = 3) ///
	
label define labels331 ///
    3 "dont known, no response, unknown", modify

drop if CA16 ==3
tab CA16, mi


tab agegrp1_cat, mi 
tab cdisability, mi
*********************************************************************
**************************** Analysis *******************************
*********************************************************************
tab HL4 agegrp1_cat, row

* Sex
asdoc tab HL4 agegrp1_cat, row save(Nig_ECD.doc) fs(12) dec(2)

* Age group
asdoc tab agegrp  agegrp1_cat, row save(Nig_ECD.doc) fs(12) dec(2)

* residence
asdoc tab HH6  agegrp1_cat, row save(Nig_ECD.doc) fs(12) dec(2)

*Geopolitical zone
asdoc tab zone  agegrp1_cat, row save(Nig_ECD.doc) fs(12) dec(2)

*Wealth Index
asdoc tab windex5MICS  agegrp1_cat, row save(Nig_ECD.doc) fs(12) dec(2)

* Children disability
asdoc tab cdisability  agegrp1_cat, row save(Nig_ECD.doc) fs(12) dec(2)

* Maternal education
asdoc tab melevel_comb agegrp1_cat, row save(Nig_ECD.doc) fs(12) dec(2)

* ECD stimulation
asdoc tab EC1 agegrp1_cat, row save(Nig_ECD.doc) fs(12) dec(2)

* Ethnicity
asdoc tab ethnicity agegrp1_cat, row save(Nig_ECD.doc) fs(12) dec(2)


* Harsh Dicipline 1
asdoc tab UCD2G agegrp1_cat, row save(Nig_ECD.doc) fs(12) dec(2)

* Harsh Dicipline 2
asdoc tab UCD2K agegrp1_cat, row save(Nig_ECD.doc) fs(12) dec(2)

* Diffculty playing
asdoc tab UCF18 agegrp1_cat, row save(Nig_ECD.doc) fs(12) dec(2)


* Had diarrhoea
asdoc tab CA1 agegrp1_cat, row save(Nig_ECD.doc) fs(12) dec(2)



regress agegrp1_cat HL4 agegrp HH6 zone  windex5MICS cdisability melevel_comb  EC1 ethnicity UCD2G UCD2K UCF18 CA1

asdoc vif, save(Nig_ECD.doc) fs(12) dec(2)

svyset UF1 [pweight = chweightMICS], strata(stratum) singleunit(certainty)

svy: logistic agegrp1_cat i.HL4  i.agegrp i.HH6 i.zone i.ethnicity## i.windex5MICS i.cdisability  i.melevel_comb  i.BD2_merge i.UF2_grp i.EC1 i.UCD2G i.UCD2K i.UCF17 i.UCF18 i.CA1 i.CA16

est store model1
svy: logistic agegrp1_cat i.HL4  i.agegrp i.HH6 i.zone i.ethnicity i.windex5MICS i.cdisability  i.melevel_comb  i.BD2_merge i.UF2_grp i.UB9 i.EC1 i.UCD2G i.UCD2K i.UCF17 i.UCF18 i.CA1 i.CA16

est store model2

est table model1 model2, stats(N ll r2_p aic bic)

margins, dydx(*)

svy: tab agegrp agegrp1_cat, row


logistic agegrp1_cat i.HL4  i.agegrp i.HH6 i.zone i.ethnicity## i.windex5MICS i.cdisability  i.melevel_comb  i.BD2_merge i.UF2_grp i.UB9 i.EC1 i.UCD2G i.UCD2K i.UCF17 i.UCF18 i.CA1 i.CA16 [pweight= chweightMICS], vce (cluster UF1)

est store model3

logistic agegrp1_cat i.HL4  i.agegrp i.HH6 i.zone  i.windex5MICS i.cdisability  i.melevel_comb  i.EC1 i.ethnicity i.UCD2G i.UCD2K i.UCF18 i.CA1 [pweight= chweightMICS], vce (cluster UF1)

logistic agegrp1_cat i.HL4  i.agegrp i.HH6 i.zone  i.windex5MICS i.cdisability  i.melevel_comb  i.EC1 i.ethnicity i.UCD2G i.UCD2K i.UCF18 i.CA1 [pweight= chweightMICS], vce (cluster UF1)


est store model4

est table model3 model4, stats(N ll r2_p aic bic) 

asdoc svy: logistic agegrp1_cat i.HL4  i.agegrp i.HH6 i.zone  i.windex5MICS i.cdisability  i.melevel_comb  i.EC1 i.ethnicity i.UCD2G i.UCD2K i.UCF18 i.CA1

margins, dydx(*) post
save "children_pro.dta", replace
use "children_pro.dta", 

