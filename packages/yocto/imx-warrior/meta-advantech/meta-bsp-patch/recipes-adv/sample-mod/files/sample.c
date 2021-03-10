#include <linux/module.h>

int init_module(void){
	printk("%s, %d: \n", __FUNCTION__, ___LINE__);
	return 0;
}

void cleanup_module(void){
	printk("%s, %d: \n", __FUNCTION__, ___LINE__);
}

MODULE_LICENSE("GPL");
