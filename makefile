OUTPUTDIR=./output
BOOKSLIST=$(wildcard ./books/*)

# Default values for LaTeX & PDF output

#fontsize
#lang / mainlang
#papersize
#documentclass

#euro
#mainfont
#sansfont
#monofont
#mathfont

#geometry

#natbib

#biblatex
#biblio-files

#listings

#lhs

#highlighting-macros

#verbatim-in-note

#tables

#graphics

#author-meta
#title-meta
#urlcolor
#linkcolor
#links-as-notes

#strikeout

#numbersections

#header-includes

#title
#author
#date

#include-before

#toc
#toc-depth

#body

#natbib
#biblio-files
#biblio-title
#book-class

#include-after



fontsize=12pt
lang=french
geometry=portrait
paper=a4paper
hmargin=3cm
vmargin=3.5cm

# Common options for pandoc's calls
GLOBAL_CONFIG= \
	--listings \
	--no-highlight

TEX_CONFIG= \
	--template=templates/default.latex \
	--variable fontsize=${fontsize} \
	--variable lang=${lang} \
	--variable geometry=${geometry} \
	--variable paper=${paper} \
	--variable hmargin=${hmargin} \
	--variable vmargin=${vmargin}

PANDOC_BIN=/usr/bin/pandoc
PDFBOOK_BIN=/usr/bin/pdfbook

%.check:
	( test -d books/$(patsubst %.check,%,$(@)) && \
		echo "Book $(patsubst %.check,%,$(@)) FOUND" ) || \
		( echo "Book $(patsubst %.check,%,$(@)) NOT FOUND" && \
		exit 1 )

%-report.pdf:
	echo "PDF  generation, readable  report... "
	$(PANDOC_BIN) $(GLOBAL_CONFIG) \
			$(TEX_CONFIG) \
			--variable documentclass=report \
			-o $(OUTPUTDIR)/$(@) \
			books/$(patsubst %-report.pdf,%,$(@))/*.mkd

%-a4book.pdf:
	echo "PDF  generation, printable a4 book... "
	$(PANDOC_BIN) $(GLOBAL_CONFIG) \
			--toc \
			--variable toc-depth=2 \
			$(TEX_CONFIG) \
			--variable documentclass=book \
			--variable print=true \
			-o $(OUTPUTDIR)/$(@) \
			books/$(patsubst %-a4book.pdf,%,$(@))/*.mkd

%-a5book.pdf:
	echo "PDF  generation, printable a5 book... "
	$(PDFBOOK_BIN) --quiet \
			--keepinfo \
			--landscape \
			--twoside \
			--a4paper \
			--nup 2x2 \
			--outfile output/$(@) \
			-- $(OUTPUTDIR)/$(patsubst %-a5book.pdf,%,$(@))-a4book.pdf

%.tex:
	echo "TEX  generation... "
	$(PANDOC_BIN) $(GLOBAL_CONFIG) \
			$(TEX_CONFIG) \
			-o $(OUTPUTDIR)/$(@) \
			books/$(patsubst %.tex,%,$(@))/*.mkd

%.epub:
	echo "EPUB generation... "
	$(PANDOC_BIN) --toc \
			--epub-stylesheet=tpl_epub/book.css \
			--epub-metadata=tpl_epub/metadata.fr.xml  \
			$(GLOBAL_CONFIG) \
			-o $(OUTPUTDIR)/$(@) \
			books/$(patsubst %.epub,%,$(@))/*.mkd

%.html5:
	echo "HTML5 generation... "
	$(PANDOC_BIN) \
			--toc --toc-depth=1 \
			--template=templates/default.html5 \
			$(GLOBAL_CONFIG) \
			-t html5 \
			-o $(OUTPUTDIR)/$(@) \
			books/$(patsubst %.html5,%,$(@))/*.mkd

%.pdf: | %-report.pdf %-a4book.pdf %-a5book.pdf
	@true

%.all: | %.tex %.pdf %.epub %.html5
	@true

%: | %.check %.all
	@true
