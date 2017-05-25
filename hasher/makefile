all: hashingSHA256.cpp
	g++ -std=c++11 hashingSHA256.cpp -o hasher -lssl -lcrypto -fopenmp
clean:
	rm -f hasher
run: hasher
	./hasher -e 6 -z 6
