;+
; NAME:
;   k_specK
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
;   06-Feb-2002  Translated to IDL by Mike Blanton, NYU
;-
;------------------------------------------------------------------------------
pro k_speck,savfile,outsavfile, to_z=to_z, subsample=subsample

if (not keyword_set(to_z)) then to_z=0.1

restore,savfile

ngalaxy=n_elements(sp)
if(n_elements(subsample) eq 0) then subsample=1l
indx=lindgen(ngalaxy/long(subsample))*long(subsample)
sp=sp[indx]
ngalaxy=n_elements(indx)
help,ngalaxy

mags=dblarr(5,n_elements(sp))
mags0=dblarr(5,n_elements(sp))
for i=0l, n_elements(sp)-1l do begin
    readspec,sp[i].plate,sp[i].fiberid,flux=fluxspec,wave=waveimg

    if(n_elements(fluxspec) gt 1 and n_elements(waveimg) gt 1) then begin 
; Look at magnitudes at this redshift
        if(n_elements(scalespec) eq 0) then begin
            scalespec=1./waveimg^2
            scales=filter_thru(scalespec,waveimg=waveimg,/toair)
        endif
        fluxes=filter_thru(fluxspec,waveimg=waveimg,/toair)
        mags[*,i]=-2.5*alog10(fluxes/scales)
        
; Look at magnitudes in z=zzero bands
        wavescale=(1.+to_z)/(1.+sp[i].z)
        waveimg=wavescale*waveimg
        fluxes=filter_thru(fluxspec,waveimg=waveimg,/toair)
        mags0[*,i]=-2.5*alog10(fluxes/scales)+ $
          2.5*alog10((1.+to_z)/(1.+sp[i].z))
    endif
end

galaxy_maggies=galaxy_maggies[*,indx]
galaxy_invvar=galaxy_maggies[*,indx]
coeff=coeff[*,indx]
save,galaxy_maggies,galaxy_invvar,sp,coeff,ematrix,bmatrix,lambda, $
  filterlist,filename=outsavfile,mags,mags0

end
