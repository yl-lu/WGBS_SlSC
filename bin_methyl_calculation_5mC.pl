#!/usr/bin/perl
use warnings;
use strict;
my @chr_length = qw(chr0 98455869 55977580 72290146 66557038 66723567 49794276 68175699 65987440 72906345 65633393 56597135 68126176);
my @array1 = qw(CG CHG CHH);
my @array2 = qw(MS VC GC SC);
for my $context (@array1){
	for my $stage (@array2){
		for (1..12){
			my $i = (sprintf "%02d", $_);
			open IN_CT_table, "< /public/home/yllu/data/BS_seq/CT_table_cov10_mC_context/${context}_${stage}_ch${i}.cout.cov10" or die $!;
			open OUT, "> /public/home/yllu/data/BS_seq/circos/${context}_${stage}_ch${i}.plotfile" or die $!;
			my %hash;  
			my $window_SN;
			while(<IN_CT_table>){
				chomp;
				my @each_line = split /\t/, $_;	
				my $pos = $each_line[1];
				my $value = $each_line[5];	
				$window_SN = int(($pos - 1)/ 100000);	
				unless(exists $hash{$window_SN}){ 
					$hash{$window_SN}{'sum'} = 0;
					$hash{$window_SN}{'count'} = 0;
				} 		
				$hash{$window_SN}{'sum'} += $value;
				$hash{$window_SN}{'count'} ++;
			}
			my @a = sort {$a <=> $b} keys %hash;	
			$window_SN = $a[-1];
			for (my $j = 0; $j<= $window_SN; $j++){
				unless (exists $hash{$j}){
					$hash{$j}{'sum'} = 0;
					$hash{$j}{'count'} = 1;
				}
			}
			my $win_number = keys %hash;
			print "chr${i}: $window_SN\n";
			print "chr${i}: $win_number\n";
			my @number = sort {$a <=> $b} keys %hash;
			print "chr${i}: @number"."\n";
			foreach my $window(sort {$a <=> $b} keys %hash){ 
				my $sum = $hash{$window}{'sum'};
				my $count = $hash{$window}{'count'};
				my $avg = sprintf("%.0f",($sum/$count)*10000);
				my $start = $window * 100000 + 1;	
				my $end;
				if ($window == ($win_number-1)){
					$end = $chr_length[$i];
				}else {
					$end = ($window + 1) * 100000;
				}
				my $j = (sprintf "%01d", $i);
				print OUT "chr${j}\t$start\t$end\t$avg\n";	
			}
			close IN_CT_table;
			close OUT;
		}
	}
}