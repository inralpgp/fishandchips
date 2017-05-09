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

open(C, "$liste") or die "Impossible de lire $liste\n" ;

# path to the dataset file
$curr_dir="/Fish_And_Chips_AAJ/Dataset_insertion_process/2-clusterisationEDC";  	########### !!!!!!! A MODIF !!!!!!!

# path to working directory
$seriedir="";     ########### !!!!!!! A MODIF !!!!!!!

# Numéro de la série
$serie=1;



while(<C>)
{
	# Parsing des lignes du fichier contenant la liste des datasets
	chomp;
	if($_=~ m/^#/){
		next;
	}
	else{
		#~ print $_."\n";
		$_ =~ /([^\t]*)\t[^\t]*\t[^\t]*.*/ ;
		my $srp = $1 ;
		my $file = $1;


		#~ print "\n*** SRP: $srp\tFile: $file\n";	
		system("date");	
		$dataset="$seriedir/$file/$file";
		#~ print "$dataset\n";

		$round=1;


			
		if(-e "$dataset/$srp.analyzed.png")
		{
			print "<congratulations> Clusterisation EDC already done !\n\n";
			
		}
	
		
		if(-e "$dataset/$srp\_20000genes\_counts.TMM.fpkm.matrix" ) {
			print "<congratulation> Matrix OK\n";
			
			if(-e "$dataset/$srp\_20000genes\_counts.TMM.fpkm.matrix"){
				$nom_fichier_matrice = $dataset."/$srp\_20000genes\_counts.TMM.fpkm.matrix" ;
			}
			
		
			open(MATRICE, $nom_fichier_matrice) or print "impossible d'ouvrir le fichier $nom_fichier_matrice \n";
			$nom_echantillons = <MATRICE>;
			$nblignes=0;
			while(<MATRICE>){
				$nblignes++;
			}
			close MATRICE;
			$echs = split("\t",$nom_echantillons);
			$nb_echant = scalar($echs)-1;
			
		
			
			$pvalkern = 0.001;
			if ($nb_echant<=30) {$pvalkern = 0.0025;}
			if ($nb_echant<=25) {$pvalkern = 0.005;}
			if ($nb_echant<=20) {$pvalkern = 0.01;}
			
		
			print "Clusterisation EDC \n";

			if($nblignes<=8000) {$c=$nblignes;}
			elsif($nblignes<=10000){$c=3000;}
			elsif($nblignes<=20000){$c=1000;}
			else{$c=500;}
			
			system ("pwd");
			chdir("./2-clusterisationEDC");
			system ("pwd");

	
			system("/usr/lib/jvm/java-1.8.0-openjdk-amd64/bin/java -Xmx3072m Noyau  -f $nom_fichier_matrice -y norm -o $dataset/clusters.txt -m 4 -M 500 -s 1 -t 1 -g 10 -n 20 -p $pvalkern -q $pvalkern -i 0.30 -v false -c $c");
		
		
			#######retrieve clusters found by EDC.R

			unless(-e "$dataset/cluster"){
				system("mkdir $dataset/cluster"); 
			}
			system("mv $dataset/clusters.txt  $dataset/cluster");
	
			chdir("..");
	
	
			$nom_fichier_affectation = "$dataset/cluster/clusters.txt"; 
			open(AFFECT, $nom_fichier_affectation) or print "impossible d'ouvrir le fichier d'affectation clusters.txt\n";
			$affect= <AFFECT> ;	
			$nombre_de_clusters = 0;
			@aff =split /\t/, $affect ;
			chomp(@aff);
			foreach (@aff){
				if ($nombre_de_clusters < $_){ 
					$nombre_de_clusters = $_; 
				}
			}
			close(AFFECT);


	
			if ($nombre_de_clusters > 0){
				open(MATRICE, $nom_fichier_matrice) or die "impossible d'ouvrir le fichier dataset \n";
				$nom_echantillons = <MATRICE>;
				close MATRICE;

				@clusterstxt = <$dataset/cluster/cluster_*.txt>; 
				foreach $cluster (@clusterstxt){
					unlink $cluster;
				}
				###creation cluster_*.txt files, containning datas about genes from each clusters for slcview
				for($i = 1 ; $i <= $nombre_de_clusters ; $i++){
					$nom_fichier = "cluster_$i.txt";	

					open($i , ">$dataset/cluster/".$nom_fichier) or die 'impossible de creer le fichier cluster';
					print $i $nom_echantillons;			
				}
		
				open(AFFECT, $nom_fichier_affectation) or die "impossible d'ouvrir le fichier d'affectation";
				open(MATRICE, $nom_fichier_matrice) or die "impossble d'ouvrir la matrice";	
				$gene = <MATRICE>;				
				foreach $numero_du_cluster (@aff){		
					$gene = <MATRICE>;					
					if($numero_du_cluster ne "0") {
						print  $numero_du_cluster $gene; 
					}				
				}
	
				open(ECH, ">$dataset/ligne_echantillons.txt") or die "impossible de créer le fichier : ligne_echantillons.txt\n";
				print ECH $nom_echantillons;				
		
				close ECH;
	
				unlink "$dataset/clustergroupes1.txt", "$dataset/clustergroupes2.txt", "$dataset/cluster_groupes.txt";
				###################################################################################################
				#########        clusterisation of files on samples et creations of images       ##################
				###################################################################################################
				$echs = split("\t",$nom_echantillons);
				$nombre_echs = scalar($echs);

				$cmd = "cat ";


				for($i = 1 ; $i <= $nombre_de_clusters ; $i++){
					$nom_fichier = "$dataset/cluster/cluster_$i.txt";
					$cmd.= " ".$nom_fichier;
				}
				$cmd.= " > $dataset/clustergroupes1.txt";
			
				system("$cmd");
			
				open(IN, "$dataset/clustergroupes1.txt");
				open(OUT, ">$dataset/clustergroupes2.txt");
				while(<IN>){
					if($_ =~ /^NAME/ ){	
					}
					else {
						print OUT $_
					}
				}
			
				$cmd = "cat $dataset/ligne_echantillons.txt $dataset/clustergroupes2.txt > $dataset/$srp.analyzed.txt";
				system($cmd);
				close IN;
				close OUT;
				
				
				for($i = 1 ; $i <= $nombre_de_clusters ; $i++){
					close $i;
				}
				close MATRICE;
				close AFFECT;
	
				system("./2-clusterisationEDC/cluster3 -f $dataset/$srp.analyzed.txt -l -cg m -g 1 -e 1 -m a");
				
	
				if(-e "$dataset/$srp.analyzed.png"){
					unlink("$dataset/$srp.analyzed.png");
				}
			
				system("../../slcview-2.0/slcview.pl $dataset/$srp.analyzed.cdt -xsize 20 -ysize 0.5 -atrresolution 150 -gtrresolution 100 -arraylabels 170 -genelabels 0 -spacing 5 -linecolor black -o $dataset/$srp.analyzed.png");



				unlink "$dataset/clustergroupes2.txt","$dataset/clustergroupes1.txt","$dataset/ligne_echantillons.txt";
				
				print "\n";
				
				
				unless(-e "$dataset/outliers")
				{
					mkdir "$dataset/outliers"; 
				}
				
				############## TEST OUTLIERS ########
				
				if ( ($nb_echant>4) && ($round<20) )	# Under 4 samples, outliers detection useless
				{
					#~ system("perl", "./2-clusterisationEDC/outliers_correction/checking_outliers.pl", $dataset, $file, $round, $serie);
				}
				
				if(-e "$dataset/outliers/round_$round\.txt")
				{

					if($round==1){
						if(-e "$dataset/$srp.TMM.fpkm.matrix.knn.txt"){
							system("cp $dataset/$srp.TMM.fpkm.matrix.knn.txt $dataset/$srp.TMM.fpkm.matrix.knn.ori.txt");
						}

					}
					
					if(-e "$dataset/$srp.TMM.fpkm.matrix.knn.txt"){
						unlink "$dataset/$srp.TMM.fpkm.matrix.knn.txt";
					}

					
					rename "$dataset/$srp.analyzed.png", "$dataset/outliers/$srp.analyzed.$round.png";
					system("rm -r $dataset/cluster $dataset/$srp.analyzed\*");
					

					if(-e "$dataset/$srp\_20000genes\_counts.TMM.fpkm.matrix"){
						$target=$srp.".TMM.fpkm.matrix";
					}

					system("perl", "./2-clusterisationEDC/outliers_correction/changing_values_2.pl", $dataset,$round, $target);
				}
				else{
					print "\nNo round_$round\.txt   --->    NO MORE OUTLIERS !!!\n\n";
					
					if($round==1){
						if(-e "$dataset/$srp\_20000genes\_counts.TMM.fpkm.matrix"){
							unlink "$dataset/$srp.TMM.fpkm.matrix";											
							rename "$dataset/$srp.TMM.fpkm.ori.matrix", "$dataset/$srp.TMM.fpkm.matrix";		
							
						}

					}
					else{
						rename "$dataset/$srp.analyzed.png", "$dataset/outliers/$srp.analyzed.$round.png";
						system("rm $dataset/$srp.analyzed\*");
					

						if(-e "$dataset/$srp\_20000genes\_counts.TMM.fpkm.matrix"){
							unlink "$dataset/$srp.TMM.fpkm.matrix";											
							rename "$dataset/$srp.TMM.fpkm.ori.matrix", "$dataset/$srp.TMM.fpkm.matrix";

						}
					
					
						if(-e "$dataset/$srp.TMM.fpkm.matrix.knn.txt"){
							unlink "$dataset/$srp.TMM.fpkm.matrix.knn.txt";
							rename "$dataset/$srp.TMM.fpkm.matrix.knn.ori.txt", "$dataset/$srp.TMM.fpkm.matrix.knn.txt";
							$knn_file="$srp.TMM.fpkm.matrix.knn.txt";
						}

					
						system("perl", "./2-clusterisationEDC/outliers_correction/correction.pl", $dataset, $file, $knn_file);
					}
				}
			} 
			else{
				print "<error> No cluster for $file\n\n";
			}
	
		} ## If .knn existeunless(-e "$dataset/cluster")
	
		else
		{
			print "<error> No output file from Trinity 2\n\n";
		}
		
		system("date");

	}

}

close C;

exit;

