build:
	jb build .
copy:
	cp -r _build/html/* docs
git:
	git add .
	git status
update: build copy git 