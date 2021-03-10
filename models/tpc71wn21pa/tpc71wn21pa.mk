ifeq ($(modelname),tpc71wn21pa)
bspname:=TPC71W-N21PA-r1-Yocto2.7-$(shell date +"%Y%m%d")
bspspl=$(currdir)/bsp/spl/n21pa
bsplogo=$(currdir)/bsp/logo/advantech/adv_logo_1024x600_32bpp.bmp
bspscripts=$(currdir)/bsp/scripts/basic
bspdtbname=imx6q-tpc71w-n21pa.dtb
bspdtb=$(shell realpath -m $(tpc71wn21pa_yocto_workdir)/tmp/deploy/images/$(tpc71wn21pa_yocto_machine)/$(bspdtbname))

.PHONY: bitbake
bitbake/%: 
	@bitbake_target=$$(echo "$$(basename $(@))"); make packages/yocto/imx-warrior/tpc71wn21pa/bitbake/$${bitbake_target}; 

.PHONY: bitbake/env
bitbake/env/%: 
	@bitbake_target=$$(echo "$$(basename $(@))"); make packages/yocto/imx-warrior/tpc71wn21pa/bitbake/env/$${bitbake_target}; 

.PHONY: image
image: packages/yocto/imx-warrior/tpc71wn21pa/bitbake/fsl-image-qt5

.PHONY: boot
boot: packages/yocto/imx-warrior/tpc71wn21pa/bitbake/u-boot-imx

.PHONY: kernel
kernel: packages/yocto/imx-warrior/tpc71wn21pa/bitbake/linux-imx

include models/tpc71wn21pa/*/*.mk

endif

