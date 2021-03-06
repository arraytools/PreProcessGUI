#!/bin/bash
#
# Software automatic setup script for BRB-SeqTools on Mac OS.
#
# Note:
# Xcode command line developer tools and JDK need to be installed manually in order to agree their licenses.
#
SRATOOLKIT_URL=https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/2.8.2-1/sratoolkit.2.8.2-1-mac64.tar.gz
BWA_URL=https://github.com/lh3/bwa/releases/download/v0.7.15/bwa-0.7.15.tar.bz2
BOWTIE2_URL=https://github.com/BenLangmead/bowtie2/releases/download/v2.2.9/bowtie2-2.2.9-macos-x86_64.zip
TOPHAT_URL=http://ccb.jhu.edu/software/tophat/downloads/tophat-2.1.0.OSX_x86_64.tar.gz
STAR_URL=https://github.com/alexdobin/STAR/archive/2.5.2b.tar.gz
SAMTOOLS_URL=https://github.com/samtools/samtools/releases/download/1.4/samtools-1.4.tar.bz2
BCFTOOLS_URL=https://github.com/samtools/bcftools/releases/download/1.4/bcftools-1.4.tar.bz2
PICARD_URL=https://github.com/broadinstitute/picard/releases/download/2.1.1/picard-tools-2.1.1.zip
HTSEQ_URL=https://pypi.python.org/packages/3c/6e/f8dc3500933e036993645c3f854c4351c9028b180c6dcececde944022992/HTSeq-0.6.1p1.tar.gz#md5=c44d7b256281a8a53b6fe5beaeddd31c
FASTQC_URL=http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.5.zip
FASTX_URL=http://hannonlab.cshl.edu/fastx_toolkit/fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2
# SNPEFF_URL=https://downloads.sourceforge.net/project/snpeff/snpEff_latest_core.zip
SNPEFF_URL=http://sourceforge.net/projects/snpeff/files/snpEff_v4_2_core.zip/download
# JDK_URL=http://download.oracle.com/otn-pub/java/jdk/8u121-b13/e9e7ea248e2c4826b92b3f075a80e441/jdk-8u121-macosx-x64.dmg
RCRAN_URL=https://cloud.r-project.org/bin/macosx/R-3.4.0.pkg
PANDOC_URL=https://github.com/jgm/pandoc/releases/download/1.19.2.1/pandoc-1.19.2.1-osx.pkg
AVFS_URL=https://downloads.sourceforge.net/project/avf/avfs/1.0.4/avfs-1.0.4.tar.bz2
SUBREAD_URL=https://sourceforge.net/projects/subread/files/subread-1.5.2/subread-1.5.2-source.tar.gz
XZ_URL=https://tukaani.org/xz/xz-5.2.3.tar.gz
MACTEX_URL=http://tug.org/cgi-bin/mactex-download/BasicTeX.pkg
# MACTEX_URL=http://ctan.org/tex-archive/systems/mac/mactex/BasicTeX.pkg

set -e

if [ -n "$(xcode-select -p 2>&1 | grep error)" ]
then
   echo "Xcode has not been installed";
fi

# create a new directory
echo step 1
if [ ! -d /opt/SeqTools/bin ]; then
  mkdir -p /opt/SeqTools/bin
fi
cd /opt/SeqTools/bin

# bookmark the directory name for SeqTools
echo step 2
if [ -f .DirName ]; then
  rm .DirName
fi
touch .DirName

# sratoolkit
echo step 3
curl -L $SRATOOLKIT_URL -o sratoolkit.tar.gz
dn=`tar -tf sratoolkit.tar.gz | head -1 | cut -f1 -d"/"`
echo "sratoolkit=$dn" >> .DirName
tar xzvf sratoolkit.tar.gz

# BWA (needs to compile)
echo step 4
curl -L $BWA_URL -o BWA.tar.bz2
dn=`tar -tf BWA.tar.bz2 | head -1 | cut -f1 -d"/"`
echo "bwa=$dn" >> .DirName
tar xvf BWA.tar.bz2
cd $dn
make
cd ..

# bowtie
echo step 5
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
echo step 6
curl -L $TOPHAT_URL -o tophat.tar.gz
dn=`tar -tf tophat.tar.gz | head -1 | cut -f1 -d"/"`
echo "tophat=$dn" >> .DirName
tar xzvf tophat.tar.gz

# star
echo step 7
curl -L $STAR_URL -o star.tar.gz
dn=`tar -tf star.tar.gz | head -1 | cut -f1 -d"/"`
echo "star=$dn" >> .DirName
tar xzvf star.tar.gz

# samtools (needs to compile)
# htslib 1.4 requires lzma (xz package)
echo step 8
curl -L $XZ_URL -o xz.tar.gz
dn=`tar -tf xz.tar.gz | head -1 | cut -f1 -d"/"`
tar xzvf xz.tar.gz
cd $dn
./configure
make
make install
cd ..

curl -L $SAMTOOLS_URL -o samtools.tar.bz2
dn=`tar -tf samtools.tar.bz2 | head -1 | cut -f1 -d"/"`
echo "samtools=$dn" >> .DirName
tar xjvf samtools.tar.bz2
cd $dn
./configure
make

# add htslib from samtools
dn=$(basename `find . -maxdepth 1 -name 'htslib*'`)
echo "htslib=$dn" >> ../.DirName
cd $dn
./configure
make
cd ../..

# subread
echo step 9
curl -L $SUBREAD_URL -o subread.tar.gz
dn=`tar -tf subread.tar.gz | head -1 | cut -f1 -d"/"`
echo "subread=$dn" >> .DirName
tar xzvf subread.tar.gz
cd $dn/src
make -f Makefile.MacOS
cd -

# bcftools (needs to compile)
echo step 10
curl -L $BCFTOOLS_URL -o bcftools.tar.bz2
dn=`tar -tf bcftools.tar.bz2 | head -1 | cut -f1 -d"/"`
echo "bcftools=$dn" >> .DirName
tar xjvf bcftools.tar.bz2
cd $dn
make
cd ..

# Picard tool
echo step 11
curl -L $PICARD_URL -o picard.zip
nline=$(unzip -vl picard.zip | head | grep -n 'CRC-32' | awk -F: '{print $1}')
((nline+=2))
dn=`unzip -vl picard.zip | sed -n "${nline}p" | awk '{print $8}'`
echo "picard=$(basename $dn)" >> .DirName
unzip -o picard.zip

# htseq-count (needs to compile)
echo step 12
easy_install pip
sudo -H pip install pysam==0.10.0
curl -L $HTSEQ_URL -o HTSeq.tar.gz
tar xzvf HTSeq.tar.gz
dn=`tar -tf HTSeq.tar.gz | head -1 | cut -f1 -d"/"`
cd $dn
python setup.py build
python setup.py install
cd ..

# fastqc
echo step 13
if [ -f fastqc.zip ]; then
  rm fastqc.zip
fi
curl -L $FASTQC_URL -o fastqc.zip
echo "fastqc=FastQC" >> .DirName
unzip -o fastqc.zip

# snpeff
echo step 14
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
echo step 15
curl -L $FASTX_URL -o fastx.tar.bz2
echo "trimmer=fastx" >> .DirName
if [ ! -d fastx ]; then
  mkdir fastx
fi
tar -xjvf fastx.tar.bz2 -C fastx

# install r-base & rmarkdown
echo step 16
curl -L $RCRAN_URL -o rcran.pkg
installer -pkg rcran.pkg -target /
/usr/local/bin/R -e "install.packages('rmarkdown', repos='https://cran.rstudio.com')"

# install pandoc (pkg)
echo step 17
curl -L $PANDOC_URL -o pandoc.pkg
installer -pkg pandoc.pkg -target /

# instal lftp for accessing cosmic, wget for dbSNFP
echo step 18
curl -O https://raw.githubusercontent.com/rudix-mac/rpm/2016.12.13/rudix.py
python rudix.py install rudix
/usr/local/bin/rudix install lftp
echo step 19
# gdown.pl needs wget
# rudix install wget

# install MacTex
echo step 20
curl -L $MACTEX_URL -o BasicTex.pkg
installer -pkg BasicTex.pkg -target /
/Library/TeX/texbin/tlmgr update --self
/Library/TeX/texbin/tlmgr install titling --repository=http://ftp.dante.de/tex-archive/systems/texlive/tlnet

# clean up
rm *.zip *.tar.gz *.tar.bz2

chown -R root:wheel /opt/SeqTools/bin
chmod +x /opt/SeqTools/bin/FastQC/fastqc

echo Software automatic setup has completed!
# read -p "Press [Enter] key to quit."
