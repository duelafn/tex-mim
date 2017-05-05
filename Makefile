
install: TeX.png tex.mim
	cp -f tex.mim /usr/share/m17n/
	cp -f TeX.png /usr/share/m17n/icons/

imelist: imelist.cpp
	g++ -lm17n -o imelist imelist.cpp

test: imelist
	./imelist | grep t-TeX
