function [ lats, lons ] = Rprofile(latA,lonA,latAp,lonAp,half_width)

% #*---------------------------------------------------------------------------
% #*
% #*      Copyright (c) 2000-2004 by Onur TAN
% #*      See COPYING file for copying and redistribution conditions.
% #*
% #*      This program is free software; you can redistribute it and/or modify
% #*      it under the terms of the GNU General Public License as published by
% #*      the Free Software Foundation; version 2 of the License.
% #*
% #*      This program is distributed in the hope that it will be useful,
% #*      but WITHOUT ANY WARRANTY; without even the implied warranty of
% #*      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% #*      GNU General Public License for more details.
% #*
% #*      Contact info:   Onur TAN,
% #*                      Istanbul Technical University, Faculty of Mines
% #*                      Department of Geophysics, Maslak, Istanbul-TURKEY
% #*                      www.geop.itu.edu.tr/~onur
% #*                      tano@itu.edu.tr
% #*--------------------------------------------------------------------------*/
% 
% #*********          Rprofile                    **************************
% #*Rprofile generates coordinates of a rectangle corners for a given profile
% #*points and its half-width in km. The lat-lon of 5 points (closed-poligon)
% #*is written to standart output.
% #
% #*Formulation by Ahmet OKELER (okelerah@itu.edu.tr)
% #*C++ code by Onur TAN (tano@itu.edu.tr)
% #*Istanbul Tech. Univ.-Geophysics
% #*
% #*Converted to perl by Jeremy Pesicek Aug. 08
% #*
% #*Usage: Rprofile lat-A lon-A lat-B lon-B half-width
% #*
% 
% $argc   = $#ARGV+1;
% if ($argc != 5) {
%         print "Rprofile generates coordinates of a rectangle's corners for a given profile's\n";
%         print "points and its half-width in km. The lat and lon of 5 points (closed-polygon)\n";
%         print "are written to standard output.\n";
%         print "Usage: Rprofile.pl lat-A lon-A lat-B lon-B half-width\n";
%         exit (-1);
% }

Ax = lonA;
Ay = latA;
Bx = lonAp;
By = latAp;
W = half_width;

%Common values
% $pi=3.1415926536;
rad=pi/180.0;
deg=180.0/pi;

Cx=60*1.4290;
Cy=60*1.8505;

CenterX=(Ax+Bx)/2.0;
CenterY=(Ay+By)/2.0;

Mx1=Ax-CenterX;
My1=Ay-CenterY;
x1=Mx1*Cx;
y1=My1*Cy;
Mx2=Bx-CenterX;
My2=By-CenterY;
x2=Mx2*Cx;
y2=My2*Cy;

X=x2-x1;
Y=y2-y1;

if(X == 0)
    alpha=90;
else
    alpha=deg*atan2(Y,X);
end

beta=90.0-alpha;

j1=cos(beta*rad)*W;
j2=sin(beta*rad)*W;

Point1x=((x1-j1)/Cx)+CenterX;
Point1y=((y1+j2)/Cy)+CenterY;

Point2x=((x1+j1)/Cx)+CenterX;
Point2y=((y1-j2)/Cy)+CenterY;

Point3x=((x2+j1)/Cx)+CenterX;
Point3y=((y2-j2)/Cy)+CenterY;

Point4x=((x2-j1)/Cx)+CenterX;
Point4y=((y2+j2)/Cy)+CenterY;

% printf "%7.3f %7.3f\n",$Point1y,$Point1x;
% printf "%7.3f %7.3f\n",$Point2y,$Point2x;
% printf "%7.3f %7.3f\n",$Point3y,$Point3x;
% printf "%7.3f %7.3f\n",$Point4y,$Point4x;
% printf "%7.3f %7.3f\n",$Point1y,$Point1x;

lons = [Point1x, Point2x, Point3x, Point4x, Point1x ];
lats = [Point1y, Point2y, Point3y, Point4y, Point1y ];
