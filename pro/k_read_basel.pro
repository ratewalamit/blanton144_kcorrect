;+
; NAME:
;   k_read_basel
;
; PURPOSE:
;
; CALLING SEQUENCE:
;
; INPUTS:
;
; OPTIONAL INPUTS:
;
; OUTPUTS:
;
; OPTIONAL INPUT/OUTPUTS:
;
; COMMENTS:
;
; EXAMPLES:
;
; BUGS:
;
; PROCEDURES CALLED:
;
; REVISION HISTORY:
;   17-Jan-2002  Translated to IDL by Mike Blanton, NYU
;-
;------------------------------------------------------------------------------
pro k_read_basel,lambda,flux,filename,teff=teff,logg=logg, mh=mh,vturb=vturb, $
                 xh=xh

; Need at least 3 parameters
if (N_params() LT 3) then begin
    klog, 'Syntax - k_read_basel, lambda, flux, filename, [teff=,logg=, mh=,vturb=, xh=]'
    return
endif

lambda=dblarr(1221)

tmpflux=dblarr(1221)
tmpmodelno=0L
tmpteff=0L
tmplogg=0.d
tmpmh=0.d
tmpvturb=0.d
tmpxh=0.d

openr,unit,filename,/get_lun
readf,unit,lambda
nunits=0L
while(NOT eof(unit)) do begin
    readf,unit,tmpmodelno,tmpteff,tmplogg,tmpmh,tmpvturb,tmpxh
    readf,unit,tmpflux
    nunits=nunits+1L
end
outstr=strtrim(string(nunits),2)+' block(s) of spectra'
klog,outstr
close,unit
free_lun,unit

flux=dblarr(1221,nunits)
modelno=lonarr(nunits)
teff=lonarr(nunits)
logg=dblarr(nunits)
mh=dblarr(nunits)
vturb=dblarr(nunits)
xh=dblarr(nunits)

openr,unit,filename,/get_lun
readf,unit,lambda
nunits=0L
while(NOT eof(unit)) do begin
    readf,unit,tmpmodelno,tmpteff,tmplogg,tmpmh,tmpvturb,tmpxh
    readf,unit,tmpflux
    modelno[nunits]=tmpmodelno
    teff[nunits]=tmpteff
    logg[nunits]=tmplogg
    mh[nunits]=tmpmh
    vturb[nunits]=tmpvturb
    xh[nunits]=tmpxh
    flux[*,nunits]=tmpflux
    nunits=nunits+1L
end
close,unit
free_lun,unit

end
;------------------------------------------------------------------------------

