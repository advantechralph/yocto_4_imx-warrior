repodir:=$(builddir)/repo
repo:=$(repodir)/repo
repourl:=http://commondatastorage.googleapis.com/git-repo-downloads/repo
repogiturl:=https://gerrit.googlesource.com/git-repo

.PHONY: repo
repo: packages/repo/fetch

.PHONY: packages/repo/fetch
packages/repo/fetch: $(builddir) $(builddir)/.fetch_repo

.PHONY: packages/repo/clean
packages/repo/clean: 
	@rm -rf $(builddir)/.fetch_repo $(repodir)

$(builddir)/.fetch_repo: 
	#   @mkdir -p $(repodir)
	#   #   @curl -s $(repourl) -o $(repo)
	@git clone --branch v1.13.9.4 $(repogiturl) $(repodir) && rm -rf $(repodir)/.git
	@chmod a+x $(repo)
	@touch $@

