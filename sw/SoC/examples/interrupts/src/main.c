#include <stdint.h>
/*
typedef struct plic_t {
    uint32_t cr;            // 0x0
    uint32_t state;         // 0x4
    uint16_t a;             // 0x8
    // 0xA
    ...
    ...
}
*/
int main(){

    /* Insert your code here */

    uint32_t * gpio_addr = (uint32_t *) 0x100000;
    uint8_t * rv_plic_addr = (uint8_t *) 0x300000;

    //struct plic_t * rv_plic_ptr = (struct plic_t *) 0x300000;

    //rv_plic_ptr->state = 0x00000;


    /*
    while(1){
	for(int i = 0; i < 100000; i++);
    	*gpio_addr = 0b00000000000000001111111111111111; // 0x0000ffff
    	for(int i = 0; i < 100000; i++);
    	*gpio_addr = 0x00000000;
    }
    
    */
   /*
    *(rv_plic_addr + (0x000004 / sizeof(uint32_t))) = (0x00000001 & 0x3);
    uint32_t reg_value = *(rv_plic_addr + (0x000004 / sizeof(uint32_t))) & 0x3;

    if (reg_value == 0x1) {
        *gpio_addr = 0x00000001; // Successo
    } else {
        *gpio_addr = 0x00000002; // Fallimento
    }
*/


    //LETTURA ESEGUITA CON SUCCESSO 
/*
    uint32_t reg_value = *(rv_plic_addr + (0x000004 / sizeof(uint32_t))) & 0x3;

    if (reg_value == 0x1) {
        *gpio_addr = 0x00000001; // Successo
    } else if (reg_value==0x2){
        *gpio_addr = 0x00000002; 
    } else if (reg_value==0x3){
        *gpio_addr = 0x000000FF; 
    } else                    {
        *gpio_addr = 0x00000400;
    }

*/
    uint32_t reg_value;// = rv_plic_addr[4] & 0x000000ff;
    //*gpio_addr = reg_value;
    for (int i = 0;i<32*4; i++){
        reg_value = rv_plic_addr[4+i];
    if (reg_value!=0xff){
        *gpio_addr = reg_value;
    }
    }

    
    /*
*(rv_plic_addr + (0x000004 / sizeof(uint32_t)))=0x2;
if (*(rv_plic_addr + (0x000004 / sizeof(uint32_t))) == 0x3) {
        *gpio_addr = 0x00000001; // Successo
    } else  {
        *gpio_addr = 0x00000400;
    }
*/


/*

    uint32_t new_value = 0x1; // Ad esempio, scrivere '01' sui bit 0 e 1
    uint32_t reg_value;

// Azzera i bit 0 e 1 mantenendo invariati gli altri bit
    //reg_value &= ~0x3;  // Maschera per azzerare gli ultimi due bit (0x3 = 0b11)

    // Imposta i nuovi valori sui bit 0 e 1
    reg_value |= new_value & 0x3;  // Solo i bit 0 e 1 vengono modificati

    // Scrivi il valore modificato nel registro
    *(rv_plic_addr + (0x000004 / sizeof(uint32_t))) = reg_value;

    // Verifica se la scrittura ha avuto successo
    if (*(rv_plic_addr + (0x000004 / sizeof(uint32_t))) == (reg_value & 0x3)) {
        // Scrivi su GPIO per accendere il LED 3
        *gpio_addr = 0x08; // LED 3 acceso, supponendo che LED 3 sia mappato su bit 3 del GPIO
    } else {
        // Se la scrittura non ha avuto successo, accendi un altro LED (ad esempio, LED 2)
        *gpio_addr = 0x09; // LED 2 acceso
    }

    */



/*
   // SCRITTURA SU  Interrupt Pending Bits 
    
    //*(rv_plic_addr + (0x002000 / sizeof(uint32_t))) = 0x00000001;
    //rv_plic_addr[0x04] = 0x0000001, 
    if (*(rv_plic_addr + (0x002000 / sizeof(uint32_t))) == 0x00000000) {
            *gpio_addr = 0x00000001;
        } else {
            *gpio_addr = 0x00000002;
        }
    
*/
    
       /*
     *(rv_plic_addr + 0x00001) = 0x00000001;
    if (*(rv_plic_addr + 0x00001) == 0x00000001) {
            *gpio_addr = 0x00000001;
        } else {
            *gpio_addr = 0x00000002;
        }
    */

   /*

   //*(rv_plic_addr + (0x001000 / sizeof(uint32_t))) = 0x00000001; // Scrive al registro Priority Threshold
    uint32_t read_value = *(rv_plic_addr + (0x000004 / sizeof(uint32_t))); // Legge il registro
    
    if (*(rv_plic_addr + (0x000004 / sizeof(uint32_t))) == read_value) {
        *gpio_addr = 0x00000004; // Indica successo
    } else {
        *gpio_addr = 0x00000002; // Indica fallimento
    }

    */
    while(1);

    return 0;
}