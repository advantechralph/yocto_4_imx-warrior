.PHONY: packages/yocto/tegra/repo/init
packages/yocto/tegra/repo/init: $(builddir)/yocto/tegra/.repo_init

.PHONY: packages/yocto/tegra/repo/sync
packages/yocto/tegra/repo/sync: $(builddir)/yocto/tegra/.repo_sync

.PHONY: packages/yocto/tegra/clean_conf
packages/yocto/tegra/clean_conf: 
	@rm -rf $(builddir)/yocto/tegra/build
	@rm -rf $(builddir)/yocto/tegra/.conf
	@rm -rf $(builddir)/yocto/tegra/.extra-conf

.PHONY: packages/yocto/tegra/conf
packages/yocto/tegra/conf: packages/yocto/tegra/repo/sync $(builddir)/yocto/tegra/.conf $(builddir)/yocto/tegra/.extra-conf

$(builddir)/yocto/tegra/.conf: 
	@cd $(builddir)/yocto/tegra && source $(builddir)/yocto/tegra/sources/poky/oe-init-build-env build
	@touch $@

define tegra_extra_local_conf_str
BBLAYERS += " $(builddir)/yocto/tegra/sources/poky/meta-tegra "
endef
export tegra_extra_local_conf_str

define tegra_extra_bblayers_conf_str
MACHINE="jetson-nano-devkit-emmc"
ACCEPT_FSL_EULA = "1"
endef
export tegra_extra_bblayers_conf_str

.PHONY: packages/yocto/tegra/extra-conf
packages/yocto/tegra/extra-conf: $(builddir)/yocto/tegra/.extra-conf

$(builddir)/yocto/tegra/.extra-conf:
	@sed -i -e '$$ainclude extra-bblayers.conf' $(builddir)/yocto/tegra/build/conf/bblayers.conf
	@sed -i -e '$$ainclude extra-local.conf' $(builddir)/yocto/tegra/build/conf/local.conf
	@echo "$${tegra_extra_local_conf_str}" > $(builddir)/yocto/tegra/build/conf/extra-bblayers.conf
	@echo "$${tegra_extra_bblayers_conf_str}" > $(builddir)/yocto/tegra/build/conf/extra-local.conf
	@echo > $(builddir)/yocto/tegra/build/conf/sanity.conf
	@touch $@

$(builddir)/yocto/tegra/.manifest.git: 
	@mkdir -p $(builddir)/yocto/tegra/manifest.git
	@cd $(builddir)/yocto/tegra/manifest.git && git init
	@cp -a $(topdir)/packages/yocto/tegra/tegra.xml $(builddir)/yocto/tegra/manifest.git
	@cd $(builddir)/yocto/tegra/manifest.git; git add .; git commit -m "import xml";
	@touch $@

$(builddir)/yocto/tegra/.repo_init: packages/repo/fetch $(builddir)/yocto/tegra/.manifest.git 
	@cd $(builddir)/yocto/tegra && $(repo) init -u $(builddir)/yocto/tegra/manifest.git -b master -m tegra.xml
	@touch $@

$(builddir)/yocto/tegra/.repo_sync: $(builddir)/yocto/tegra/.repo_init
	@cd $(builddir)/yocto/tegra && $(repo) sync
	@touch $@

.PHONY: packages/yocto/tegra/bitbake/version
packages/yocto/tegra/bitbake/version: packages/yocto/tegra/conf
	@cd $(builddir)/yocto/tegra && source $(builddir)/yocto/tegra/sources/poky/oe-init-build-env build && bitbake -s

