.PHONY: info
info: packages/info

.PHONY: packages/info
packages/info: 
	@printf "\n"
	@printf "%-30s: %s\n" "currdir" "$(currdir)"
	@printf "%-30s: %s\n" "builddir" "$(builddir)"
	@printf "%-30s: %s\n" "repo" "$(repo)"

