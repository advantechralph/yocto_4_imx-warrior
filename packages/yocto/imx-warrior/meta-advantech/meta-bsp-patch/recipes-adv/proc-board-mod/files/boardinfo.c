#include <linux/proc_fs.h>
#include <linux/seq_file.h>

static struct proc_dir_entry *entry;
static char board_type[20]="WISE-710-A2";

static int boardinfo_proc_show(struct seq_file *m, void *v){
	seq_printf(m, "%s", board_type);
	return 0;
}

static int boardinfo_proc_open(struct inode *inode, struct file *file){
	return single_open(file, boardinfo_proc_show, NULL);
}

static const struct file_operations boardinfo_proc_fops = {
	.open           = boardinfo_proc_open,
	.read           = seq_read,
	.llseek         = seq_lseek,
	.release        = single_release,
};

int proc_boardinfo_init(void){
	entry = proc_create("board", 0, NULL, &boardinfo_proc_fops);
	return 0;
}

void proc_boardinfo_exit(void){
	proc_remove(entry);
}

