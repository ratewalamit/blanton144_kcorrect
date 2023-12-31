; oke
;
; Load atmospheric extinction curves into idl matrices.  Interpolate to
; any wavelength in the range.  Return zero outside that range.
;
; From jbo@cygnus.dao.nrc.ca Wed Jan 13 21:21:26 1999
; Date: Wed, 13 Jan 99 10:13:22 PST
; From: "J.B. Oke" <jbo@cygnus.dao.nrc.ca>
; To: hogg@IAS.EDU
; Subject: Re:  Palomar transmission
;
; I dont know how famous it is but I do have the extinction curve that I
; derived and use.  There are actually three parts to it.  The first is
; the overall extinction, the second is water vapor in the near infrared
; and the third are the oxygen A and B bands.  They are at low
; resolution and are intended to be used with linear interpolation
; between points.  The last two are not very accurate and both use a
; square root extinction law since the individuallines are highly
; saturated.
;
; Below are the three which are intended for use at Palomar.  The format
; is just a C array.
;
; Bev
;
; Here are the equations I [Bev] use [in C notation]:
; For water vapor
;
;    temp=wex[1][j-1]+(((a[0][i]-wex[0][j-1])/(wex[0][j]-wex[0][j-1]))*
;         (wex[1][j]-wex[1][j-1]));
;    a[2][i]=a[2][i]-sqrt(kwv*0.00100*temp*mean);
;
; Here kwv is a scaling factor which is typically 1.0.
;
; For oxygen
;
;    temp=ox[1][j-1]+(((a[0][i]-ox[0][j-1])/(ox[0][j]-ox[0][j-1]))*
;         (ox[1][j]-ox[1][j-1]));
;    a[2][i]=a[2][i]-sqrt(0.001*temp*mean);
;
; I believe that in the above a[2][i] is the raw magnitude which is
; corrected then foe extinction in magnitudes.
;
; -----------------------------------------------------------------------------
; oke: return extinction, given a vector of wavelengths, a
; water-vapor constant kwv, and an airmass.
;
pro oke, lambda, kwv, airmass, a

    exl= [2999,3100,3110,3120,3130,3140,3150,3160,3180,3200, $
          3220,3240,3260,3280,3300,3320,3340,3360,3380,3400, $
          3450,3500,3550,3600,3700,3800,3900,4000,4100,4200, $
          4300,4400,4500,4600,4700,4800,4900,5000,5200,5400, $
          5600,5800,6000,6100,6200,6500,6980,7140,7390,7560, $
          7730,8106,8440,8902,9706,9860,10800,12500]
    ex=  [5.000,1.887,1.758,1.627,1.509,1.418,1.344,1.284,1.175,1.084, $
          1.015,0.951,0.902,0.874,0.830,0.798,0.772,0.747,0.727,0.708, $
          0.662,0.624,0.591,0.558,0.504,0.456,0.414,0.376,0.345,0.317, $
          0.291,0.269,0.249,0.233,0.218,0.205,0.193,0.184,0.169,0.157, $
          0.148,0.141,0.136,0.131,0.123,0.100,0.076,0.070,0.064,0.060, $
          0.057,0.051,0.047,0.043,0.037,0.036,0.032,0.030]
    wexl= [2999,3000,4000,5000,6000,6843,6980, $
           7147,7162,7186,7200,7220,7242,7310,7340,7390, $
           7560,7730, $
           8106,8140,8169,8210,8232,8260,8280,8330,8370,8420,8440, $
           8902,8960,8998,9020,9044,9058,9078,9158,9216, $
           9227,9252,9288,9349,9383,9392,9413,9454,9606,9706, $
           10000,15000]
    wex=  [0.000,0.000,0.000,0.000,0.000,0.000,0.00, $
           0.00,0.31,5.95,5.21,1.32,3.62,1.04,0.07,0.00, $
           0.00,0.00, $
           0.00,1.02,6.08,1.52,5.77,1.22,1.85,0.78,0.12,0.02,0.00, $
           0.00,1.10,14.10,12.10,0.30,0.30,6.90,8.50,0.60, $
           5.50,1.90,2.90,265.4,170.8,50.0,37.3,106.6,36.0,0.00, $
           0.00,0.00]
    oxl= [2999,3000,4000,5000,6000,6843,6854,6877,6930,6980, $
          7560,7578,7590,7605,7647,7663,7682,7700,7730, $
          10000,15000]
    ox=  [0.000,0.000,0.000,0.000,0.000,0.000,0.54,15.80,0.57,0.00, $
          0.00,2.20,42.0,528.0,189.0,42.0,4.20,0.30,0.00, $
          0.00,0.00]

    tmp1= interpol(ex,exl,lambda)
    tmp2= interpol(wex,wexl,lambda)
    tmp3= interpol(ox,oxl,lambda)

    a= ((lambda GE 2999.0) AND (lambda LE 12500.0))* $
    	tmp1*airmass+sqrt(kwv*0.00100*tmp2*airmass)+sqrt(0.001*tmp3*airmass)
    a= a+(lambda LT 2999.0)*5.0*airmass

end
;
; -----------------------------------------------------------------------------
; plotoke: check that the results look reasonable
;
pro plotoke

    lambda= 2000.0+findgen(6000)*2.0
    oke, lambda, 1.0, a1
    oke, lambda, 0.0, a0
    plot, lambda, a1, $
        yrange=[0,1.0]
    oplot, lambda, a0

end
