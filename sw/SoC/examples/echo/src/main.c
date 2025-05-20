#include "uninasoc.h"

int main() {

  char str[128];

  uninasoc_init();

  while(1){
    printf("Please enter a string\n\r");

    scanf("%s",str);

    printf("Your string is\n\r%s", str);
    printf("\n\r");
  }

  return 0;

}


