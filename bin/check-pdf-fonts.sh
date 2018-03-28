#!/bin/sh

# The pdffonts tool is part of Xpdf (http://www.foolabs.com/xpdf/). You can
# build Xpdf without installing freetype, and this will build pdffonts (and
# some other command line tools), but not the Xpdf graphical viewer (tested 
# on MacOS X 10.7.2 with xpdf-3.03).

pdffonts $1 > $2

nmf=`cat $2 | tail -n +3 | awk '{if ($4 != "yes") print $0}' | wc -l`

if [ $nmf -gt 0 ]; then \
  tput setaf 1 
  tput bold
  echo ""
  echo "WARNING: the following fonts are not embedded:"
  echo ""
  tput sgr0
  cat $2
  echo ""
  echo "Try running \"updmap --edit\" and setting \"pdftexDownloadBase14 true\""
  echo ""
  echo "================================================================================"
fi