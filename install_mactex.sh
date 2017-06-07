MACTEX_URL=http://tug.org/cgi-bin/mactex-download/BasicTeX.pkg
curl -L $MACTEX_URL -o BasicTex.pkg
sudo installer -pkg BasicTex.pkg -target /
# Password:
# installer: Package name is BasicTeX-2017
# installer: Installing at base path /
# installer: The install was successful.
echo run update
sudo /Library/TeX/texbin/tlmgr update --self
# tlmgr: package repository http://mirrors.rit.edu/CTAN/systems/texlive/tlnet (not verified: gnupg not available)
# tlmgr: saving backups to /usr/local/texlive/2017basic/tlpkg/backups
# tlmgr: no self-updates for tlmgr available.
echo install titling
sudo /Library/TeX/texbin/tlmgr install titling --repository=http://ftp.dante.de/tex-archive/systems/texlive/tlnet
# tlmgr: package repository http://ftp.dante.de/tex-archive/systems/texlive/tlnet # (not verified: gnupg not available)
# [1/1, ??:??/??:??] install: titling [3k]
# running mktexlsr ...
# done running mktexlsr.
# tlmgr: package log updated: /usr/local/texlive/2017basic/texmf-var/web2c/tlmgr.log
echo done

