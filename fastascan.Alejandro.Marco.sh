#Hi, welcome to the FASTASCAN script made by Alejandro Marco. This script allows us to find .fa and .fasta files in our current directory or in a relative path if we set a valid directory
# as an argument. In addition, the script can perform more functions when analyzes the scanned fasta files, and presents the output as a table using the function column. Hope it will be useful!

#First of all, we set extra variables like colors or variables that will be used for the loop
RED="\e[31m"
GREEN="\e[32m"
PURPLE="\e[35m"
NC="\e[0m"
TotalSeq=0
TotalSeqLen=0

#In this if loop we check if the user specified a valid path as an argument to scan the fasta files in that relative path
if [[ -n $1 && -d $1 ]] 
then
   FASTAFILES=$(find $1 \( -not -path '/*._*' \) \( -type l -o -type f \) \( -name "*.fa" -a -not -name '._*' -o -name "*.fasta" -a -not -name '._*' \))
   
elif  [[ $1 = "-h" ]] # I added a help function as an argument for those who doesn't know how this script works and want more information about it.
then
echo
echo "       ☻ / 
       /▌        Hi. This is the FASTASCAN help option. 
       /\﻿                                                                     "
echo
echo "Info: FASTASCAN is a script that helps you to find fasta files (.fa and .fasta) in your
current directory and subfolders (not in hidden directories and not binary or hidden files)."
echo
echo "In addition, FASTASCAN has the function of granting certain information about each of the scanned fasta files:

- Distinguish which fasta files (if any) are symlinks
- Tells us the number of sequences that are in each file
- Also, the total sequence length in each file (the total number of nucleotides/aminoacids that are contained)
- Distinguish the fasta files containing nucleotide sequences from those containing protein sequences
- And print once a single sequence tittle as an example, he global total number of sequences and the total sequence length

Also, you can select a path as argument (a valid path) to scan from that relative path and not from the current path."
echo
echo "Hope this helped you! "
echo
exit

elif  [[ -n $1 && ! -d $1 ]] #This elif is for the case of the user type's a non valid or existing directoy.
then
echo
echo -e  ${RED}ERROR!${NC} ${PURPLE}$1${NC} is not a valid directory!
echo
echo FASTASCAN cannot procede. Ending program...
echo
exit
else #And if there's no path argument (or help argument), then use the current directory to scan for fasta files
   FASTAFILES=$(find . \( -not -path '/*._*' \) \( -type l -o -type f \) \( -name "*.fa" -a -not -name '._*' -o -name "*.fasta" -a -not -name '._*' \))
fi

echo
echo "                                                             🅆 🄴 🄻 🄲 🄾 🄼 🄴   🅃 🄾                             "
echo "                                                                                                               "
echo "                                            
                                 ███████╗░█████╗░░██████╗████████╗░█████╗░░██████╗░█████╗░░█████╗░███╗░░██╗
                                 ██╔════╝██╔══██╗██╔════╝╚══██╔══╝██╔══██╗██╔════╝██╔══██╗██╔══██╗████╗░██║
                                 █████╗░░███████║╚█████╗░░░░██║░░░███████║╚█████╗░██║░░╚═╝███████║██╔██╗██║
                                 ██╔══╝░░██╔══██║░╚═══██╗░░░██║░░░██╔══██║░╚═══██╗██║░░██╗██╔══██║██║╚████║
                                 ██║░░░░░██║░░██║██████╔╝░░░██║░░░██║░░██║██████╔╝╚█████╔╝██║░░██║██║░╚███║
                                 ╚═╝░░░░░╚═╝░░╚═╝╚═════╝░░░░╚═╝░░░╚═╝░░╚═╝╚═════╝░░╚════╝░╚═╝░░╚═╝╚═╝░░╚══╝          "
echo
echo
echo "-------------------------------------------- SCANNING FOR FASTA FILES... --------------------------------------------"
echo
                                 
echo -e  ${PURPLE}"Fasta_File_Path Num_Seq Total_Seq_Len Symlink? N/P?"${NC} >> FASTASCANtemporal.txt #print a header for our output and redirect to a temporally file                                 

if [[ -z $FASTAFILES ]] #If FASTASCAN didn't catch any fasta file print the "No Fasta" message
then
 echo
 echo "FASTASCAN doesn't detect any fasta file in this directory. Please, try other directories."
 echo
 echo
else # but if FASTASCAN catch at least one fasta file, then start the big loop with all their functions
echo
for i in $FASTAFILES 
do
echo -n $i >> FASTASCANtemporal.txt #redirect the path to every fasta scaned to our temporally file
#countea las secuencias
SeqNum=$(grep -h ">" $i | wc -l)
echo -n " "$SeqNum >> FASTASCANtemporal.txt #Grep and counts all sequence tittles of every fasta scaned and then redirects it to our temporally file
TotalSeq=$(($TotalSeq + $SeqNum))           #Here we're summing the number of sequences to calculate the global total number of sequences
#sum=$(($num1 + $num2))
#Countea los caracteres
SeqLen=$(grep -h -v ">" $i | sed 's/-//g'| sed 's/ //g'| awk '{n=n+length}END{print n}')
echo -n " "$SeqLen >> FASTASCANtemporal.txt #Grep all except the tittles, subsitute the spaces and gaps and count all the characters, redirecting the output to our temporally file
TotalSeqLen=$(($TotalSeqLen + $SeqLen))     #Here we're summing the lenghts to calculate the global total length
#
if [[ -L $i ]] 
then
  echo -n " "Yes >> FASTASCANtemporal.txt #If the fa/fasta scaned is a link, redirect yes to the temporally file
else
  echo -n " "No >> FASTASCANtemporal.txt #But if it's not a link, redirect no to the temporally file
fi

# 
CHARACTERS=$(awk ' />/ {getline; print $0; exit}' $i | sed 's/-//g'| sed 's/ //g')
#Another way to solve is ---> grep ">" -m 1 -A 1 ./dataset1/proteins/fesor.dbteu.aligned.fa | tail -n 1  (but this line 
# contains a new line character! Important to consider that for the if statments and for the sed subsitutons).
if [[ $CHARACTERS =~ [actgACTG] ]] && ! [[ $CHARACTERS =~ [^actgACTG] ]] 
then
echo  " "Nucleotide >> FASTASCANtemporal.txt #In case of be a nucleotide sequence, redirect this output to the temporally file
elif [[ $CHARACTERS =~ [actgrndeqhilkmfpswyvxACTGRNDEQHILKMFPSWYVX] ]] && ! [[ $CHARACTERS =~ [^actgrndeqhilkmfpswyvxACTGRNDEQHILKMFPSWYVX] ]]
then
echo " "Protein >> FASTASCANtemporal.txt #In case of be a aminoacid sequence, redirect this output to the temporally file
else
echo " "UNDEF >> FASTASCANtemporal.txt #If there's no ">" tittle sequence detected or the characters aren't Nucleotides or Aminoacids, redirect UNDEF output to the temporally file
fi

done

# We consider as a possible nucleotide characters -> actgACTG
# We consider as a possible aminoacid characters --> actgrndeqhilkmfpswyvxACTGRNDEQHILKMFPSWYVX

column FASTASCANtemporal.txt  -t -L -s " " #And with column we print our output located in the temporally file as a table (more visual for the user)

echo
#Here prints the global total sequence length (sum of every character of all the sequences scaned), resalted in green 
echo -e "The global total sequence length is about" ${GREEN}$TotalSeqLen${NC} "characters"
echo
#Here prints the global total number of sequences, resalted in green
echo -e "The global total number of sequences are" ${GREEN}$TotalSeq${NC}
echo
#And here prints a single title as an example, resalted in green (but not more than one title per script execution)
echo -e "Example tittle:" ${GREEN}$(grep -h -m 1 ">" $FASTAFILES | head -n1)${NC}
echo
echo 

fi

rm FASTASCANtemporal.txt #And finally, remove the temporally file

echo "--------------------------------------------- SCAN COMPLETED ---------------------------------------------"
echo



#The not used functions are in the following lines:

#find . -regex '.*fa[s]?[t]?[a]?'
#column [-entx] [-c columns] [-s sep] [file ...]

