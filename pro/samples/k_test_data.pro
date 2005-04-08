;+
; NAME:
;   k_test_data
; PURPOSE:
;   gather test data and put into $KCORRECT_DIR/data/test
; CALLING SEQUENCE:
;   k_test_data [, /sdss, /deep, /galex, /twomass, /synth]
; KEYWORDS:
;   /sdss - gather data from spAll.fits and from Fermi spSpec files
;   /deep - gather some DEEP data
;   /galex - gather some GALEX data, and match to SDSS
;   /twomass - gather some TWOMASS data, and match to SDSS
;   /synth - synthesize some data
;   /all - do all of above
; COMMENTS:
;   Creates in $KCORRECT_DIR/data/test:
;     spall_test.fits
;     spspec_test.fits
;     galex_test.fits
;     deep_test.fits
;     twomass_test.fits
;     synth_test.fits
; BUGS:
;   Not finished yet.
; REVISION HISTORY:
;   07-Apr-2005  Written by Mike Blanton, NYU
;-
;------------------------------------------------------------------------------
pro k_test_data, sdss=sdss, deep=deep, galex=galex, twomass=twomass, $
                 synth=synth, all=all

if(keyword_set(sdss) gt 0 OR keyword_set(all) gt 0) then begin
    
endif

if(keyword_set(sdss) gt 0 OR keyword_set(all) gt 0) then begin
    spawn, getenv('KCORRECT_DIR')+'/data/redshifts/deep/get_deep'
    deep=mrdfits(getenv('KCORRECT_DIR')+ $
                 '/data/redshifts/deep/zcat.dr1.uniq.fits.gz',1)
    indx=shuffle_indx(n_elements(deep), num_sub=500)
    deep=deep[indx]
    mwrfits, deep, getenv('KCORRECT_DIR')+'/data/test/deep_test.fits'
endif

if(keyword_set(galex) gt 0 OR keyword_set(all) gt 0) then begin
    galex=mrdfits(getenv('VAGC_REDUX')+'/object_galex.fits',1)
    indx=shuffle_indx(n_elements(galex), num_sub=500)
    galex=galex[indx]
    mwrfits, galex, getenv('KCORRECT_DIR')+'/data/test/galex_test.fits'
endif

if(keyword_set(twomass) gt 0 OR keyword_set(all) gt 0) then begin
    twomass=mrdfits(getenv('VAGC_REDUX')+'/object_twomass.fits',1)
    indx=shuffle_indx(n_elements(twomass), num_sub=500)
    twomass=twomass[indx]
    mwrfits, twomass, getenv('KCORRECT_DIR')+'/data/test/twomass_test.fits'
endif

end
