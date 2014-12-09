# Use trap command to know if the script is run successfully or not.
# If there is any error, we should see error=1 in /tmp/error.log
# If there is no error, we should get error=0 in /tmp/error.log.

trap 'echo error=1 > /tmp/error.log' ERR
BOWTIE2_URL=http://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.2.1/bowtie2-2.2.1-linux-x86_64.zip/download
SAMTOOLS_URL=http://sourceforge.net/projects/samtools/files/samtools/0.1.19/samtools-0.1.19.tar.bz2/download

set -e

# bowtie
if [ -f bowtie2.zip ]; then
  rm bowtie2.zip
fi
wget $BOWTIE2_URL -O bowtie2.zip

# samtools (needs to compile)
wget $SAMTOOLS_URL -O samtools.tar.bz2

echo error=0 > /tmp/error.log
read -p "Press [Enter] key to quit."
