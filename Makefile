.PHONY: all setup clean_dist distro clean install dsc source_deb upload

NAME=vcstools
VERSION=0.1.14

all:
	echo "noop for debbuild"

setup:
	@echo "Confirming version numbers are all consistently taged with ${VERSION}"
	@grep ${VERSION} setup.py 1> /dev/null
	@echo "Confirmed: all files reference version ${VERSION}"

clean_dist:
	-rm -f MANIFEST
	-rm -rf dist
	-rm -rf deb_dist

distro: setup clean_dist
	python setup.py sdist

push: distro
	python setup.py sdist register upload
	scp dist/${NAME}-${VERSION}.tar.gz ipr:/var/www/pr.willowgarage.com/html/downloads/${NAME}

clean: clean_dist
	echo "clean"

install: distro
	sudo checkinstall python setup.py install

dsc: distro
	python setup.py --command-packages=stdeb.command sdist_dsc

source_deb: dsc
	# need to convert unstable to each distro and repeat
	cd deb_dist/${NAME}-${VERSION} && dpkg-buildpackage -sa -k84C5CECD

binary_deb: dsc
	# need to convert unstable to each distro and repeat
	cd deb_dist/${NAME}-${VERSION} && dpkg-buildpackage -sa -k84C5CECD

upload: source_deb
	cd deb_dist && dput ppa:tully.foote/tully-test-ppa ../${NAME}_${VERSION}-1_source.changes 

testsetup:
	echo "running tests"

test: testsetup
	nosetests --with-coverage --cover-package=vcstools --with-xunit
