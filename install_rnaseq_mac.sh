#!/bin/bash
#
# Software automatic setup script for BRB-SeqTools on Mac OS.
#
# Note:
# Xcode command line developer tools, JDK and R need to be installed manually in order to agree their licenses.
#
SRATOOLKIT_URL=https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/2.7.0/sratoolkit.2.7.0-ubuntu64.tar.gz
BWA_URL=https://github.com/lh3/bwa/archive/0.7.12.tar.gz
# BOWTIE2_URL=http://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.2.6/bowtie2-2.2.6-linux-x86_64.zip/download
BOWTIE2_URL=https://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.2.9/bowtie2-2.2.9-macos-x86_64.zip/download
TOPHAT_URL=http://ccb.jhu.edu/software/tophat/downloads/tophat-2.1.0.OSX_x86_64.tar.gz
STAR_URL=https://github.com/alexdobin/STAR/archive/2.5.1b.tar.gz
SAMTOOLS_URL=https://github.com/samtools/samtools/releases/download/1.3/samtools-1.3.tar.bz2
BCFTOOLS_URL=https://github.com/samtools/bcftools/releases/download/1.3/bcftools-1.3.tar.bz2
PICARD_URL=https://github.com/broadinstitute/picard/releases/download/1.141/picard-tools-1.141.zip
HTSEQ_URL=https://pypi.python.org/packages/3c/6e/f8dc3500933e036993645c3f854c4351c9028b180c6dcececde944022992/HTSeq-0.6.1p1.tar.gz#md5=c44d7b256281a8a53b6fe5beaeddd31c
FASTQC_URL=http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.5.zip
FASTX_URL=http://hannonlab.cshl.edu/fastx_toolkit/fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2
SNPEFF_URL=http://sourceforge.net/projects/snpeff/files/snpEff_v4_2_core.zip/download
# SNPEFF_URL=https://github.com/pcingola/SnpEff/archive/v4.2.zip
JDK_URL=http://download.oracle.com/otn-pub/java/jdk/8u121-b13/e9e7ea248e2c4826b92b3f075a80e441/jdk-8u121-macosx-x64.dmg
RCRAN_URL=https://cloud.r-project.org/bin/macosx/R-3.3.3.pkg
PANDOC_URL=https://github.com/jgm/pandoc/releases/download/1.19.2.1/pandoc-1.19.2.1-osx.pkg
AVFS_URL=https://downloads.sourceforge.net/project/avf/avfs/1.0.4/avfs-1.0.4.tar.bz2
SUBREAD_URL=https://sourceforge.net/projects/subread/files/subread-1.5.2/subread-1.5.2-source.tar.gz

set -e

# download packages for htseq-count
echo step 6
# easy_install pip
echo step 7
# sudo -H pip install numpy matplotlib
echo step 8
# sudo -H pip install pysam

# create a new directory
echo step 11
if [ ! -d /opt/SeqTools/bin ]; then
  mkdir -p /opt/SeqTools/bin
fi
cd /opt/SeqTools/bin

# jdk
curl $JDK_URL -o jdk.dmg
MOUNTDIR=$(echo `hdiutil mount jdk.dmg | tail -1 \
| awk '{$1=$2=""; print $0}'` | xargs -0 echo) \
&& installer -pkg "${MOUNTDIR}/"*.pkg -target / \
&& hdiutil detach "${MOUNTDIR}"

# bookmark the directory name for SeqTools
echo step 12
if [ -f .DirName ]; then
  rm .DirName
fi
touch .DirName

# sratoolkit
echo step 13
curl $SRATOOLKIT_URL -o sratoolkit.tar.gz
dn=`tar -tf sratoolkit.tar.gz | head -1 | cut -f1 -d"/"`
echo "sratoolkit=$dn" >> .DirName
tar xzvf sratoolkit.tar.gz

# BWA (needs to compile)
echo step 14
curl -L $BWA_URL -o BWA.tar.gz
dn=`tar -tf BWA.tar.gz | head -1 | cut -f1 -d"/"`
echo "bwa=$dn" >> .DirName
tar xzvf BWA.tar.gz
cd $dn
make
cd ..

# bowtie
echo step 15
if [ -f bowtie2.zip ]; then
  rm bowtie2.zip
fi
curl -L $BOWTIE2_URL -o bowtie2.zip
nline=$(unzip -vl bowtie2.zip | head | grep -n 'CRC-32' | awk -F: '{print $1}')
((nline+=2))
dn=`unzip -vl bowtie2.zip | sed -n "${nline}p" | awk '{print $8}'`
echo "bowtie=$(basename $dn)" >> .DirName
unzip -o bowtie2.zip

# tophat
echo step 16
curl -L $TOPHAT_URL -o tophat.tar.gz
dn=`tar -tf tophat.tar.gz | head -1 | cut -f1 -d"/"`
echo "tophat=$dn" >> .DirName
tar xzvf tophat.tar.gz

# star
echo step 17
curl -L $STAR_URL -o star.tar.gz
dn=`tar -tf star.tar.gz | head -1 | cut -f1 -d"/"`
echo "star=$dn" >> .DirName
tar xzvf star.tar.gz

# samtools (needs to compile)
echo step 18
curl -L $SAMTOOLS_URL -o samtools.tar.bz2
dn=`tar -tf samtools.tar.bz2 | head -1 | cut -f1 -d"/"`
echo "samtools=$dn" >> .DirName
tar xjvf samtools.tar.bz2
cd $dn
./configure
make

dn=$(basename `find . -maxdepth 1 -name 'htslib*'`)
echo "htslib=$dn" >> ../.DirName
# add htslib from samtools
cd $dn
./configure
make
cd ../..

# subread
echo step 19
curl -L $SUBREAD_URL -o subread.tar.gz
dn=`tar -tf subread.tar.gz | head -1 | cut -f1 -d"/"`
echo "subread=$dn" >> .DirName
tar xzvf subread.tar.gz
cd $dn/src
make -f Makefile.MacOS
cd -

# bcftools (needs to compile)
echo step 20
curl -L $BCFTOOLS_URL -o bcftools.tar.bz2
dn=`tar -tf bcftools.tar.bz2 | head -1 | cut -f1 -d"/"`
echo "bcftools=$dn" >> .DirName
tar xjvf bcftools.tar.bz2
cd $dn
make
cd ..

# Picard tool
echo step 21
curl -L $PICARD_URL -o picard.zip
nline=$(unzip -vl picard.zip | head | grep -n 'CRC-32' | awk -F: '{print $1}')
((nline+=2))
dn=`unzip -vl picard.zip | sed -n "${nline}p" | awk '{print $8}'`
echo "picard=$(basename $dn)" >> .DirName
unzip -o picard.zip

# htseq-count (needs to compile)
echo step 22
curl -L $HTSEQ_URL -o HTSeq.tar.gz
tar xzvf HTSeq.tar.gz
dn=`tar -tf HTSeq.tar.gz | head -1 | cut -f1 -d"/"`
cd $dn
python setup.py build
python setup.py install
cd ..

# fastqc
echo step 23
if [ -f fastqc.zip ]; then
  rm fastqc.zip
fi
curl -L $FASTQC_URL -o fastqc.zip
echo "fastqc=FastQC" >> .DirName
unzip -o fastqc.zip

# snpeff
echo step 24
if [ -f snpEff*.zip ]; then
  rm snpEff*.zip
fi
curl -L $SNPEFF_URL -o snpEff.zip
nline=$(unzip -vl snpEff.zip | head | grep -n 'CRC-32' | awk -F: '{print $1}')
((nline+=2))
dn=`unzip -vl snpEff.zip | sed -n "${nline}p" | awk '{print $8}'`
echo "snpeff=$(basename $dn)" >> .DirName
unzip -o snpEff.zip
snpEff=`basename $dn`
if [ ! -d $snpEff/data ]; then mkdir $snpEff/data; fi
chmod a+w $snpEff/data

# fastx
echo step 25
curl -L $FASTX_URL -o fastx.tar.bz2
echo "trimmer=fastx" >> .DirName
if [ ! -d fastx ]; then
  mkdir fastx
fi
tar -xjvf fastx.tar.bz2 -C fastx

echo step 26
# apt-get install -y texlive-latex-base
# MacTex
# BasicLatex is 110MB while the full TexLive is 3GB
# See http://www.tug.org/mactex/morepackages.html
# http://ftp.math.purdue.edu/mirrors/ctan.org/systems/mac/mactex/mactex-basictex-20161009.pkg
# It takes a few minutes to get a reasonable connection (500KB/s)
# After installation, latex is located at 
#   /usr/local/texlive/2016basic/bin/x86_64-darwin/
echo step 27
# apt-get install -y texlive-fonts-recommended # ecrm1000 error
echo step 28
# apt-get install -y texlive-latex-extra # .sty files
echo step 29
# apt-get install -y lmodern # lmodern.sty

# install r-base & rmarkdown
echo step 30
curl -L $RCRAN_URL -o rcran.pkg
installer -pkg rcran.pkg -target /
R -e "install.packages('rmarkdown', repos='https://cran.rstudio.com')"

# install pandoc (pkg)
echo step 31
curl -L $PANDOC_URL -o pandoc.pkg
installer -pkg pandoc.pkg -target /

# instal lftp for accessing cosmic, wget for dbSNFP
echo step 32
curl -O https://raw.githubusercontent.com/rudix-mac/rpm/2016.12.13/rudix.py
python rudix.py install rudix
rudix install lftp
rudix install wget

# install avfs for mounting compressed files
# also consider archivemount https://www.macports.org/ports.php?by=category&substr=fuse
echo step 33
curl -L $AVFS_URL -o avfs.tar.bz2
tar -xjvf avfs.tar.bz2

# clean up
rm *.zip *.tar.gz *.tar.bz2

chown -R root:wheel /opt/SeqTools/bin
chmod +x /opt/SeqTools/bin/FastQC/fastqc

read -p "Press [Enter] key to quit."
