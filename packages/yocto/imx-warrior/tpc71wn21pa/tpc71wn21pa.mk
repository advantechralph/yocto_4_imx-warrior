.PHONY: packages/yocto/imx-warrior/tpc71wn21pa/repo/init
packages/yocto/imx-warrior/tpc71wn21pa/repo/init: \
	packages/repo/fetch \
	$(builddir)/yocto/tpc71wn21pa/.manifest.git \
	$(builddir)/yocto/tpc71wn21pa/.repo_init

.PHONY: packages/yocto/imx-warrior/tpc71wn21pa/repo/sync
packages/yocto/imx-warrior/tpc71wn21pa/repo/sync: \
	packages/repo/fetch \
	$(builddir)/yocto/tpc71wn21pa/.manifest.git \
	$(builddir)/yocto/tpc71wn21pa/.repo_init \
	$(builddir)/yocto/tpc71wn21pa/.repo_sync

$(builddir)/yocto/tpc71wn21pa/.manifest.git: 
	@mkdir -p $(builddir)/yocto/tpc71wn21pa/manifest.git
	@cd $(builddir)/yocto/tpc71wn21pa/manifest.git && git init
	@cp -a $(topdir)/packages/yocto/imx-warrior/tpc71wn21pa/tpc71wn21pa.xml $(builddir)/yocto/tpc71wn21pa/manifest.git
	@cd $(builddir)/yocto/tpc71wn21pa/manifest.git; git add .; git commit -m "import xml";
	@touch $@

$(builddir)/yocto/tpc71wn21pa/.repo_init: 
	@cd $(builddir)/yocto/tpc71wn21pa && $(repo) init -u $(builddir)/yocto/tpc71wn21pa/manifest.git -b master -m tpc71wn21pa.xml
	@touch $@

$(builddir)/yocto/tpc71wn21pa/.repo_sync:
	@cd $(builddir)/yocto/tpc71wn21pa && $(repo) sync
	@touch $@

tpc71wn21pa_yocto_machine:=imx6qtpc71wn21pa
# tpc71wn21pa_yocto_machine:=imx6qsabresd
tpc71wn21pa_yocto_distro:=fsl-imx-x11
tpc71wn21pa_yocto_builddir:=build
tpc71wn21pa_yocto_workdir:=$(builddir)/yocto/tpc71wn21pa/work

.PHONY: packages/yocto/imx-warrior/tpc71wn21pa/clean_conf
packages/yocto/imx-warrior/tpc71wn21pa/clean_conf: 
	@rm -rf $(builddir)/yocto/tpc71wn21pa/build
	@rm -rf $(builddir)/yocto/tpc71wn21pa/.conf
	@rm -rf $(builddir)/yocto/tpc71wn21pa/.extra-conf

.PHONY: packages/yocto/imx-warrior/tpc71wn21pa/conf
packages/yocto/imx-warrior/tpc71wn21pa/conf: \
	packages/yocto/imx-warrior/tpc71wn21pa/repo/sync \
	$(builddir)/yocto/tpc71wn21pa/.conf \
	$(builddir)/yocto/tpc71wn21pa/.extra-conf

.PHONY: packages/yocto/imx-warrior/tpc71wn21pa/test
packages/yocto/imx-warrior/tpc71wn21pa/test: packages/yocto/imx-warrior/tpc71wn21pa/repo/sync $(builddir)/yocto/tpc71wn21pa/.test

$(builddir)/yocto/tpc71wn21pa/.test:
	@cd $(builddir)/yocto/tpc71wn21pa && MACHINE=$(tpc71wn21pa_yocto_machine) \
		DISTRO=$(tpc71wn21pa_yocto_distro) \
		EULA=1 \
		source fsl-setup-release.sh -b $(tpc71wn21pa_yocto_builddir) -e $(tpc71wn21pa_yocto_distro)

$(builddir)/yocto/tpc71wn21pa/.conf: 
	@cd $(builddir)/yocto/tpc71wn21pa && MACHINE=$(tpc71wn21pa_yocto_machine) \
		DISTRO=$(tpc71wn21pa_yocto_distro) \
		EULA=1 \
		source fsl-setup-release.sh -b $(tpc71wn21pa_yocto_builddir) -e $(tpc71wn21pa_yocto_distro)
	@touch $@

define tpc71wn21pa_extra_local_conf_str
ACCEPT_FSL_EULA = "1"
DL_DIR = "$(tpc71wn21pa_yocto_workdir)/downloads"
TMPDIR = "$(tpc71wn21pa_yocto_workdir)/tmp"
SSTATE_DIR = "$(tpc71wn21pa_yocto_workdir)/sstate-cache"
CORE_IMAGE_EXTRA_INSTALL += " adv-base-files kernel-modules "
EXTRA_IMAGE_FEATURES += " package-management "
DISTRO_FEATURES_remove = " optee "
FEATURE_INSTALL_remove=" psplash "
# UBOOT_CONFIG += "1G"
SCMVERSION = "n"
endef
export tpc71wn21pa_extra_local_conf_str

define tpc71wn21pa_extra_bblayers_conf_str
BBLAYERS += " $(builddir)/yocto/tpc71wn21pa/sources/meta-advantech "
BBLAYERS += " $(builddir)/yocto/tpc71wn21pa/sources/meta-advantech/meta-bsp-patch "
endef
export tpc71wn21pa_extra_bblayers_conf_str

.PHONY: packages/yocto/imx-warrior/tpc71wn21pa/extra-conf
packages/yocto/imx-warrior/tpc71wn21pa/extra-conf: $(builddir)/yocto/tpc71wn21pa/.extra-conf

$(builddir)/yocto/tpc71wn21pa/.extra-conf:
	@mkdir -p $(tpc71wn21pa_yocto_workdir)
	@ln -sf $(topdir)/packages/yocto/imx-warrior/meta-advantech $(builddir)/yocto/tpc71wn21pa/sources
	@sed -i -e '$$ainclude extra-bblayers.conf' $(builddir)/yocto/tpc71wn21pa/build/conf/bblayers.conf
	@sed -i -e '$$ainclude extra-local.conf' $(builddir)/yocto/tpc71wn21pa/build/conf/local.conf
	@echo "$${tpc71wn21pa_extra_local_conf_str}" > $(builddir)/yocto/tpc71wn21pa/build/conf/extra-local.conf
	@echo "$${tpc71wn21pa_extra_bblayers_conf_str}" > $(builddir)/yocto/tpc71wn21pa/build/conf/extra-bblayers.conf
	@echo > $(builddir)/yocto/tpc71wn21pa/build/conf/sanity.conf
	@touch $@

.PHONY: packages/yocto/imx-warrior/tpc71wn21pa/bitbake/versions
packages/yocto/imx-warrior/tpc71wn21pa/bitbake/versions: packages/yocto/imx-warrior/tpc71wn21pa/conf
	@cd $(builddir)/yocto/tpc71wn21pa && source setup-environment $(tpc71wn21pa_yocto_builddir) && bitbake -s

.PHONY: packages/yocto/imx-warrior/tpc71wn21pa/bitbake/env
packages/yocto/imx-warrior/tpc71wn21pa/bitbake/env/%: packages/yocto/imx-warrior/tpc71wn21pa/conf
	@bitbake_target=$$(echo "$$(basename $(@))"); \
		cd $(builddir)/yocto/tpc71wn21pa && source setup-environment $(tpc71wn21pa_yocto_builddir) && bitbake -e $${bitbake_target};

.PHONY: packages/yocto/imx-warrior/tpc71wn21pa/bitbake
packages/yocto/imx-warrior/tpc71wn21pa/bitbake/%: packages/yocto/imx-warrior/tpc71wn21pa/conf
	@bitbake_target=$$(echo "$$(basename $(@))"); \
		cd $(builddir)/yocto/tpc71wn21pa && source setup-environment $(tpc71wn21pa_yocto_builddir) && bitbake $${bitbake_target};

