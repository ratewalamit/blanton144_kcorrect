;+
; NAME:
;   k_espec_plot
;
; PURPOSE:
;   Make plot of eigenspectra for K-correct paper
;
; CALLING SEQUENCE:
;   k_espec_plot,version,[vpath=]
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
pro k_espec_plot,version,vpath=vpath,lamlim=lamlim,psfile=psfile

if(n_elements(vpath) eq 0) then $
  vpath=getenv('KCORRECT_DIR')+'/data/etemplates'
if(n_elements(lamlim) eq 0) then lamlim=[2000.,10000.]

k_load_ascii_table,ematrix,vpath+'/ematrix.'+version+'.dat'
k_load_ascii_table,bmatrix,vpath+'/bmatrix.'+version+'.dat'
k_load_ascii_table,lambda,vpath+'/lambda.'+version+'.dat'
nt=(size(ematrix))[2]
nl=n_elements(lambda)-1l

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
axis_char_scale= 2.0
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

espec=bmatrix#ematrix
lam=0.5*(lambda[0l:nl-1l]+lambda[1l:nl])
indx=where(lam gt lamlim[0] and lam lt lamlim[1])
!p.multi=[nt,1,nt]
for i=0, nt-1l do begin
    print,i
    !Y.RANGE=[-0.5*max(abs(espec[indx,i])),0.5*max(abs(espec[indx,i]))]
    if(i eq 0) then $
      !Y.RANGE=[0.,0.7*max(espec[indx,i])]
    !X.CHARSIZE = tiny
    !X.TITLE = ''
    if(i eq nt-1) then !X.CHARSIZE = axis_char_scale
    if(i eq nt-1) then !X.TITLE = 'Wavelength (Angstroms)'
    djs_plot,lam,espec[*,i],xst=1,yst=1,xra=lamlim,thick=4
    djs_oplot,lam,0.*lam,linestyle=1
    xyouts,lam[n_elements(lam)/2],!Y.RANGE[1]-0.2*(!Y.RANGE[1]-!Y.RANGE[0]), $
      'Eigenspectrum #'+strtrim(string(i),2)
endfor

if(keyword_set(psfile)) then begin
    device, /close
    set_plot,'x'
endif
    
end
;------------------------------------------------------------------------------
