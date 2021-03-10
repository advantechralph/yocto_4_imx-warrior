.PHONY: packages/l4t/toolchain/fetch
packages/l4t/toolchain/fetch: $(builddir)/l4t/toolchain $(builddir)/l4t/toolchain/.fetch $(builddir)/l4t/toolchain/.unpack

$(builddir)/l4t/toolchain: 
	@mkdir -p $@

$(builddir)/l4t/toolchain/.fetch: 
	@cd $(builddir)/l4t/toolchain && wget $(l4t_toolchain_dl_url) 
	@touch $@

$(builddir)/l4t/toolchain/.unpack: 
	@cd $(builddir)/l4t/toolchain && tar -xpvf $(l4t_toolchain_dl_file)
	@touch $@

.PHONY: packages/l4t/toolchain/clean
packages/l4t/toolchain/clean:
	@rm -rf $(builddir)/l4t/toolchain

.PHONY: packages/l4t/toolchain/info
packages/l4t/toolchain/info:
	@echo l4t_toolchain_dl_url=$(l4t_toolchain_dl_url)
	@echo l4t_toolchain_dl_file=$(l4t_toolchain_dl_file)

