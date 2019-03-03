TARGETS_DRAFTS := draft-ietf-core-dynlink
TARGETS_TAGS := draft-ietf-core-dynlink-00 draft-ietf-core-dynlink-01 draft-ietf-core-dynlink-02
.INTERMEDIATE: draft-ietf-core-dynlink-00.md
draft-ietf-core-dynlink-00.md:
	git show "draft-ietf-core-dynlink-00:draft-ietf-core-dynlink.md" | sed -e 's/draft-ietf-core-dynlink-latest/draft-ietf-core-dynlink-00/g' >$@
.INTERMEDIATE: draft-ietf-core-dynlink-01.md
draft-ietf-core-dynlink-01.md:
	git show "draft-ietf-core-dynlink-01:draft-ietf-core-dynlink.md" | sed -e 's/draft-ietf-core-dynlink-latest/draft-ietf-core-dynlink-01/g' >$@
.INTERMEDIATE: draft-ietf-core-dynlink-02.md
draft-ietf-core-dynlink-02.md:
	git show "draft-ietf-core-dynlink-02:draft-ietf-core-dynlink.md" | sed -e 's/draft-ietf-core-dynlink-latest/draft-ietf-core-dynlink-02/g' >$@
draft-ietf-core-dynlink-03.md: draft-ietf-core-dynlink.md
	sed -e 's/draft-ietf-core-dynlink-latest/draft-ietf-core-dynlink-03/g' $< >$@
diff-draft-ietf-core-dynlink.html: draft-ietf-core-dynlink-02.txt draft-ietf-core-dynlink-03.txt
	-$(rfcdiff) --html --stdout $^ > $@
