VERSION=0.1

pandoc_bin=/usr/bin/pandoc
pdfbook_bin=/usr/bin/pdfbook

fontsize=12pt
lang=french
geometry=portrait
paper=a4paper
hmargin=3cm
vmargin=3.5cm

# Common options for pandoc's calls
templates_dir=./templates
outputdir=./output

pandoc_config= \
	$(pandoc_metadata) \
	-V geometry:hmargin=3cm \
	-V geometry:vmargin=3.5cm \
	--listings \
	--no-highlight

tex_config= \
	$(pandoc_config) \
	--template=$(templates_dir)/default.latex \
	--variable fontsize=${fontsize} \
	--variable lang=${lang} \
	--variable geometry=${geometry} \
	--variable paper=${paper} \
	--variable hmargin=${hmargin} \
	--variable vmargin=${vmargin}



%.check:
	( test -d books/$(patsubst %.check,%,$(@)) && \
		echo "Book $(patsubst %.check,%,$(@)) FOUND" ) || \
	( echo "Book $(patsubst %.check,%,$(@)) NOT FOUND" && \
		exit 1 )
	$(eval pandoc_metadata=$(shell /usr/bin/awk -f utilities/metadata.awk books/$(patsubst %.check,%,$(@))/00-metadata.txt) )

%-report.pdf:
	echo "PDF  generation, readable  report... "
	$(pandoc_bin) \
		$(tex_config) \
		--variable documentclass=report \
		-o $(outputdir)/$(@) \
		books/$(patsubst %-report.pdf,%,$(@))/*.mkd

%-a4book.pdf:
	echo "PDF  generation, printable a4 book... "
	$(pandoc_bin) \
		$(tex_config) \
		--toc --toc-depth=2 \
		--variable documentclass=book \
		--variable print=true \
		-o $(outputdir)/$(@) \
		books/$(patsubst %-a4book.pdf,%,$(@))/*.mkd

%-a5book.pdf:
	echo "PDF  generation, printable a5 book... "
	$(pdfbook_bin) --quiet \
		--keepinfo \
		--landscape \
		--twoside \
		--a4paper \
		--nup 2x2 \
		--outfile output/$(@) \
		-- $(outputdir)/$(patsubst %-a5book.pdf,%-a4book.pdf,$(@))

%.tex:
	echo "TEX  generation... "
	$(pandoc_bin) \
		$(tex_config) \
		-o $(outputdir)/$(@) \
		books/$(patsubst %.tex,%,$(@))/*.mkd

%-2.epub:
	echo "EPUB generation... "
	$(pandoc_bin) \
		$(pandoc_config) \
		-t epub \
		--toc --toc-depth=1 \
		--template=$(templates_dir)/default.epub \
		--epub-stylesheet=$(templates_dir)/epub.stylesheet.css \
		--epub-metadata=$(templates_dir)/epub.metadata.fr.xml \
		-o $(outputdir)/$(@) \
		books/$(patsubst %-2.epub,%,$(@))/*.mkd

%-3.epub:
	echo "EPUB3 generation... "
	$(pandoc_bin) \
		$(pandoc_config) \
		-t epub3 \
		--toc --toc-depth=1 \
		--template=$(templates_dir)/default.epub3 \
		--epub-stylesheet=$(templates_dir)/epub.stylesheet.css \
		--epub-metadata=$(templates_dir)/epub.metadata.fr.xml \
		-o $(outputdir)/$(@) \
		books/$(patsubst %-3.epub,%,$(@))/*.mkd

%.html:
	echo "HTML generation... "
	$(pandoc_bin) \
		$(pandoc_config) \
		-t html5 \
		--template=$(templates_dir)/default.html5 \
		--toc --toc-depth=1 \
		-o $(outputdir)/$(@) \
		books/$(patsubst %.html,%,$(@))/*.mkd

%.pdf: | %-report.pdf %-a4book.pdf %-a5book.pdf
	@true

%.all: | %.tex %.pdf %-2.epub %-3.epub %.html
	@true

%: | %.check %.all
	@true
