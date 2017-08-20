#!/bin/sh
VERSION=1.8.2
PKGVERS=2
rm -rf rolisteam
if [  $# -gt 0 ]
then
	for i in "$@"; do
		if [ "$i" = "clean" ]
		then
		    	rm -rf rolisteam
		fi
		if [ "$i" = "tarball" ]
		then
		    mkdir rolisteam
		    cp ./rolisteam.desktop rolisteam/
		    cp ./changelog rolisteam/
		    cd rolisteam
		    git clone --recursive git@github.com:Rolisteam/rolisteam.git
		    cp ./rolisteam.desktop rolisteam-$VERSION/
		    mv rolisteam rolisteam-$VERSION
		    cp ./changelog rolisteam-$VERSION/
		    cd rolisteam-$VERSION
		    rm -rf packaging
            find . -name ".git*" -exec rm -rf {} \;
		    cd ..
		    tar -czf rolisteam-$VERSION.tar.gz rolisteam-$VERSION
		    zip -r rolisteam-$VERSION.zip rolisteam-$VERSION
		fi
		if [ "$i" = "setup" ]
		then
		    sudo apt-get install libqt5-dev build-essential cdbs debhelper wdiff  devscripts dh-make dpatch vim git
		fi
		if [ "$i" = "build" ]
		then
            rm -rf rolisteam
			mkdir rolisteam
			cp ./rolisteam.desktop rolisteam/
			cd rolisteam
		        git clone --recursive git@github.com:Rolisteam/rolisteam.git
			mv rolisteam rolisteam-$VERSION
			mv ./rolisteam.desktop rolisteam-$VERSION/
			cp -R ../debian rolisteam-$VERSION/
			cp ../changelog rolisteam-$VERSION/debian/
			cd rolisteam-$VERSION
			lrelease rolisteam.pro
			rm -rf packaging
			rm -rf .git
			#dch -i
			#dpkg-buildpackage -rfakeroot
            echo "###################################"
            pwd
			echo "y\n" | debuild -S -sa
			cd ..
			dput ppa:rolisteam/ppa rolisteam_${VERSION}ubuntu${PKGVERS}_source.changes
		 	#dput -f ppa:rolisteam/rolisteamdev rolisteam_${VERSION}ubuntu1~ppa$PKGVERS~beta_source.changes
		 	#dput -f ppa:rolisteam/rolisteamdev rolisteam_${VERSION}ubuntu${PKGVERS}_source.changes
		fi
	done
fi
