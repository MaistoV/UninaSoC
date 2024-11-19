#include "tinyIO.h"
#include <stdint.h>

int main()
{ 

  tinyIO_init();

  char c;

  while(1){
    scanf("%c",&c);
    printf("%c", c);
  }

  return 0;

}


