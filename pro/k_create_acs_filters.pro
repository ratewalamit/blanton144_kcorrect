;+
; NAME:
;   k_create_acs_filters
; PURPOSE:
;   Take the set of given ACS filters and make ascii format files
; CALLING SEQUENCE:
; INPUTS:
; OPTIONAL INPUTS:
; KEYWORDS:
; OUTPUTS:
; OPTIONAL INPUT/OUTPUTS:
; COMMENTS:
; EXAMPLES:
; BUGS:
; PROCEDURES CALLED:
; REVISION HISTORY:
;   12-Feb-2003  WRitten by Mike Blanton, NYU
;-
;------------------------------------------------------------------------------
pro k_create_acs_filters 

; get ccd response
ccd1file=getenv('KCORRECT_DIR')+'/data/filters/acs/acs_wfc_ccd1_016_syn.fits'
ccd1=mrdfits(ccd1file,1)

filters=findfile(getenv('KCORRECT_DIR')+'/data/filters/acs/*.fits')
for i=0L, n_elements(filters)-1L do begin
    prefix=(stregex(filters[i],'acs\/(.*)\.fits',/extract,/subexpr))[1]
    filt=mrdfits(filters[i],1) 
    ccd1interp=interpol(ccd1.throughput,ccd1.wavelength,filt.wavelength)
    filt.throughput=filt.throughput*ccd1interp
    openw,unit,getenv('KCORRECT_DIR')+'/data/filters/'+prefix+'.dat',/get_lun
    printf,unit,format='(i10,1x,i10,1x,i10)',n_elements(filt),2,2
    for j=0L, n_elements(filt)-1L do begin
        printf,unit,format='(f14.6,1x,f14.6)', filt[j].wavelength, $
          filt[j].throughput
    endfor
    free_lun,unit
endfor

end
;------------------------------------------------------------------------------
