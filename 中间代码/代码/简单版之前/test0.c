int main()
{
	float x;
	float y;
	float z;
	int m;

	x = 1.5;
	y = 1.6;

	z = x + y;
	z = x - y;
	z = x * y;
	z = x / y;
	z = x + y / x;

	m = x && y;
	m = x || y;

	m = x || y + x && y;
}


