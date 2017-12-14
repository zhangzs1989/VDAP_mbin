function GAP = computeMaxStationGap(eqlat,eqlon,staLat,staLon)

%{
compute the maximum station azimuthal gap
J. PESICEK 11/2017

for now, I'm using an external call to an old perl script. The meat of this code is
pasted below at bottom. 

This code should be ported into matlab at some point. (TODO) 

%}

stalist = [staLat, staLon];

save('/tmp/stalist.txt','stalist','-ascii');
str = sprintf('~/Dropbox/bin/computeAzGap.pl %f %f /tmp/stalist.txt',eqlat,eqlon);

[status,result] = system(str);

if status~=0
    details(result)
    error('external call to maxgap script failed')
end

ii = strfind(result,':');
GAP = str2double(result(ii+1:end));

% AZ = azimuth(eqlat,eqlon,staLat,staLon);

% figure
% plot(staLon,staLat,'bo',eqlon,eqlat,'go')
% title(num2str(GAP))

end

%{
#!/usr/bin/perl

$argc = $#ARGV+1;
if ($argc != 3) {
        print "Usage: computeAzGap.pl <EventLat> <EventLon> <stationList>\n";
        exit (-1);
}

$elat=shift;
$elon=shift;
$sta=shift; # station list, lat, lon

open(STA,"$sta") or die;

while (<STA>) {
        chomp;
        ($stalat,$stalon)=(split /\s+/,$_)[1,2];
#        push @staList, $sta;
        push @staLat, $stalat;
        push @staLon, $stalon;
        #print "station: $stalat \t $stalon \n";

}
close(STA);
for ($i=0;$i<@staList;$i++) { chomp $staLat[$i],  "\n"; } #print $staLat[$i], "\n"; }

#print "Event: $elat \t $elon \n";

use Math::Trig;
for ($k=0;$k<@staLat;$k++) {
        $stanorth=fromnorth($elat,$elon,$staLat[$k],$staLon[$k]);
        push @staNorth,  $stanorth;

}
#print "@staNorth\n";

$gap=computegap(@staNorth);

#sub fromnorth($late,$lone,$lat,$lon)
sub fromnorth {
        my($Elat,$Elon,$Slat,$Slon) = @_;
                if ($Elat == 90) {$Elat = 90.0001; }
                if ($Slat == 90) {$Slat = 90.0001; }
        $d2r=0.017453293;
        $A=$d2r*($Elon-$Slon);
        $b=$d2r*(90.-$Elat);       #          /* Epicenter colatitude */
        $c=$d2r*(90.-$Slat);       #          /* Station   colatitude */
        $delta=acos( cos($b)*cos($c) + sin($b)*sin($c)*cos($A) ) ; #    /* Distance     */
        $Az=acos( (cos($c)-cos($delta)*cos($b)) / (sin($delta)*sin($b)) ) ; # /* Azimuth      */
        $BAz=acos( (cos($b)-cos($delta)*cos($c)) / (sin($delta)*sin($c)) ) ;#  /* Back Azimuth */
        if ( $Slon < $Elon ){ $Az=360.*$d2r - $Az;}               # /* Clockwise correction */
        if ( $Slon > $Elon ){ $BAz = 360.*$d2r - $BAz;}
        $r  = 6371.;
        $Vp = 6.8;
        $T  = 2. * $r * sin($delta/2.) / $Vp;
        $P  = $r * cos($delta/2.) / $Vp ;                                  # /* Ray Parameter*/
#       $Ih = asin( $P*$Vp / ($r-$h) );
#       $Ih = asin( ($r/($r-$h)) * $Vp * ($T/($delta*111)) );
#        print $sta," North ", $Az/$d2r, "\n";
        return $Az/$d2r;
}

sub numerically { $a <=> $b }

#sub computegap(@fromnorth)
sub computegap {
        my(@north) = @_;
        my @sorted=();

        #print "In subroutine computegap:\n";
        for ($m=0; $m<@north; $m++) {
               if ($north[$m] < 0) {
                        $north[$m] = 360 + $north[$m];
                }
#       print "$north[$m]\n";
        }

        @sorted = sort numerically @north;
#       print "@sorted\n";

        my $last = @sorted;
        $maxdiff = 360 - ( $sorted[$last-1] - $sorted[0] );
        #print "maxdiff: $maxdiff\n";
        #print "sorted:\n";

        for ($m=0;$m<@sorted;$m++) {
                chomp $sorted[$m];
                #print $sorted[$m],"\n";

                $diff= ($sorted[$m+1]-$sorted[$m] );
                if ($diff>$maxdiff) {
                        $maxdiff=$diff;
                        #print "maxdiff: $maxdiff\n";
                        }
        }
        print "maxgap: ",$maxdiff, "\n";
        return $maxdiff;
}
%}