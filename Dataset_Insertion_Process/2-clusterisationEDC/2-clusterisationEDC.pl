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

#AUTHOR : Yann Echasseriau, Ambre-Aurore Josselin

# This script reads a list of GSE files and launches the cut method. It creates a cluster file
# To view these.
# Parameter of the java program Noyau:
# -f $ dataset.txt 	input file
# -y normal 		format of the input file; Norm = standard madmuscle format
# -o clusters.txt 	output file
# -m 4 				kclus minimal for kmeans
# -M 500 			kclus maximum for kmeans
# -s 1 				step of the sequence seq (m, M, s)
# -t 1 				number of iterations for a value of kclus
# -g 10 			maximum difference between the current kclus and the best result achieved (number of dense clusters)
# -n 20 			number of neighbors forming a cluster core
# -p $ 				pvalkern maximum acceptable pvalue for a kernel
# -q $ 				pvalkern maximum acceptable pvalue between a cluster element and its kernel
# -i 0.50 			minimum silhouette value to accept a new kernel
# -v true 			v to true displays the detail of the debug method
# -c 500

# dataset list
my $liste=$ARGV[0];
print "liste : $liste\n";
open(C, "$liste") or die "Impossible de lire $liste\n" ;

# path to the dataset file
$curr_dir="/Fish_and_Chips/Dataset_insertion_process/2-clusterisationEDC";	########### !!!!!!! to MODIFIED !!!!!!!
# path to the working directory
$seriedir="";	########### !!!!!!! to MODIFIED !!!!!!!
# Numéro de la série
$serie=1;



while(<C>)
{
	# parsing dataset file
	chomp;
	$_ =~ /([^\t]*)\t[^\t]*\t([^\t]*)\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t([^\t]*)\t.*/ ;
	my $gse = $1 ;
	my $file = $2;
	my $channel_count = $3 ;


	print "\n*** GSE: $gse\tFile: $file\tchannel_count: $channel_count\n";	
	system("date");	
	$dataset="$seriedir/$gse/$file";

	# 20 round loop to detect the outliers samples and eliminated them and replace them by value from KNN process 
	$round=0;
	do
	{
		++$round;
		
		print "\n\n\t\t/!\\ ROUND $round /!\\ \n\n";

		# test to find normalized matrix file name 
		if(-e "$dataset/$file\_RAW.txt")
		{
			$filename=$file."_RAW";
		}
		elsif(-e "$dataset/$file\_PROC.txt")
		{
			$filename=$file."_PROC";
		}
		else
		{
			print "<error> fichier absent\n" ;
			print "<end>\n\n";
			break;
		}
		
		# if first round , copy normalized matrix file 
		if($round==1)
		{
			if(-e "$dataset/$filename.lowess.txt")
			{
				system("cp $dataset/$filename.lowess.txt $dataset/$filename.lowess.ori.txt");
			}
			elsif(-e "$dataset/$filename.norm.txt")
			{
				system("cp $dataset/$filename.norm.txt $dataset/$filename.norm.ori.txt");
			}
		}

	
		#Launch script KNN.R on mono channel
		if(-e "$dataset/$file.lowess.knn.txt" || -e "$dataset/$file.norm.knn.txt"){
			print "<congratulations> Knn already done !\n";
		}
		elsif(-e "$dataset/$filename.lowess.txt" || -e "$dataset/$filename.norm.txt")
		{
			print "knn en cours...\n" ;
			my $RDataOutput = "$curr_dir/Result_knn_s$serie.R";
			open (BATCHR, ">$curr_dir/Launch_$serie.R") or print STDERR "Impossible de créer Launch.R\n ";
			print BATCHR "setwd(\"$dataset/\") \n";
			print BATCHR "GDS = \"$filename\" \n";
			print BATCHR "dye = $channel_count \n";
			print BATCHR "source(\"$curr_dir/knn.R\") \n";
			close BATCHR;
			system("R --no-save < $curr_dir/Launch_$serie.R  >> $RDataOutput 2>&1")== 0 or print STDERR "R script failed";
			system("date");		
		}
		else
		{
			print "<error> No lowess or norm file\n\n";
			next;
		}
	
	
		# copy matrix  = raw datas matrix 
		if ( ($channel_count==1) && !(-e "$dataset/$file\.txt") )
		{
			system("cp $dataset/$filename\.txt $dataset/$file\.txt");
		}
		elsif ( ($channel_count==2) && !(-e "$dataset/$file\.txt") && ($filename=~m/PROC/) )
		{
			system("cp $dataset/$filename\.txt $dataset/$file\.txt");
		}

		
		if(-e "$dataset/$file.analyzed.png")
		{
			print "<congratulations> Clusterisation EDC already done !\n\n";
		}
	
	
		if(-e "$dataset/$file.lowess.knn.txt" || -e "$dataset/$file.norm.knn.txt")
		{
			print "<congratulation> KNN OK\n";
			#############################################################
				## Launch cluster cutting
			#############################################################
		
			# TEst to find normalized matrix and do KNN process
			if(-e "$dataset/$file.lowess.knn.txt")
			{
				$nom_fichier_matrice = $dataset."/$file.lowess.knn.txt" ;
			}
			else
			{
				$nom_fichier_matrice = $dataset."/$file.norm.knn.txt";
			}
		
			open(MATRICE, $nom_fichier_matrice) or print "impossible d'ouvrir le fichier $nom_fichier_matrice \n";
			$nom_echantillons = <MATRICE>;
			$nblignes=0;
			while(<MATRICE>)
			{
				$nblignes++;
			}
			close MATRICE;
			$echs = split("\t",$nom_echantillons);###number of samples + 1 (column NAME )
			$nb_echant = scalar($echs)-1;
			print "nombre echantillons = ".$nb_echant." pour le fichier ".$dataset."\n";
		
			
			# pval param necessary for "Noyau" program
			$pvalkern = 0.001;
			if ($nb_echant<=30) {$pvalkern = 0.0025;}
			if ($nb_echant<=25) {$pvalkern = 0.005;}
			if ($nb_echant<=20) {$pvalkern = 0.01;}
			
		
			print "Clusterisation EDC \n";

			# Calculated c parameter
			print "nb lignes : $nblignes\n";
			if($nblignes<=8000) {$c=$nblignes;}
			elsif($nblignes<=10000){$c=3000;}
			elsif($nblignes<=20000){$c=1000;}
			else{$c=500;}
	
			chdir("./2-clusterisationEDC");
	
	
			system("/usr/lib/jvm/java-1.6.0-openjdk/bin/java -Xmx3072m Noyau  -f $nom_fichier_matrice -y norm -o clusters.txt -m 4 -M 500 -s 1 -t 1 -g 10 -n 20 -p $pvalkern -q $pvalkern -i 0.30 -v false -c $c");
		
		
			#######retrieve clusters found by EDC.R

			unless(-e "$dataset/cluster")
			{
				system("mkdir $dataset/cluster"); 
			}
			system("mv clusters.txt  $dataset/cluster");
	
			chdir("..");
	
	
			$nom_fichier_affectation = "$dataset/cluster/clusters.txt"; # File with the number of the genes and the assignment to cluster
			open(AFFECT, $nom_fichier_affectation) or print "impossible d'ouvrir le fichier d'affectation clusters.txt\n";
			$affect= <AFFECT> ;
			# print $affect."\n";	
			$nombre_de_clusters = 0;
			@aff =split /\t/, $affect ;
			chomp(@aff);
			foreach (@aff)
			{
				if ($nombre_de_clusters < $_)  
				{ $nombre_de_clusters = $_;  }
			}
			close(AFFECT);
			print "nombre de clusters = ".$nombre_de_clusters."\n";

	
			if ($nombre_de_clusters > 0)
			{
				open(MATRICE, $nom_fichier_matrice) or die "impossible d'ouvrir le fichier dataset \n";
				$nom_echantillons = <MATRICE>;
				close MATRICE;


				@clusterstxt = <$dataset/cluster/cluster_*.txt>; 
				foreach $cluster (@clusterstxt)
				{
					unlink $cluster;
				}
				###creation cluster_*.txt files , containning the data about cluster for slcview 
				for($i = 1 ; $i <= $nombre_de_clusters ; $i++)
				{
					$nom_fichier = "cluster_$i.txt";	

					open($i , ">$dataset/cluster/".$nom_fichier) or die 'impossible de creer le fichier cluster';
					print $i $nom_echantillons;			
				}
		
				open(AFFECT, $nom_fichier_affectation) or die "impossible d'ouvrir le fichier d'affectation";	
				open(MATRICE, $nom_fichier_matrice) or die "impossble d'ouvrir la matrice";	
				
				$gene = <MATRICE>;				
				foreach $numero_du_cluster (@aff)
				{		
					$gene = <MATRICE>;					
					if($numero_du_cluster ne "0")
					{	
						print  $numero_du_cluster $gene; 
					}				
				}
	
				open(ECH, ">ligne_echantillons.txt") or die "impossible de créer le fichier : ligne_echantillons.txt\n";
				print ECH $nom_echantillons;				
		
				close ECH;
	
				unlink "$dataset/clustergroupes1.txt", "$dataset/clustergroupes2.txt", "$dataset/cluster_groupes.txt";
				###################################################################################################
				#########        clusterisation of files on samples et creations of images       ##################
				###################################################################################################
				$echs = split("\t",$nom_echantillons);
				$nombre_echs = scalar($echs);
				$emptytab = "empty\t";
				$ligne_vide = $emptytab x $nombre_echs;
				chop($ligne_vide);				
				$zone_vide = "$ligne_vide\n" x 10;

				open(BLANC,">zoneVide.txt")||die "impossible d'ouvrir le fichier\n";
				print BLANC $zone_vide;
				close BLANC;
	
				$cmd = "cat ";
				$zonevide = " zoneVide.txt ";

				for($i = 1 ; $i <= $nombre_de_clusters ; $i++)
				{
					$nom_fichier = "$dataset/cluster/cluster_$i.txt";
					$cmd.= $nom_fichier;
					$cmd.= $zonevide;
				}
				$cmd.= " > $dataset/clustergroupes1.txt";
			
				system("$cmd");
			

				open(IN, "$dataset/clustergroupes1.txt");
				open(OUT, ">$dataset/clustergroupes2.txt");
				while(<IN>)
				{
					if($_ =~ /^NAME/ )
					{	
					}
					else {print OUT $_}
				}
			
				$cmd = "cat ligne_echantillons.txt $dataset/clustergroupes2.txt > $dataset/$file.analyzed.txt";
				system($cmd);
				close IN;
				close OUT;
				
				
				for($i = 1 ; $i <= $nombre_de_clusters ; $i++)
				{
					close $i;
				}
				close MATRICE;
				close AFFECT;
	

				system("./2-clusterisationEDC/cluster -f $dataset/$file.analyzed.txt -g 0 -e 1 -m c");	
	
				if(-e "$dataset/$file.analyzed.png")
				{
					unlink("$dataset/$file.analyzed.png");
				}
			
				system("../../slcview-2.0/slcview.pl $dataset/$file.analyzed.cdt -xsize 20 -ysize 0.5 -atrresolution 150 -gtrresolution 100 -arraylabels 170 -genelabels 0 -spacing 5 -linecolor black -o $dataset/$file.analyzed.png");


				unlink "$dataset/clustergroupes2.txt","$dataset/clustergroupes1.txt","ligne_echantillons.txt","zoneVide.txt";

				print "\n";
				
				
				unless(-e "$dataset/outliers")
				{
					mkdir "$dataset/outliers"; 
				}
				
				############## TEST OUTLIERS ########
				
				if ( ($nb_echant>4) && ($round<20) )	
				{
					system("perl", "./2-clusterisationEDC/outliers_correction/checking_outliers.pl", $dataset, $file, $round, $serie);
				}
				
				if(-e "$dataset/outliers/round_$round\.txt")
				{
					if($round==1)
					{
						if(-e "$dataset/$file.lowess.knn.txt")
						{
							system("cp $dataset/$file.lowess.knn.txt $dataset/$file.lowess.knn.ori.txt");
						}
						elsif(-e "$dataset/$file.norm.knn.txt")
						{
							system("cp $dataset/$file.norm.knn.txt $dataset/$file.norm.knn.ori.txt");
						}
					}
					
					if(-e "$dataset/$file.lowess.knn.txt")
					{
						unlink "$dataset/$file.lowess.knn.txt";
					}
					elsif(-e "$dataset/$file.norm.knn.txt")
					{
						unlink "$dataset/$file.norm.knn.txt";
					}
					
					rename "$dataset/$file.analyzed.png", "$dataset/outliers/$file.analyzed.$round.png";
					system("rm -r $dataset/cluster $dataset/$file.analyzed\*");
					
					if(-e "$dataset/$filename.lowess.txt")
					{
						$target=$filename.".lowess.txt";
					}
					elsif(-e "$dataset/$filename.norm.txt")
					{
						$target=$filename.".norm.txt";
					}

					system("perl", "./2-clusterisationEDC/outliers_correction/changing_values_2.pl", $dataset, $round, $target);
				}
				else
				{
					print "\nNo round_$round\.txt   --->    NO MORE OUTLIERS !!!\n\n";
					
					if($round==1)
					{
						if(-e "$dataset/$filename.lowess.txt")
						{
							unlink "$dataset/$filename.lowess.txt";
							rename "$dataset/$filename.lowess.ori.txt", "$dataset/$filename.lowess.txt";
						}
						elsif(-e "$dataset/$filename.norm.txt")
						{
							unlink "$dataset/$filename.norm.txt";
							rename "$dataset/$filename.norm.ori.txt", "$dataset/$filename.norm.txt";
						}
					}
					else
					{
						rename "$dataset/$file.analyzed.png", "$dataset/outliers/$file.analyzed.$round.png";
						system("rm $dataset/$file.analyzed\*");
					
						if(-e "$dataset/$filename.lowess.txt")
						{
							unlink "$dataset/$filename.lowess.txt";
							rename "$dataset/$filename.lowess.ori.txt", "$dataset/$filename.lowess.txt";
						}
						elsif(-e "$dataset/$filename.norm.txt")
						{
							unlink "$dataset/$filename.norm.txt";
							rename "$dataset/$filename.norm.ori.txt", "$dataset/$filename.norm.txt";
						}
					
					
						if(-e "$dataset/$file.lowess.knn.txt")
						{
							unlink "$dataset/$file.lowess.knn.txt";
							rename "$dataset/$file.lowess.knn.ori.txt", "$dataset/$file.lowess.knn.txt";
							$knn_file="$file.lowess.knn.txt";
						}
						elsif(-e "$dataset/$file.norm.knn.txt")
						{
							unlink "$dataset/$file.norm.knn.txt";
							rename "$dataset/$file.norm.knn.ori.txt", "$dataset/$file.norm.knn.txt";
							$knn_file="$file.norm.knn.txt";
						}
					
						system("perl", "./2-clusterisationEDC/outliers_correction/correction.pl", $dataset, $file, $knn_file);
					}
				}
			} 
			else
			{
				print "<error> No cluster for $file\n\n";
			}
	
		} 
	
		else
		{
			print "<error> No output file from knn\n\n";
		}
		
		system("date");

	
	}while(-e "$dataset/outliers/round_$round\.txt");


}

close C;

exit;

