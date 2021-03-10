
define bar
$(shell printf "#%.0s" {1..47}; echo)
endef

define usage_str

  TPC71WN21PA Yocto Warrior Build Package Usage: 

endef
export usage_str

usage help: 
	@echo "$${usage_str}" | more

