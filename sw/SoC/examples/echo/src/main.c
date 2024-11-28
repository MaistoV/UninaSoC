#include "tinyIO.h"
#include <stdint.h>

int main()
{ 

  tinyIO_init();

  char c;
  uint32_t u;
  int d;

  while(1){
    scanf("%d",&d);
    //c = _getchar();
    printf("%d", d);
  }

  return 0;

}


