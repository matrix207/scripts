#include <stdio.h>

int hello() {
	printf("%s %s %d\n", __FILE__, __func__, __LINE__);
	return 0;
}
