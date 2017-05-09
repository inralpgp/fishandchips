#!/usr/bin/perl -w
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

#AUTHOR : Yann Echasseriau

# This script is the launcher to the descriptive stats
# This results in the creation of a subfolder per dataset tested in the directory "result"
# This same subfolder will contain at the end 4 images, 2 images for the raw data and 2 for the normalized data (lowess), representing the stats of the dataset in question 

$datasetList=$ARGV[0];
$downDir=$ARGV[1];
$downDir=~s/\.\.\///;

# Reds datasets to test
open (FILE, $datasetList);
while(<FILE>)
{
	chomp$_;
	@line=split("\t", $_);
	
	# Creation of the file which will contains descriptives stats 
	unless(-d "/home/yann/WORKS/Fish_and_Chips/Dataset_insertion_process/1_bis-stats_descr/results/".$line[2])
	{
		mkdir("/home/yann/WORKS/Fish_and_Chips/Dataset_insertion_process/1_bis-stats_descr/results/".$line[2]);
	}
	
	opendir(DIR, "/home/yann/WORKS/Fish_and_Chips/Dataset_insertion_process/1_bis-stats_descr/results/".$line[2]);
	@file_list=grep{$_=~m/\.jpg/} readdir DIR;
	closedir DIR;
	
	
	if((scalar@file_list)==4)
	{
		# if descriptives stats alredy exists
		next;
	}
	else
	{
		# If no descriptives stats stats descriptive 
		system("rm -r /home/yann/WORKS/Fish_and_Chips/Dataset_insertion_process/1_bis-stats_descr/results/".$line[2]);
		print $line[2]." ...\t";
	
		# Tests to find raw data matrices
		if (-e "/home/yann/WORKS/Fish_and_Chips/".$downDir."/".$line[0]."/".$line[2]."/".$line[2]."_RAW.txt")
		{
			$rawfile="/home/yann/WORKS/Fish_and_Chips/".$downDir."/".$line[0]."/".$line[2]."/".$line[2]."_RAW.txt";
		}
		elsif (-e "/home/yann/WORKS/Fish_and_Chips/".$downDir."/".$line[0]."/".$line[2]."/".$line[2]."_PROC.txt")
		{
			$rawfile="/home/yann/WORKS/Fish_and_Chips/".$downDir."/".$line[0]."/".$line[2]."/".$line[2]."_PROC.txt";
		}
		else
		{
			print "WARNING !! no raw file !\n";
			next;
		}
	
		# Tests to find LOWESS data matrices
		if (-e "/home/yann/WORKS/Fish_and_Chips/".$downDir."/".$line[0]."/".$line[2]."/".$line[2].'_RAW.lowess.txt')
		{
			$normfile="/home/yann/WORKS/Fish_and_Chips/".$downDir."/".$line[0]."/".$line[2]."/".$line[2]."_RAW.lowess.txt";
		}
		elsif (-e "/home/yann/WORKS/Fish_and_Chips/".$downDir."/".$line[0]."/".$line[2]."/".$line[2]."_PROC.lowess.txt")
		{
			$normfile="/home/yann/WORKS/Fish_and_Chips/".$downDir."/".$line[0]."/".$line[2]."/".$line[2]."_PROC.lowess.txt";
		}
		elsif (-e "/home/yann/WORKS/Fish_and_Chips/".$downDir."/".$line[0]."/".$line[2]."/".$line[2]."_RAW.norm.txt")
		{
			$normfile="/home/yann/WORKS/Fish_and_Chips/".$downDir."/".$line[0]."/".$line[2]."/".$line[2]."_RAW.norm.txt";
		}
		elsif (-e "/home/yann/WORKS/Fish_and_Chips/".$downDir."/".$line[0]."/".$line[2]."/".$line[2]."_PROC.norm.txt")
		{
			$normfile="/home/yann/WORKS/Fish_and_Chips/".$downDir."/".$line[0]."/".$line[2]."/".$line[2]."_PROC.norm.txt";
		}
		else
		{
			print "WARNING !! no lowess-norm file !\n\n";
			next;
		}
	
		$folder="/home/yann/WORKS/Fish_and_Chips/Dataset_insertion_process/1_bis-stats_descr/results/".$line[2];
	
		mkdir($folder);
	
		print "launching STAT DESC ...\n";
	
		system("Rscript /home/yann/WORKS/Fish_and_Chips/Dataset_insertion_process/1_bis-stats_descr/launch_stats_desc.R $folder $rawfile $normfile");
	
		print "DONE !!\n\n";

	}
}
close FILE;

exit;

