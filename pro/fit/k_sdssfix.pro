;+
; NAME:
;   k_sdssfix
; PURPOSE:
;   Take SDSS database asinh magnitudes and errors and "fixes" them
; CALLING SEQUENCE:
;   k_sdssfix, mags, mags_err, maggies, maggies_ivar [, /standard, aboff=]
; INPUTS:
;   mags - input asinh magnitudes (luptitudes)
;   mags_err - input uncertainties in mags
; OUTPUTS:
;   maggies - best AB maggies to use 
;   maggies_ivar - best inverse variance to use
; OPTIONAL INPUTS:
;   aboff - [5] AB offsets (defaults to list below)
; KEYWORDS:
;   /standard - assume standard magnitudes, not luptitudes
; COMMENTS:
;   This converts from SDSS database asinh magnitudes to AB maggies. 
;
;   It "fixes" errors in the sense that for "bad" measurements or
;   errors you assign values which are not absurd. Not necessary for
;   Princeton-style input (which sets ivar to zero as
;   appropriate). 
;  
;   Also adds errors in quadrature:
;     sigma(ugriz) = [0.05, 0.02, 0.02, 0.02, 0.03]
;   to account for calibration uncertainties.
;
;   Uses the AB conversions posted by D. Eisenstein (sdss-calib/???)
;     u(AB,2.5m) = u(database, 2.5m) - 0.036
;     g(AB,2.5m) = g(database, 2.5m) + 0.012
;     r(AB,2.5m) = r(database, 2.5m) + 0.010
;     i(AB,2.5m) = i(database, 2.5m) + 0.028
;     z(AB,2.5m) = z(database, 2.5m) - 0.040
;   You can specify your own with the "aboff" input.
;
;   Note that older versions (v3_2 and previous) used a different set
;   of corrections: 
;     u(AB,2.5m) = u(database, 2.5m) - 0.042   (NOT WHAT WE DO HERE)
;     g(AB,2.5m) = g(database, 2.5m) + 0.036   (NOT WHAT WE DO HERE)
;     r(AB,2.5m) = r(database, 2.5m) + 0.015   (NOT WHAT WE DO HERE)
;     i(AB,2.5m) = i(database, 2.5m) + 0.013   (NOT WHAT WE DO HERE)
;     z(AB,2.5m) = z(database, 2.5m) - 0.002   (NOT WHAT WE DO HERE)
;
;   If for whatever reason you have regular magnitudes (rather than
;   asinh), use /standard. 
;
; REVISION HISTORY:
;   07-Feb-2002  Written by Mike Blanton, NYU
;   03-Jun-2003  Updated to v3_0 by Mike Blanton, NYU
;-
;------------------------------------------------------------------------------
function k_sdss_err2ivar, err, verbose=verbose

errband=[0.05,0.02,0.02,0.02,0.03]

ivar=fltarr(5,n_elements(err)/5L)+1.E

error_indx=where(err eq -9999, error_count) 
if(error_count gt 0) then ivar[error_indx]=0.E

error_indx=where(err eq -1000, error_count) 
if(error_count gt 0) then ivar[error_indx]=0.E

error_indx=where(err eq 0, error_count) 
if(error_count gt 0) then ivar[error_indx]=0.E

if(keyword_set(verbose)) then begin
    unusual_indx=where(ivar eq 1. and err lt 0,unusual_count)
    if(unusual_count gt 0) then begin
        for i=0L,unusual_count-1L do $
          splog,'Unusual ERR value of '+string(err[unusual_indx[i]])+ $
          '; setting IVAR to zero'
        ivar[unusual_indx]=0.E
    endif
endif

for i=0L, 4L do begin
    q=err[i,*] gt 0
    ivar[i,*]=ivar[i,*]*q/((err[i,*]^2+errband[i]^2)*q+(1-q))
endfor

return, ivar

end
;
pro k_sdssfix, mags, mags_err, maggies, maggies_ivar, standard=standard, $
               aboff=aboff

bvalues=[1.4D-10, 0.9D-10, 1.2D-10, 1.8D-10, 7.4D-10]
if(NOT keyword_set(aboff)) then aboff=[-0.036, 0.012, 0.010, 0.028, -0.040]

if((size(mags))[0] eq 1) then begin
    nk=5
    ngalaxy=1
endif else begin
    nk=(size(mags,/dimens))[0]
    ngalaxy=(size(mags,/dimens))[01]
endelse

if(nk ne 5) then begin
  klog, 'k_sdssfix for 5-band SDSS observations only! ignoring ...'
  return 
endif

mags_ivar=reform(k_sdss_err2ivar(mags_err),nk,ngalaxy)

indx=where(mags eq -9999 and mags_ivar ne 0.,count)
if(count gt 0) then begin
    klog, string(count)+' cases of good error but bad value in k_sdssfix!'
    mags_ivar[indx]=0.
endif

maggies=dblarr(nk,ngalaxy)
maggies_ivar=dblarr(nk,ngalaxy)
for k=0L, nk-1L do begin
    indx=where(mags_ivar[k,*] ne 0.,count)
    if(count gt 0) then begin
        if(NOT keyword_set(standard)) then begin
            err=1./sqrt(mags_ivar[k,indx])
            maggies[k,indx]=k_lups2maggies(mags[k, indx], err, $
                                           maggies_err=merr, $
                                           bvalues=bvalues[k])* $
              10.^(-0.4*aboff[k])
            maggies_ivar[k,indx]=1./(merr*10.^(-0.4*aboff[k]))^2
        endif else begin
            maggies[k,indx]=(10.D)^(-(0.4D)*(mags[k,indx]+aboff[k]))
            maggies_ivar[k,indx]= $
              mags_ivar[k,indx]/(0.4*alog(10.)*maggies[k,indx])^2.
        endelse
    endif
endfor
indx=where(mags_ivar eq 0.,count)
if(count gt 0) then begin
   maggies[indx]=0.
   maggies_ivar[indx]=0.
endif

end
;------------------------------------------------------------------------------
