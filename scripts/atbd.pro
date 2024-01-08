;first, get all file names for HH and HV data
;upper and lower sideband

;thresholds
;inundated veg class 1
T0_0=1.
T0_1=0.5
T0_2=15.
T0_3=20.
;inundated veg class 2
T1_0=1.0
T1_1=0.5
T1_2=15.
T1_3=20.
;open water class 1
T2_0=1.
T2_1=0.0001
T2_2=15.
T2_3=.1
;open water class 2
T3_0=1.
T3_1=0.0001
T3_2=15.
T3_3=0.01
;not inundated
T4_0=1.0
T4_1=0.05
T4_2=15.
T4_3=1.0
;not classified
T5_0=0.
T5_1=0.0
T5_2=15.0
T5_3=.5

ns=1604
nl=1850
val=fltarr(ns,nl)
class0=bytarr(ns,nl)
class1=bytarr(ns,nl)
class2=bytarr(ns,nl)
class3=bytarr(ns,nl)
class4=bytarr(ns,nl)
class5=bytarr(ns,nl)
class6=bytarr(ns,nl)

vers='02'
proc='CX'

;change detection
;refine classes using change detection
;1=yes
change=0

;if want to compare with classification of entire timespan dominant classication type
class_temporal=0


; two - HH and HV
numpol=2
pol=strarr(numpol)
;two - lower and upper sideband for nummode
nummode=2
mode=strarr(nummode)
;prefix for each date
numdates=6
prefix=strarr(numdates)


;number of images in running average
nt=2
print,'multitemporal averaging over',nt,' images'

;number of averaged images per pol per mode over timespan nt
na=numdates-nt+1

avg=fltarr(na,numpol,nummode,ns,nl)
avg_all=fltarr(numpol,nummode,ns,nl)

n=intarr(numpol,nummode)

;average modes together
;1=yes
mlmodes=1
avg_mlmode=fltarr(na,numpol,ns,nl)
avg_all_mlmode=fltarr(numpol,ns,nl)


;correct = calibrate each image based on average backscatter over time
;correct= 1, modify calibration based on corrfactor
correct=1
corrfactor=fltarr(na,numpol,nummode)
meanval=fltarr(numpol,nummode)


;wetland mask if available
;1 = wetland area
wetmask='wetland_mask.byt'
wet=MAKE_ARRAY(ns,nl,/FLOAT, value=1.)

pol(0)='HHHH'
pol(1)='HVHV'

mode(0)='129A'
mode(1)='129B'

;19043
prefix(0)='NISARA_02602_19043_000_190701_L090'

;19048
prefix(1)='NISARA_02602_19048_000_190716_L090'

;19051
prefix(2)='NISARA_02602_19051_000_190725_L090'

;19053
prefix(3)='NISARA_02602_19053_012_190812_L090'

;19069
prefix(4)='NISARA_02602_19069_000_190923_L090'

;19070
prefix(5)='NISARA_02602_19070_002_190930_L090'


;directories for data
;day number *10+modes
ddir=strarr(numdates*10+nummode+1)
ddir(00)='19043_129A/'
ddir(01)='19043_129B/'
ddir(10)='19048_129A/'
ddir(11)='19048_129B/'
ddir(20)='19051_129A/'
ddir(21)='19051_129B/'
ddir(30)='19053_129A/'
ddir(31)='19053_129B/'
ddir(40)='19069_129A/'
ddir(41)='19069_129B/'
ddir(50)='19070_129A/'
ddir(51)='19070_129B/'

date_acq=strarr(numdates)
date_acq(0)='190701'
date_acq(1)='190716'
date_acq(2)='190725'
date_acq(3)='190812'
date_acq(4)='190923'
date_acq(5)='190930'

ct=0.
ct2=0.
ct3=0.

;pols (only real, HH and HV)
for j=0,1 do begin

  ;modes (upper and lower sideband)
  for i=0,1 do begin

;output average image for all dates
    out_all=strtrim(string(pol(j)))+'_'+strtrim(string(mode(i)),2)+'_avg.flt'
    openw,5,out_all

;print,'change mode and pol'
;dates
    for k=0,numdates-1 do begin

      inn=ddir(k*10+i)+prefix(k)+'_'+proc+'_'+pol(j)+'_'+mode(i)+'_'+vers+'.flt'

;     print,inn
      openr,3,inn
      readu,3,val
      close,3

       avg_all(j,i,*,*)=avg_all(j,i,*,*)+val/float(numdates)
;nt is the number of images in each average
;need to do rolling average over nt
       for l=0,nt-1 do begin
          if k-l ge 0 and k-l lt na then begin
              avg(k-l,j,i,*,*)=avg(k-l,j,i,*,*)+val/float(nt)
;              print,k-l,j,i,size(avg(k-l,j,i,*,*),/n_elements)
          endif
       endfor


;average backscatter for each rolling average
;      print,'k,nt,na',k, nt,na
      if k ge nt-1  and k le na+nt then begin
        outn=strtrim(string(pol(j)))+'_'+strtrim(string(mode(i)),2)+'_'+strtrim(string(k-nt+1),2)+'.flt'
        tmp=avg(k-nt+1,j,i,*,*)
    
        x=where(tmp le 0,count)
        tmp(x)=sqrt(-1)
        corrfactor(k-nt+1,j,i)=mean(tmp,/nan)
;        print,k-nt+1,j,i,corrfactor(k-nt+1,j,i)
        openw,4,outn
        writeu,4,tmp
        close,4
      endif

;end date loop
    endfor

  tmp=avg_all(j,i,*,*)
  x=where(tmp le 0,count)
  tmp(x)=sqrt(-1)
;  print,mean(tmp,/nan)
  meanval(j,i)=mean(tmp,/nan)
  writeu,5,tmp
  close,5

  
; end mode loop
  endfor
;end pol loop
endfor

x=where(tmp lt 0.00001 or finite(tmp) eq 0,count)
if count gt 0 then wet(x)=0

;print,numdates

if correct eq 1 then print,'correcting each output image based on comparison with average over entire time span'

;normalize possible correction factors to correct possible calibration errors if needed
for j=0,numpol-1 do begin
  for i=0,nummode-1 do begin
    for k=0,na-1 do begin
;      print,date_acq(k),' ',pol(j),' ',mode(i),corrfactor(k,j,i),meanval(j,i),corrfactor(k,j,i)/meanval(j,i)
      corrfactor(k,j,i)=corrfactor(k,j,i)/meanval(j,i)

; correct if necessary
      if correct eq 1 then begin
        avg(k,j,i,*,*)=avg(k,j,i,*,*)/corrfactor(k,j,i)
        outn=strtrim(string(pol(j)))+'_'+strtrim(string(mode(i)),2)+'_'+strtrim(string(k),2)+'_avg_corr.flt'
        openw,4,outn
        writeu,4,avg(k,j,i,*,*)
        close,4
      endif
    endfor
  endfor
endfor

;merge modes by mlooking them
if mlmodes eq 1 then begin
  for j=0,numpol-1 do begin
    out_all=strtrim(string(pol(j)))+'_avgml.flt'
    openw,8,out_all
    for k=0,na-1 do begin
        outn=strtrim(string(pol(j)))+'_'+strtrim(string(k),2)+'_avgml_corr.flt'
        tmp=(avg(k,j,0,*,*)+avg(k,j,1,*,*))/2.0
        x=where(tmp le 0,count)
        tmp(x)=sqrt(-1)
        avg_mlmode(k,j,*,*)=tmp
        openw,4,outn
        writeu,4,tmp
        close,4
    endfor
    avg_all_mlmode(j,*,*)=(avg_all(j,0,*,*)+avg_all(j,1,*,*))/2.0
    tmp=avg_all_mlmode(j,*,*)
    x=where(tmp le 0,count)
    tmp(x)=sqrt(-1)
    writeu,8,tmp
    close,8

  endfor
endif

;classification


;Classification of avg_all to obtain dominant state of inundation over the time period.



; classification of each date average over the timespan of all images
;compare with dominant state of inundation... TBD
if class_temporal eq 1 then begin

;class_temporal or not
 endif

if mlmodes eq 1 then nummode=1

  for i=0,nummode-1 do begin
    for k=0,na-1 do begin
        if nummode eq 0 then begin
           outn='class_'+strtrim(string(mode(i)),2)+'_'+strtrim(string(k),2)+'.byt'
           outn1ha='class_'+strtrim(string(mode(i)),2)+'_'+strtrim(string(k),2)+'_1ha.byt'
        endif
        if nummode eq 1 then begin
           outn='class_'+strtrim(string(k),2)+'.byt'
           outn1ha='class_'+strtrim(string(k),2)+'_1ha.byt'
        endif
        if mlmodes eq 1 then begin
          tmpHH=avg_mlmode(k,0,*,*)
          tmpHV=avg_mlmode(k,1,*,*)
        endif else begin
          tmpHH=avg(k,0,i,*,*)
          tmpHV=avg(k,1,i,*,*)
        endelse
print,outn
print,outn1ha


;class 0 -- inundated vegetation  first class
;if HH/HV > thresh1 and HH gt tresh2
      x=where(tmpHH/tmpHV gt T0_0 and tmpHH/tmpHV lt T0_2 and tmpHH gt T0_1 and tmpHH lt T0_3 and wet eq 1., count)
      class0=bytarr(ns,nl)
      class0(x)=1

;class 1 -- inundated vegetation second class
;if HH/HV > thresh1 and HH gt tresh2
      x=where(tmpHH/tmpHV gt T1_0 and tmpHH/tmpHV lt T1_2 and tmpHH gt T1_1 and tmpHH lt T1_3 and wet eq 1., count)
      class1=bytarr(ns,nl)
      class1(x)=1

;class 2 -- open water first class
;if HH/HV > thresh1 and HH lt tresh2
      x=where(tmpHH/tmpHV gt T2_0 and tmpHH/tmpHV lt T2_2 and tmpHH gt T2_1 and tmpHH lt T2_3 and wet eq 1., count)
      class2=bytarr(ns,nl)
      class2(x)=1

;class 3 -- open water second class
;if HH/HV > thresh1 and HH lt tresh2
      x=where(tmpHH/tmpHV gt T3_0 and tmpHH/tmpHV lt T3_2 and tmpHH gt T3_1 and tmpHH lt T3_3 and wet eq 1., count)
      class3=bytarr(ns,nl)
      class3(x)=1

;classs4 -- not inundated class
;if HH/HV > thresh1 and HH lt tresh2
      x=where(tmpHH/tmpHV gt T4_0 and tmpHH/tmpHV lt T4_2 and tmpHH gt T4_1 and tmpHH lt T4_3 and wet eq 1., count)
      class4=bytarr(ns,nl)
      class4(x)=1

; class 5 - not classified
;due to unexpected  or unphysical values
; for example

      x=where(tmpHH/tmpHV gt T5_0 and tmpHH/tmpHV lt T5_2 and tmpHH gt T5_1 and tmpHH lt T5_3 and wet eq 1., count)
      class5=bytarr(ns,nl)
      class5(x)=1

; class 6 - no class
;none of the other classes

      x=where(wet eq 1. and class0 eq 0 and class1 eq 0 and class2 eq 0 and class3 eq 0 and class4 eq 0 and class5 eq 0, count)
      class6=bytarr(ns,nl)
      class6(x)=1


initclass=bytarr(ns,nl)
x=where(wet eq 0,count)
;no data
if count gt 0 then initclass(x)=10
x=where(initclass eq 0 and class0 eq 1, count)
if count gt 0 then initclass(x)=byte(0)*class0(x)
x=where(initclass eq 0 and class1 eq 1, count)
if count gt 0 then initclass(x)=byte(1)*class1(x)
x=where(initclass eq 0 and class2 eq 1, count)
if count gt 0 then initclass(x)=byte(2)*class2(x)
x=where(initclass eq 0 and class3 eq 1, count)
if count gt 0 then initclass(x)=byte(3)*class3(x)
x=where(initclass eq 0 and class4 eq 1, count)
if count gt 0 then initclass(x)=byte(4)*class4(x)
x=where(initclass eq 0 and class5 eq 1, count)
if count gt 0 then initclass(x)=byte(5)*class5(x)
x=where(initclass eq 0 and class6 eq 1, count)
if count gt 0 then initclass(x)=byte(6)*class6(x)



;output initial class estimates
    openw,41,outn
    writeu,41,initclass
    close,41

;aggregate to 1 ha
class1ha=bytarr(ns,nl)

x1=where(initclass eq 10)
for i=0,ns-11,10 do begin
    for j=0,nl-11,10 do begin
         x=where(initclass(i:i+9,j:j+9) eq 0,count0)
         x=where(initclass(i:i+9,j:j+9) eq 1,count1)
         x=where(initclass(i:i+9,j:j+9) eq 2,count2)
         x=where(initclass(i:i+9,j:j+9) eq 3,count3)
         x=where(initclass(i:i+9,j:j+9) eq 4,count4)
         x=where(initclass(i:i+9,j:j+9) eq 5,count5)
         x=where(initclass(i:i+9,j:j+9) eq 6,count6)
         if count0 + count1 gt 33 then begin
           class1ha(i:i+9,j:J+9)=1
         endif else begin
             if count2 + count3  gt 10 then begin
                 class1ha(i:i+9,j:J+9)=2
             endif else begin
                class1ha(i:i+9,j:J+9)=3
             endelse
         endelse
    endfor
endfor


; aggregated 1ha classes
; 0 -  no data
; 1 - inundated vegetation
; 2 - open water
; 3 - not inundated

    class1ha(x1)=0
    openw,41,outn1ha
    writeu,41,class1ha
    close,41


    endfor
  endfor

;compare with change detection if desired
if change eq 1 then begin

  for i=0,nummode-1 do begin
    for k=0,na-1 do begin

;not inundated to inundated vegetation

;inundated vegetation to not inundated

;not inundated to open water

;open water to not inundated

    endfor
  endfor
endif




end
