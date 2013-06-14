#!/usr/bin/perl


## iteration counters
my $iter;
my $maxiter=25000;
## inverse Montecralo temperature
my $beta=30.;
my $beta_rate=1.0;
my $mirrors=820;
my $ntower=4;

my @list, @best_listi, @absolute_best_list;

# energy
my $energy, $max_energy, $best_energy;

## initialize the particle positions randomly or restarting

#rand_pos();
read_pos();

## main montecarlo loop
$iter = 0;
$max_energy = run_tower();
$best_energy = $max_energy;

$i = 0;
while ($i<$mirrors) {
	$absolute_best_list[$i] = $list[$i];
        $i++;
}

do {
    # cool the system a bit at every step
    $beta += $beta_rate;

    system ("cp tower-map tower-map-old");
    system ("cat tower-map >> tower-map.history");
    mod_pos();
    
    run_tower();
    if ($energy < $max_energy) {
	$param = rand();
	if (exp(-$beta * (-$energy + $max_energy) ) >= $param) {
		print  $iter, $energy;
        	$max_energy = $energy;
	
		$i = 0;
        	while ($i<$mirrors) {
            		$best_list[$i] = $list[$i];
            		$i++;
        	}
	}
	else{
		system ("cp tower-map-old tower-map");
	}
    }
    else {
	print  $iter, $energy;
	$max_energy = $energy;
 
 	$i = 0;
        while ($i<$mirrors) {
            $best_list[$i] = $list[$i];
            $i++;
        }
	if ($max_energy > $best_energy) {
		$best_energy = $max_energy;

		$i = 0;
		while ($i<$mirrors) {
        		$absolute_best_list[$i] = $best_list[$i];
	        	$i++;
		}
		save_best();
		write_best_map();
	}

    }
    write_map();    
    $iter++;
   
} until $iter > $maxiter;

exit(0);

sub read_pos {
	my $i = 0;
	open FILEIN, "<tower-map" or die $!;
	while ($list[$i] = <FILEIN>) {
	    chomp ($list[$i]);
	    $best_list[$i] = $list[$i];
	    $i++;
	}
	close FILEIN;
}

sub write_map {
	system ("awk '{if (NR>1) print \$0;}' solar_land > solar_land_tmp");
	system ("awk NF tower-map > tower-map-tmp&& paste solar_land_tmp tower-map-tmp > map.dat");
}

sub write_best_map {
	system ("awk '{if (NR>1) print \$0;}' solar_land > solar_land_tmp");
	system ("awk NF tower-map.best > tower-map-best-tmp&& paste solar_land_tmp tower-map-best-tmp > map.best.dat");
}

sub rand_pos {
	my $i = 0;
	open FILEOUT, ">tower-map" or die $!;
	do {
	    $list[$i] = int(rand() * $ntower + 1);
	    $best_list[$i] = $list[$i];
	    print FILEOUT $list[$i], "\n";
	    $i++;
	} until $i == $mirrors;
	close FILEOUT;
}

sub save_best {
	my $i = 0;
	open FILEOUTBEST, ">tower-map.best" or die $!;
	do {
	    print FILEOUTBEST $absolute_best_list[$i], "\n";
	    $i++;
	} until $i == $mirrors;
	close FILEOUTBEST;
}

sub mod_pos {
        my $tower;
	my $i = 0;
    	my $n_switch = 0;
	open FILEOUTNEW, ">tower-map" or die $!;
#	my $factor = 1.-(2./$mirrors);
	my $factor = int(rand($mirrors));
        while ($i < $mirrors) {
#        	if (rand() >= $factor) {
		if ($factor == $i) {
			$n_switch++;
			$list[$i] = int(rand() * $ntower + 1);
		}
		else {
			$list[$i] = $best_list[$i];
		}

                print FILEOUTNEW $list[$i], "\n";
		$i++;
        } 
	print $n_switch;
        close FILEOUTNEW;
}


sub run_tower {
	system ("./multiok");
        open FILE, "<energia" or die $!;
	while ($energy = <FILE>) {
		close FILE;
		return $energy;
	}
}



