;+
; NAME:
;   k_coeffdist_plot
;
; PURPOSE:
;   Make plot of distribution of coefficients for K-correct paper
;
; CALLING SEQUENCE:
;   k_coeffdist_plot,version,[vpath=]
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
;   Change to using main sample only, and cutting on M_r; cannot
;   determine much from color-selected samples...
;
; PROCEDURES CALLED:
;   k_load_ascii_table
;
; REVISION HISTORY:
;   23-Jan-2002  Translated to IDL by Mike Blanton, NYU
;-
;------------------------------------------------------------------------------
pro k_coeffdist_plot,version,vpath=vpath,basecoeff=basecoeff,subsample=subsample,nsig=nsig,psfile=psfile

if(n_elements(vpath) eq 0) then $
  vpath=getenv('KCORRECT_DIR')+'/data/etemplates'
if(n_elements(lamlim) eq 0) then lamlim=[2000.,10000.]
if(n_elements(basecoeff) eq 0) then basecoeff=3
if(n_elements(nsig) eq 0) then nsig=3.

k_load_ascii_table,coeff,vpath+'/coeff.'+version+'.dat'
k_load_ascii_table,ematrix,vpath+'/ematrix.'+version+'.dat'
k_load_ascii_table,bmatrix,vpath+'/bmatrix.'+version+'.dat'
k_load_ascii_table,lambda,vpath+'/lambda.'+version+'.dat'
nt=long((size(ematrix))[2])
ngalaxy=long(n_elements(coeff))/nt
nl=n_elements(lambda)-1l

coeffmean1=djs_avsigclip(coeff[1,*]/coeff[0,*])
coeffmean2=djs_avsigclip(coeff[2,*]/coeff[0,*])
speccoeffs=[ $
             [1.,coeffmean1,coeffmean2,-0.16], $
             [1.,coeffmean1,coeffmean2,-0.06],$
             [1.,coeffmean1,coeffmean2,0.10] $
           ]
nspecs=(size(speccoeffs))[2]

if(n_elements(subsample) eq 0) then subsample=1l
indx=lindgen(ngalaxy/long(subsample))*long(subsample)
coeff=coeff[*,indx]

if(keyword_set(psfile)) then begin
    set_plot, "PS"
    xsize= 7.5 & ysize= 7.5
    device, file=psfile,/inches,xsize=xsize,ysize=ysize, $
      xoffset=(8.5-xsize)/2.0,yoffset=(11.0-ysize)/2.0,/color,/encapsulated
    !P.FONT= -1 & !P.BACKGROUND= 255 & !P.COLOR= 0
endif else begin
    set_plot,'x'
endelse
!P.THICK= 2.0
!P.CHARTHICK= !P.THICK & !X.THICK= !P.THICK & !Y.THICK= !P.THICK
!P.CHARSIZE= 1.2
axis_char_scale= 1.0
tiny= 1.d-4
!P.PSYM= 0
!P.TITLE= ''
!X.STYLE= 1
!X.CHARSIZE= axis_char_scale
!X.MARGIN= [1,1]*0.5*axis_char_scale
!X.OMARGIN= [6,6]*axis_char_scale
!X.RANGE= 0
!Y.STYLE= 1
!Y.CHARSIZE= !X.CHARSIZE
!Y.MARGIN= 0.6*!X.MARGIN
!Y.OMARGIN= 0.6*!X.OMARGIN
!Y.RANGE= 0
xyouts, 0,0,'!3'


; Make a vector of 16 points, A[i] = 2pi/16:
A = FINDGEN(17) * (!PI*2/16.)
; Define the symbol to be a unit circle with 16 points, 
; and set the filled flag:
USERSYM, COS(A), SIN(A), /FILL

; make useful vectors for plotting
colorname= ['red','green','blue','magenta','cyan','dark yellow', $
            'purple','light green','orange','navy','light magenta', $
            'yellow green']
ncolor= n_elements(colorname)

!p.multi=[2*(nt-2),nt-2,2]
espec=bmatrix#ematrix
lam=0.5*(lambda[0l:nl-1l]+lambda[1l:nl])
indx=(lindgen(nt-1)+1)[where(lindgen(nt-1)+1 ne basecoeff)]
for i=0, n_elements(indx)-1 do begin
    xrat=coeff[basecoeff,*]/coeff[0,*]
    yrat=coeff[indx[i],*]/coeff[0,*]
    xsig=djsig(xrat)
    ysig=djsig(yrat)
    xmean=mean(xrat)
    ymean=mean(yrat)
    !X.CHARSIZE= tiny
    !Y.CHARSIZE= tiny
    !X.RANGE= xmean+nsig*[-0.7*xsig,1.3*xsig]
    !Y.RANGE= ymean+nsig*[-xsig,xsig]
    djs_plot,xrat,yrat,psym=3,xst=1,yst=1
    axis,!X.RANGE[0],!Y.RANGE[1],xaxis=1,xcharsize=axis_char_scale, $
      xtitle='a!d3!n/a!d0'
    if(i eq 0) then $
      axis,!X.RANGE[0],!Y.RANGE[0],yaxis=0,ycharsize=axis_char_scale, $
      ytitle='a!d1!n/c!d0'
    if(i eq n_elements(indx)-1) then $
      axis,!X.RANGE[1],!Y.RANGE[0],yaxis=1,ycharsize=axis_char_scale, $
      ytitle='a!d2!n/c!d0'
    for j=0,nspecs-1 do begin
        djs_oplot,[speccoeffs[basecoeff,j]],[speccoeffs[indx[i],j]],psym=8, $
          color=colorname[j],/fill
    endfor
endfor

!X.CHARSIZE= axis_char_scale
!Y.CHARSIZE= axis_char_scale
!p.multi=[1,1,2]
spec=espec#speccoeffs
out=spec[*,0]/max(spec[*,0])
djs_plot,lam,out,xst=1,yst=1,yra=[-0.1,1.1],xra=[2000.,11000.],/nodata, $
  xtitle='Wavelength (Angstroms)', ytitle='f!d!4k!3', $
  ycharsize=axis_char_scale, xcharsize=axis_char_scale
xout=lam[n_elements(lam)/9]
yout=0.95
xyouts,xout,yout,'a!d1!n/a!d0!n='+ $
      strtrim(string(speccoeffs[1,0],format='(f5.2)'),2)
yout=0.85
xyouts,xout,yout,'a!d2!n/a!d0!n='+ $
      strtrim(string(speccoeffs[2,0],format='(f5.2)'),2)
for j=0, nspecs-1 do begin
    out=spec[*,j]/max(spec[*,j])
    djs_oplot,lam,out,color=colorname[j],thick=6
    xout=lam[n_elements(lam)/2]
    yout=out[n_elements(lam)/2]+0.02
    xyouts,xout,yout,'a!d3!n/a!d0!n='+ $
      strtrim(string(speccoeffs[basecoeff,j],format='(f5.2)'),2)
endfor

if(keyword_set(psfile)) then begin
    device, /close
    set_plot,'x'
endif
    
end
;------------------------------------------------------------------------------