
define bar
$(shell printf "#%.0s" {1..47}; echo)
endef

define usage_str

  Add usage here...

endef
export usage_str

usage help: 
	@echo "$${usage_str}" | more

