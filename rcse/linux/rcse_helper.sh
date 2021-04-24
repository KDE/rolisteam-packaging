#!/bin/sh

VERSION=1.9.3
PKGVERS=0
beta=0

rm -rf rcse
rm -rf rolisteam-packaging
rm -rf rcse.desktop

GIT_BRANCH=""
cd ..
PACKAGING_ROLISTEAM_ROOT=`pwd`
cd -

ICON_PATH="rcse/resources/logo/rcse.svg"
DESKTOP_FILE_PATH=$PACKAGING_ROLISTEAM_ROOT/rcse.desktop



git=git@invent.kde.org:rolisteam/rcse.git
gitpackaging=git@invent.kde.org:rolisteam/rolisteam-packaging.git


dest=`mktemp -d -p ./`

cd $dest
DEBIAN_ROOT=$PACKAGING_ROLISTEAM_ROOT"/linux/ubuntu/debian"
CHANGE_LOG=$PACKAGING_ROLISTEAM_ROOT"/linux/changelog"
git clone $gitpackaging

if [  $# -gt 0 ]
then
	for i in "$@"; do
	        if [ "$i" = "appimage" ]
        	then
		  	export QML_SOURCES_PATHS="$PACKAGING_ROLISTEAM_ROOT/$dest/rolisteam/rolisteam/client/charactersheet/qml"
		    git clone --recursive  $git
			mkdir build
			cd build
			lrelease ../rolisteam/client/client.pro
			qmake -r ../rolisteam/rolisteam.pro CONFIG+=release .
			make -j8 install INSTALL_ROOT=../AppDir/usr/bin/
			wget https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
			wget https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage
			# make them executable
			chmod +x linuxdeploy*.AppImage
			mv AppDir/usr/bin/usr/local/bin/* AppDir/usr/bin/
			./linuxdeploy-x86_64.AppImage --appdir AppDir -e AppDir/usr/bin/rolisteam -i ../$ICON_PATH -d $DESKTOP_FILE_PATH --plugin qt --output appimage
			mv Rolisteam*.AppImage ../../
			cd ..

	        fi
		if [ "$i" = "tarball" ]
		then
		    mkdir rcse
		    cp ./rcse.desktop rcse/
		    cp ./changelog rcse/
		    cd rcse
		    git clone --recursive $git
		    cp ./rcse.desktop rcse-$VERSION/
		    mv rcse rcse-$VERSION
		    cp ./changelog rcse-$VERSION/
		    cd rcse-$VERSION
		    rm -rf packaging
        	find . -name ".git*" -exec rm -rf {} \;
        	lrelease rcse.pro
		    cd ..
		    tar -czf rcse-$VERSION.tar.gz rcse-$VERSION
		    zip -r rcse-$VERSION.zip rcse-$VERSION
		fi
		if [ "$i" = "build" ]
		then
			echo "Clone Rolisteam sources from GIT"
			git clone --recursive  $git
			echo "\nRename folder"
			mv rolisteam rolisteam-$VERSION
			echo "\nMove rolisteam.desktop to sources"
			cp $DESKTOP_FILE_PATH rolisteam-$VERSION/
			echo "\nMove debian folder into source"
			cp -R $DEBIAN_ROOT rolisteam-$VERSION/
			echo "\nMove Changelog"
			cp $CHANGE_LOG rolisteam-$VERSION/debian/
			echo "\nStart build"
			cd rolisteam-$VERSION
			lrelease client/client.pro
			rm -rf packaging
			rm -rf .git
			#dch -i
			#dpkg-buildpackage -rfakeroot
      			echo "###################################"
      			read
      			read
      			pwd
			echo "y\n" | debuild -S -sa
			cd ..
			dput ppa:rolisteam/ppa rolisteam_${VERSION}ubuntu${PKGVERS}_source.changes
		 	#dput -f ppa:rolisteam/rolisteamdev rolisteam_${VERSION}ubuntu1~ppa$PKGVERS~beta${beta}_source.changes
		 	#dput -f ppa:rolisteam/rolisteamdev rolisteam_${VERSION}ubuntu${PKGVERS}_source.changes
		fi
	done
fi

