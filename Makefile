
install: tex.mim
	cp -f tex.mim /usr/share/m17n/

imelist: imelist.cpp
	g++ -lm17n -o imelist imelist.cpp

test: imelist
	./imelist | grep t-TeX
