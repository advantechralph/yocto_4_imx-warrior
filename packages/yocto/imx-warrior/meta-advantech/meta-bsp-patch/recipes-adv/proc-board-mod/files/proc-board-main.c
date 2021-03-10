
#include <linux/of_platform.h>
#include <linux/module.h>
#include "boardinfo.h"

char board_type[20];
char board_cpu[20];

struct proc_board_data {
	const char *board_type;
	const char *advboot_version;
	const char *uboot_version;
	const char *board_cpu;
};

/* Code to create from OpenFirmware platform devices */
static int proc_board_probe_dt(struct proc_board_data *board , struct platform_device *pdev)
{
	struct device_node *np = pdev->dev.of_node;
	struct proc_board_data board_info = {};

	/* no device tree device */
	if (!np)
	{
		printk("\n [proc_board_probe_dt] no device tree device... \n");
		return -1;
	}

	board_info.board_type = of_get_property(np, "board-type", NULL);
	board_info.board_cpu = of_get_property(np, "board-cpu", NULL);
	board_info.advboot_version = of_get_property(np, "advboot_version", NULL);
	board_info.uboot_version = of_get_property(np, "uboot_version", NULL);
	printk("board-type: %s\n", board_info.board_type);
	board = &board_info;
	strcpy(board_type, board_info.board_type);
	strcpy(board_cpu, board_info.board_cpu);

	return 0;
}

static const struct of_device_id of_proc_board_match[] = {
	{ .compatible = "proc-board-data", },
	{},
};

MODULE_DEVICE_TABLE(of, of_proc_board_match);

static int proc_board_probe(struct platform_device *pdev){
	struct proc_board_data *board;
	int ret = 0;

	printk("%s, %d\n", __FUNCTION__, __LINE__);
	board = devm_kzalloc(&pdev->dev, sizeof(struct proc_board_data), GFP_KERNEL);
	
	if (!board) {
		printk("\n [proc_board_probe] Allocate board error... \n");
		return -ENOMEM;
	}

	ret = proc_board_probe_dt(board, pdev);
	
	if (ret < 0) { 
		printk("\n [proc_board_probe] proc_board_probe_dt() Fail.\n");
		return ret;
	}	

	platform_set_drvdata(pdev, board);

	return 0;
}

static struct platform_driver proc_board_driver = {
	.probe		= proc_board_probe,
	.driver		= {
		.name	= "proc-board-data",
		.owner	= THIS_MODULE,
		.of_match_table = of_match_ptr(of_proc_board_match),
	},
};

int proc_board_init(void){
	platform_driver_register(&proc_board_driver);
	proc_boardinfo_init();
	return 0; 
}

void proc_board_exit(void){
	proc_boardinfo_exit();
	platform_driver_unregister(&proc_board_driver);
}

module_init(proc_board_init);
module_exit(proc_board_exit);

MODULE_DESCRIPTION("Proc Board Data Driver");
MODULE_LICENSE("GPL");
MODULE_AUTHOR("Advantech/Ralph Wang");
MODULE_ALIAS("platform:proc-board-data");

