
imelist: imelist.cpp
	g++ -lm17n -o imelist imelist.cpp

install: tex.mim
	cp -f tex.mim /usr/share/m17n/

test: imelist
	./imelist | grep tex
