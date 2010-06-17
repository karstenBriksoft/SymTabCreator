// example created by karsten@briksoftware.com
// compile with: cc example.c -o example; strip example
//
#include <stdio.h>

int multiply(int a, int b)
{
	return a * b;
}

int add(int a, int b)
{
	return a * b;
}

int main()
{
	int a = 5;
	int b = 3;
	int c = multiply(a,b);
	int d = add(a,c);
	printf("d = %i\n",d);
}