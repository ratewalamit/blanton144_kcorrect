;+
; NAME:
;   k_deep_tests
; PURPOSE:
;   runs tests on DEEP data
; CALLING SEQUENCE:
;   k_deep_tests
; REVISION HISTORY:
;   2005-04-07 MRB, NYU
;-
;------------------------------------------------------------------------------
pro k_deep_tests, vname=vname

deep=mrdfits(getenv('KCORRECT_DIR')+ $
             '/data/redshifts/deep/zcat.dr1.uniq.fits.gz',1)
igot=where(deep.zquality ge 3 and deep.zhelio gt 0.01 and deep.zhelio lt 2.) 

lowz=lowz_read(sample='drtwo14')
im=hogg_mrdfits(vagc_name('object_sdss_imaging'),1, nrow=28800)
im=im[lowz.object_position]

for i=0L, 4999L do begin
    maxvmax=max(1./lowz.vmax)
    chances=(1./lowz.vmax)/maxvmax
    tmp_ideep=where(randomu(seed, n_elements(lowz)) lt chances, npick)
    if(i eq 0) then begin
        ideep=tmp_ideep
    endif else begin
        ideep=[ideep, tmp_ideep]
    endelse
endfor
sdss_redshift=lowz[ideep].zdist
im=im[ideep]
deep_redshift=0.5+1.*randomu(seed,n_elements(im))

bri=sdss2deep(sdss_redshift, deep_redshift, calibobj=im, vname=vname)

ipass=where(bri[1,*] lt 24.1 and $
            (bri[0,*]-bri[1,*] lt 2.35*(bri[1,*]-bri[2,*])-0.45 OR $
             bri[1,*]-bri[2,*] gt 1.15 OR $
             bri[0,*]-bri[1,*] lt 0.5))
bri=bri[*,ipass]
sdss_redshift=sdss_redshift[ipass]
deep_redshift=deep_redshift[ipass]
im=im[ipass]

k_print, filename='k_test_sdss2deep.ps'
hogg_usersym, 10, /fill
!P.MULTI=[0,1,2]
!Y.MARGIN=0
hogg_scatterplot, deep_redshift, bri[0,*]-bri[1,*], /cond, xnpix=40, $
  ynpix=20, xra=[0.5, 1.5], xcharsize=0.0001, ycharsize=1.4, $
  ytitle='!8B-R!6', yra=[-0.3,4.5], quantiles=[0.05, 0.2, 0.5, 0.8, 0.95], $
  exp=0.5, satfrac=0.001
djs_oplot, deep.zhelio, deep.magb-deep.magr, psym=3, symsize=0.35, $
  color='red'
hogg_scatterplot, deep_redshift, bri[1,*]-bri[2,*], /cond, xnpix=40, $
  ynpix=20, xra=[0.5, 1.5], xcharsize=1.4, ycharsize=1.4, ytitle='!8R-I!6', $
  xtitle='!8z!6', yra=[-0.3,2.3], quantiles=[0.05, 0.2, 0.5, 0.8, 0.95], $
  exp=0.5, satfrac=0.001
djs_oplot, deep.zhelio, deep.magr-deep.magi, psym=3, symsize=0.35, $
  color='red'
hogg_scatterplot, deep.zhelio, deep.magb-deep.magr, /cond, xnpix=40, $
  ynpix=20, xra=[0.5, 1.5], xcharsize=0.0001, ycharsize=1.4, $
  ytitle='!8B-R!6', yra=[-0.3,4.5], quantiles=[0.05, 0.2, 0.5, 0.8, 0.95], $
  exp=0.5, satfrac=0.001
hogg_scatterplot, deep.zhelio, deep.magr-deep.magi, /cond, xnpix=40, $
  ynpix=20, xra=[0.5, 1.5], xcharsize=1.4, ycharsize=1.4, ytitle='!8R-I!6', $
  xtitle='!8z!6', yra=[-0.3,2.3], quantiles=[0.05, 0.2, 0.5, 0.8, 0.95], $
  exp=0.5, satfrac=0.001
k_end_print

save

stop

nmgy=1.e+9*10.^(-0.4*bri)
ivar=1./(nmgy*0.05)^2
sdss_kc=sdss_kcorrect(sdss_redshift, calibobj=im, vname=vname, $
                      absmag=sdss_absmag)
kc=deep_kcorrect(deep_redshift, nmgy=nmgy, ivar=ivar, /sdss, $
                 absmag=deep_absmag, vname=vname, rmaggies=rmaggies, $
                 omaggies=omaggies)

k_print, filename='k_test_deep_kcorrect.ps'
!P.MULTI=[0,1,2]
hogg_scatterplot, deep_redshift, deep_absmag[1,*]-sdss_absmag[0,*], /cond, $
  xnpix=36, ynpix=18, xra=[0.5, 1.5], xcharsize=0.0001, ycharsize=1.4, $
  ytitle=textoidl('!8\Delta u!6'), yra=[-0.7,0.7], $
  quantiles=[0.05, 0.2, 0.5, 0.8, 0.95], exp=0.5, satfrac=0.001
hogg_scatterplot, deep_redshift, deep_absmag[2,*]-sdss_absmag[1,*], /cond, $
  xnpix=36, ynpix=18, xra=[0.5, 1.5], xcharsize=1.4, ycharsize=1.4, $
  ytitle=textoidl('!8\Delta g!6'), yra=[-0.7,0.7], $
  quantiles=[0.05, 0.2, 0.5, 0.8, 0.95], exp=0.5, satfrac=0.001
hogg_scatterplot, sdss_redshift, deep_absmag[1,*]-sdss_absmag[0,*], /cond, $
  xnpix=36, ynpix=18, xra=[0.001, 0.05], xcharsize=0.0001, ycharsize=1.4, $
  ytitle=textoidl('!8\Delta u!6'), yra=[-0.7,0.7], $
  quantiles=[0.05, 0.2, 0.5, 0.8, 0.95], exp=0.5, satfrac=0.001
hogg_scatterplot, sdss_redshift, deep_absmag[2,*]-sdss_absmag[1,*], /cond, $
  xnpix=36, ynpix=18, xra=[0.001, 0.05], xcharsize=1.4, ycharsize=1.4, $
  ytitle=textoidl('!8\Delta g!6'), yra=[-0.7,0.7], $
  quantiles=[0.05, 0.2, 0.5, 0.8, 0.95], exp=0.5, satfrac=0.001
k_end_print


end
