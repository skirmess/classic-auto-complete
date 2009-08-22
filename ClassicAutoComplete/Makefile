
.PHONY: clean tag release

VERSION=1

clean:
	rm -f *~

tag: clean
	cvs tag ClassicAutoComplete-$(VERSION)

release: clean
	( cd ..;							\
		rm -f ClassicAutoComplete-$(VERSION).zip;		\
		find ClassicAutoComplete				\
				-name CVS -prune -o			\
				-name .svn -prune -o			\
				-name Makefile -prune -o		\
				-name '.*.swp' -prune -o		\
				-print					\
		| zip -@ ClassicAutoComplete-$(VERSION).zip;		\
	)	
