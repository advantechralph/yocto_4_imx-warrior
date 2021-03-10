
include macro.mk
include packages/*/*.mk
include models/*.mk

ifdef _REALRUN

.PHONY: all
all: 

else

export _REALRUN=1
.DEFAULT_GOAL:=usage
_MAKEFILE=$(CURDIR)/$(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST))
_MAKEFLAGS=$(filter-out --,$(MAKEFLAGS))

%: 
	@[ -e "/usr/bin/time" ] && time make -f $(_MAKEFILE) $@ $(filter-out --,$(_MAKEFLAGS)) || make -f $(_MAKEFILE) $@ $(filter-out --,$(_MAKEFLAGS)) 

endif

