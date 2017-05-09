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

#AUTHOR : Ambre-Aurore Josselin

my $VERSION = '0.3';
my $lastModif = '02April2017';

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
my $purcent;
my $datasetlist;
my $directory;

GetOptions("h|help"           => \&help,
		   "p|purcent=i"        => \$purcent,
		   "s|datasets=s"       => \$datasetlist,
		   "dir|directory=s"    => \$directory); 


&main($datasetlist,$directory);
#*********************************************************************************************
#***********************************          MAIN           ******************************************
#    ~/bin/dev/textMining_V5.pl -p 50 -s datasets.txt  -dir ../WorkingDirectoryInsertionProcess/
#*********************************************************************************************

sub main {
	my $self = {};
	bless $self; 
	
	$self->setOptions();

	use DBI;
	my @files = () ;
	my $dir = $self->{param}->{directory};
	my $dataset_list = $self->{param}->{datasets};

	open(GO, $dataset_list) or die "impossible d'ouvrir $dataset_list ! \n" ;
	while (<GO>){
		chomp;
		$_ =~ /([^\t]*)\t[^\t]*\t[^\t]*.*/ ;
		push(@files, "$1");
		#$1 : SRP
		#$2 : study
		#$3 : specie
	}
	close GO ;


	foreach my $file (@files){
		chomp$file;
		my $srp=$file ;
		$self->{currentSRP}=$srp;

		$self->{InfosFile} = $dir."/".$file."/".$file."/".$file."_tableSamples.csv";
		$self->readFileInfo();

		my $dossier = "$dir/$file/$file/cluster/";
		opendir DIR , $dossier;
		my @list=grep{$_ ne '.' and $_ ne '..' and $_=~ m/^cluster.*\.cdt/} readdir DIR;
		close DIR; 

		my $fichier="";
		foreach $fichier (@list){
			my $number ="";
			$fichier=~ m/^cluster_(\d*)\.cdt/;
			$self->{currentNum} =$1;
			$self->{geneClusterFile}= $dir."/".$file."/".$file."/cluster/".$fichier;
			$self->readclusterBygeneFile();
			$self->analysis();
		}
	}	

}




#*********************************************************************************************
#*********************************************************************************************
#*********************************************************************************************



###
###set the options given as arguments or default
###
sub setOptions{
	my $self = shift;
	$self->{param}->{purcentSurExpressed} = $purcent;
	$self->{param}->{datasets}= $datasetlist;
	$self->{param}->{directory}= $directory;

}




###
### read file describing the samples, conditions, terms associates to data mining
###
sub readFileInfo{
	my $self = shift;
	open (FILE, "<$self->{InfosFile}");
	my  $n=0;
	$self->{CountAllTerms}=0;
	while (<FILE>){
		chomp;
		if ($_ eq "" || $_ =~ m/^#/){
			next;
		}
		elsif ($_=~ m/^Assay/) {
			my @list=split/\t/;
			my $n=0;
			foreach my $elt (@list){
				$elt =~ s/ /_/;
				$self->{header}->{$n}=$elt;
				$n+=1;
			}
		}
		else{
			my @infos=split/\t/;
			foreach ( my $i=0 ; $i < scalar(@infos) ; $i+=1){			
				$infos[$i] =~ s/ /_/g;
				$self->{datas}->{$infos[0]}->{$self->{header}->{$i}}=$infos[$i];
				if ($self->{header}->{$i} ne "Assay" && $self->{header}->{$i} ne "Array"){
					if (not exists $self->{comptageAll}->{$infos[$i]} && $infos[$i] ne "NA") {
						$self->{comptageAll}->{$infos[$i]}=1;
						$self->{CountAllTerms}+=1;
					}
					else {
						$self->{comptageAll}->{$infos[$i]}+=1;
						$self->{CountAllTerms}+=1;
					}
				}
			}
		}
	}
	close FILE;
	return 1;
}



###
### read cluster by gene expression file 
###
sub readclusterBygeneFile{
	my $self=shift;
	$self->{$self->{currentNum}}->{nbligne}=0;
	open (FILE3,"$self->{geneClusterFile}");
	while (<FILE3>){
		chomp;
		
		if ($_ eq "" || $_ =~ m/^#/ || $_=~ m/^AID/ || $_=~ m/^EWEIGHT/ ){										
			next;
		}
		elsif ($_=~ m/^GID/) {
			my @list=split/\t/;
			my $n=0;
			my $x=0;
			foreach my $elt (@list){
				if (($elt eq "GID") or ($elt eq "GWEIGHT") or ($elt eq "NAME")){
					if ($elt eq "NAME" and $x==1){
						$elt =~ s/ /_/;
						$self->{$self->{currentNum}}->{headerfile3}->{$n}=$elt;
						$n+=1;
					}
					elsif($elt eq "NAME" and $x==0){
						$x+=1;
						$n+=1;
						next;
					}	
					else{
						$n+=1;
						next;
					}
				}
				else{
					$elt =~ s/ /_/;
					$self->{$self->{currentNum}}->{headerfile3}->{$n}=$elt;
					$n+=1;
				}
			}
		}
		else {

			$self->{$self->{currentNum}}->{nbligne}+=1;
			my @listeInfos= split/\t/;
			my @listParallel3=Delete_Tab(0,@listeInfos);
			my @listParallel2=Delete_Tab(0,@listParallel3);
			my @listParallel1=Delete_Tab(0,@listParallel2);
			my @listParallel=Delete_Tab(0,@listParallel1);
			my @sortList= sort {$a<=>$b} @listParallel;

			my $len = scalar (@listParallel);
			my $seuil = (3*$len)/4;

			my $arrondi=sprintf("%.0f",$seuil);




			my $gene = $listeInfos[2];
			foreach (my $j=1 ; $j<scalar(@listeInfos);$j+=1){
				foreach my $rank (sort {$a<=>$b} keys %{$self->{$self->{currentNum}}->{headerfile3}}){
					if ($j==$rank){

						$listeInfos[$j] =~ s/ /_/g;

						if ($listeInfos[$j]=~ m/[+-]?\d+\.\d+/){

							if ($listeInfos[$j] eq ""){
								next;
							}
							else{

								if ($listeInfos[$j] >= $sortList[$arrondi]){                                                  
									$self->{$self->{currentNum}}->{overexpressed}->{$self->{$self->{currentNum}}->{headerfile3}->{$j}}->{$gene}=1;

								}
								if ($listeInfos[$j]<0){                                                 
									$self->{$self->{currentNum}}->{underexpressed}->{$self->{$self->{currentNum}}->{headerfile3}->{$j}}->{$gene}=1;
								}
							}
						}
					}
				}
			}
		}
	}
}

sub Delete_Tab
{
    my $Position = shift;
    my @OldTab = @_;
    my @NewTab;
 
    for (my $i = 0; $i < scalar(@OldTab); ++$i)
    {
        push(@NewTab, $OldTab[$i]) if ($i != $Position);
    }
 
    return @NewTab;
}



###
### count term and occurence associate to a sample
###
sub analysis{
	my $self=shift;
	###################  TO COMPLETE 
	my $password="";
	my $user="";
	my $host="";

	my $dbh=DBI->connect("DBI:mysql:database=fishAndchips;host="$host, $user, $password) or die $DBI::errstr;
	my $sth1=$dbh->prepare("INSERT INTO cluster_sample (id,cluster_id,term) VALUES(?,?,?)");
	my $sth2=$dbh->prepare("SELECT id FROM datasets WHERE directory = ?");
	$self->{$self->{currentNum}}->{countAllTermsCluster}=0;
	foreach my $assay (keys %{$self->{$self->{currentNum}}->{overexpressed}}){
		$self->{nbGeneOverexpressedForSample}->{$self->{currentNum}}->{$assay}= scalar(keys %{$self->{$self->{currentNum}}->{overexpressed}->{$assay}});
		if ( ((($self->{nbGeneOverexpressedForSample}->{$self->{currentNum}}->{$assay})/($self->{$self->{currentNum}}->{nbligne}))*100) >= $self->{param}->{purcentSurExpressed}){
			foreach my $term (keys %{$self->{datas}->{$assay}}){
				if( $term ne "Array" && $term ne "Assay"){
					if (exists $self->{$self->{currentNum}}->{Final}->{termAssoCluster}->{$self->{datas}->{$assay}->{$term}}){
						$self->{$self->{currentNum}}->{Final}->{termAssoCluster}->{$self->{datas}->{$assay}->{$term}}+=1;
						$self->{$self->{currentNum}}->{countAllTermsCluster}+=1;
						next;
					}
					else{
						$self->{$self->{currentNum}}->{Final}->{termAssoCluster}->{$self->{datas}->{$assay}->{$term}}=1;
						$self->{$self->{currentNum}}->{countAllTermsCluster}+=1;
					}
					$self->{TotTerm} +=1;
				}
			}
		}
	}

	foreach my $data (sort {$a cmp $b } keys %{$self->{comptageAll}}){

		if (exists $self->{$self->{currentNum}}->{Final}->{termAssoCluster}->{$data}){
			my $proportionAll     = ($self->{comptageAll}->{$data}) / ($self->{CountAllTerms});
			my $proportionCluster = ($self->{$self->{currentNum}}->{Final}->{termAssoCluster}->{$data}) / ($self->{$self->{currentNum}}->{countAllTermsCluster});
			if (($proportionCluster/$proportionAll)>1){
				$sth2->execute($self->{currentSRP});
				my $id = $sth2->fetchrow_array;
				$sth1->execute($id,$self->{currentNum},$data);
				#print $id."\tcluster_".$self->{currentNum}."\t".$data."\n";

			}
		}
		else{
			next;
		}
	}
	$sth1->finish();
	$sth2->finish();
	$dbh->disconnect;
}	
	
	



sub help {
	my $prog = basename($0) ;
	print STDERR <<EOF ;
#### $prog ####
# AUTHOR:        Ambre-Aurore Josselin
# VERSION:       $VERSION  -  $lastModif
# PURPOSE:       

USAGE:
	$prog  [OPTIONS]  <table>

	### OPTIONS ###

	-v, --versbosity  <integer>            mode of verbosity (1-4) [default: 1]
	-h, --help                             print this help
	-p, --purcent                          min purcentage of genes surexpressed in one sample to consoder the terms associate
	-s, --datasets                         datasets list
	-dir,--directory                       directory
	  

EOF
	exit(1) ;
}

__END__



