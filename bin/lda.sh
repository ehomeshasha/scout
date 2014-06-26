#echo -e "\nclassify-dealsaccess.sh: Creating sequence files from CSV\n"
#mahout seqCSV -i ./input/amazondeals.csv -o ./dealsaccess/seq -ow

echo -e "\nclassify-dealsaccess.sh: Creating sequence files from CSV\n"
hadoop jar target/lda-0.0.1-SNAPSHOT.jar ca.dealsaccess.text.SequenceFilesFro -i ./input/amazondeals.csv -o ./dealsaccess/seq -ow


