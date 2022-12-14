dummy:
	@echo No need to make anything.

ifdef VERSION
release:
	@git update-index --refresh --unmerged
	@if git diff-index --name-only HEAD | grep ^ ; then \
		echo Uncommitted changes in above files; exit 1; fi
	@git checkout master
	@sed -i.bak -e 's/^\(my $$version = \).*/\1$(VERSION);/' get_iplayer
	@sed -i.bak -e 's/^\(my $$VERSION = \).*/\1$(VERSION);/' get_iplayer.cgi
	@sed -i.bak -e 's/\(get_iplayer \)[0-9.]\{1,\}\( or higher\)/\1$(VERSION)\2/g' .github/ISSUE_TEMPLATE/bug_report.yaml
	@rm -f get_iplayer.bak get_iplayer.cgi.bak .github/ISSUE_TEMPLATE/bug_report.yaml.bak
	@./get_iplayer --nocopyright --manpage get_iplayer.1
	@git diff --exit-code get_iplayer.1 > /dev/null || \
		sed -i.bak -e 's/\(\.TH GET_IPLAYER "1" "\)[^"]*"/\1$(shell date +"%B %Y")\"/' get_iplayer get_iplayer.1
	@rm -f get_iplayer.bak get_iplayer.1.bak
	@git log --format='%aN' | sort -u > CONTRIBUTORS; git add CONTRIBUTORS
	@git commit -m "Release $(VERSION)" get_iplayer get_iplayer.cgi get_iplayer.1 CONTRIBUTORS .github/ISSUE_TEMPLATE/bug_report.yaml
	@git tag v$(VERSION)

tarball:
	@git update-index --refresh --unmerged
	@if git diff-index --name-only v$(VERSION) | grep ^ ; then \
		echo Uncommitted changes in above files; exit 1; fi
	git archive --format=tar --prefix=get_iplayer-$(VERSION)/ v$(VERSION) | gzip -9 > get_iplayer-$(VERSION).tar.gz
endif
