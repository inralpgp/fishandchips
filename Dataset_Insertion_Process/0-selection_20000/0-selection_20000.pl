#!/usr/bin/perl
# Copyright {2017} INRA (Institut National de Recherche Agronomique - FRANCE) 
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

my $VERSION = '0.1';
my $lastModif = '12April2017';

use strict;
use warnings;
use DBI;
use Bio::SeqIO;
use Bio::SeqFeature::Generic;
use Statistics::Descriptive;
use Data::Dumper;
use File::Basename;
use Getopt::Long;


###############################
#Custom Module
use lib '/usr/lib/perl5';

###############################

my $datasetlist= $ARGV[0];
my $directory= $ARGV[1];

GetOptions("h|help"           => \&help); 



&main($datasetlist,$directory);
#*********************************************************************************************
#***********************************          MAIN           ******************************************
#    ~/bin/dev/textMining_V5.pl -p 50 -s datasets.txt  -dir ../WorkingDirectoryInsertionProcess/
#*********************************************************************************************

sub main {
	my $self = {};
	bless $self; 
	my $dataset_list = shift;
	my $dir = shift;
	
	$self->{param}->{datasets}= $dataset_list;
	$self->{param}->{directory}= $dir;

	my @files = () ;
	
	open(GO, $dataset_list) or die "impossible d'ouvrir $dataset_list ! \n" ;
	while (<GO>){
		if($_=~ m/^#/){
			next;
		}
		else{
			chomp;
			$_ =~ /([^\t]*)\t[^\t]*\t[^\t]*.*/ ;
			push(@files, "$1");
			#$1 : SRP
			#$2 : study
			#$3 : specie
		}
	}
	close GO ;


	foreach my $file (@files){
		chomp$file;

		my $srp=$file ;
		$self->{currentSRP}=$srp;
		#$gse=~s/(-A-.+)|(-GPL.+)//;
		#$gse=~s/a$|b$|c$|d$//;
		
		$self->{InfosFile} = $dir."/".$self->{currentSRP}."/Assembly_Trinity/".$self->{currentSRP}."_genes_counts.TMM.fpkm.matrix";
		$self->readFileInfo();
	
		my $wanted=20000;
		my $nbTranscrits=scalar(keys(%{$self->{Final}}));
		if($nbTranscrits<20000){
			$wanted=$nbTranscrits;
		}
		my $newfile= $self->{param}->{directory}."/".$self->{currentSRP}."/".$self->{currentSRP}."/".$self->{currentSRP}."_20000genes_counts.TMM.fpkm.matrix";
		open (FILE2,">$newfile");
		my $m=0;
		foreach my $value ( sort {$b<=> $a} keys %{$self->{Final}} ) {
			if($m<$wanted){
				$m+=1
			}
		}
		close FILE2;
	}
}

#*********************************************************************************************
#*********************************************************************************************
#*********************************************************************************************



###
### read file describing the samples, conditions, terms associates to data mining
###
sub readFileInfo{
	my $self = shift;
	#~ -e $self->{InfosFile} or -e $self->{InfosFile} or $logger->logdie("Cannot find file: ".$self->{InfosFile}."\n");
	open (FILE, "<$self->{InfosFile}");

	my  $n=0;
	$self->{CountAllTerms}=0;
	while (<FILE>){
		chomp;
		if ($_ eq "" || $_ =~ m/^	/){											### ne prends pas en compte les lignes vides
			$self->{Header}=$_;
		}
		else{
			my @infos=split("\t",$_);
			my $gene= $infos[0];
			my $nubVal=(scalar(@infos))-1;
			my $moySum=0;

			foreach ( my $i=1 ; $i < scalar(@infos) ; $i+=1){	
				$moySum+=$infos[$i];
			}
			my $moyenne=$moySum/$nubVal;
			my $somme=0;
			foreach ( my $j=1 ; $j < scalar(@infos) ; $j+=1){	
				$somme+=(($infos[$j]-$moyenne)*($infos[$j]-$moyenne));
			}
			my $ecart=sqrt($somme/16);

			$self->{Final}->{$ecart}=$_;
		}
	}
	close FILE;
	return 1;
}





 sub help {
	my $prog = basename($0) ;
	print STDERR <<EOF ;
#### $prog ####
# AUTHOR:        Ambre-Aurore Josselin
# VERSION:       $VERSION  -  $lastModif
# PURPOSE:       

USAGE:
	$prog  [OPTIONS]  

	### OPTIONS ###

	-v, --versbosity  <integer>            mode of verbosity (1-4) [default: 1]
	-h, --help                             print this help
	  

EOF
	exit(1) ;
}

__END__
