#!/bin/sh

if [ $# != 1 ]; then
  echo "Usage: latex-build.sh <basename>"
  exit 1
fi

TEX_BASE=$1

REGEX_CITE="LaTeX Warning: Citation.*undefined"
REGEX_LABL="LaTeX Warning: Label(s) may have changed. Rerun to get cross-references right."
REGEX_BOOK="Package rerunfilecheck Warning: File .*out. has changed"

COLS=`tput cols`
BLANK_LINE=""

# Set BLANK_LINE to be a line that matches the full width of the terminal
i=0
while [ $i -lt $COLS ]; 
do
  BLANK_LINE="$BLANK_LINE="
  i=`expr $i + 1`
done

blank_line () {
  tput setaf 2 || true
  echo $BLANK_LINE
  tput sgr0 || true
}

done_bib=0
do_bib=0
do_tex=1

while [ $do_tex = 1 ]; do
  blank_line

  pdflatex -halt-on-error $TEX_BASE.tex
  if [ $? = 1 ]; then
    exit 1
  fi
  do_tex=0
  do_bib=0

  # Rerun LaTeX if the labels have changed
  labl_changed=`grep -c "$REGEX_LABL" $TEX_BASE.log`
  if [ $labl_changed != 0 ]; then
    do_tex=1
  fi

  # Rerun LaTeX if PDF bookmarks have changed
  book_changed=`grep -c "$REGEX_BOOK" $TEX_BASE.log`
  if [ $book_changed != 0 ]; then
    do_tex=1
  fi

  # Are there are undefined citations?
  undef_cite=`grep -c "$REGEX_CITE" $TEX_BASE.log`
  if [ $undef_cite != 0 ]; then
    if [ $done_bib = 0 ]; then 
      do_bib=1
    fi
    if [ $done_bib = 1 ]; then
      done_bib=2
      do_tex=1
    fi
  fi

  # Check if any of the *.bib files includes have been modified since
  # BibTeX was last run; if so, request a new run of BibTeX
  for f in `grep '\\\\bibdata{' $TEX_BASE.aux | sed 's/\\\bibdata{//' | sed 's/}//'`
  do
    if [ $f.bib -nt $TEX_BASE.bbl ]; then
      do_bib=1
    fi
  done

  if [ $do_bib = 1 ]; then 
    num_citations=`grep -c \\\\citation $TEX_BASE.aux`
    if [ $num_citations -gt 0 -a $done_bib = 0 ]; then
      # BibTeX has been requested and has not run already, and there are citations...
      blank_line
      bibtex $TEX_BASE
      if [ $? = 1 ]; then
        exit 1
      fi
      do_tex=1;
      do_bib=0;
      done_bib=1;
    fi
  fi
done

# Ghostscript (gs) is used to post-process the output to embed all fonts.
gs -q -dSAFER -dNOPAUSE -dBATCH \
   -dCompatibilityLevel=1.5 -dPDFSETTINGS=/prepress -dEmbedAllFonts=true -dSubsetFonts=true \
   -sDEVICE=pdfwrite -sOutputFile=$TEX_BASE.pdftmp $TEX_BASE.pdf

cat $TEX_BASE.pdftmp > $TEX_BASE.pdf
rm  $TEX_BASE.pdftmp

blank_line

# The pdfinfo tool is part of Xpdf (http://www.foolabs.com/xpdf/).
pdfinfo $TEX_BASE.pdf

blank_line