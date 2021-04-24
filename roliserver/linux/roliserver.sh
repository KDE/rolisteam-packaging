#!/bin/sh

VERSION=1.9.3
PKGVERS=0
beta=0

rm -rf roliserver
rm -rf rolisteam-packaging

rm -rf tmp.*

GIT_BRANCH="stable"
cd ..
PACKAGING_ROLISTEAM_ROOT=`pwd`
cd -

ICON_PATH="rolisteam/resources/logo/rolisteam.svg"
DESKTOP_FILE_PATH=$PACKAGING_ROLISTEAM_ROOT/rolisteam.desktop



git=git@invent.kde.org:rolisteam/rolisteam.git
gitpackaging=git@invent.kde.org:rolisteam/rolisteam-packaging.git


dest=`mktemp -d -p ./`

cd $dest
DEBIAN_ROOT=$PACKAGING_ROLISTEAM_ROOT"/linux/ubuntu/debian"
CHANGE_LOG=$PACKAGING_ROLISTEAM_ROOT"/linux/changelog"
CONFIG_FILE=$PACKAGING_ROLISTEAM_ROOT"/default.conf"
git clone $gitpackaging

if [  $# -gt 0 ]
then
	for i in "$@"; do
	    if [ "$i" = "appimage" ]
        then
			echo "No appimage yet"
		  	#export QML_SOURCES_PATHS="$PACKAGING_ROLISTEAM_ROOT/$dest/rolisteam/rolisteam/client/charactersheet/qml"
		    #    git clone --recursive  $git
			#mkdir build
			#cd build
			#lrelease ../rolisteam/client/client.pro
			#qmake -r ../rolisteam/rolisteam.pro CONFIG+=release .
			#make -j8 install INSTALL_ROOT=../AppDir/usr/bin/
			#wget https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
			#wget https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage
			## make them executable
			#chmod +x linuxdeploy*.AppImage
			#mv AppDir/usr/bin/usr/local/bin/* AppDir/usr/bin/
			#./linuxdeploy-x86_64.AppImage --appdir AppDir -e AppDir/usr/bin/rolisteam -i ../$ICON_PATH -d $DESKTOP_FILE_PATH --plugin qt --output appimage
			#mv Rolisteam*.AppImage ../../
			#cd ..

	    fi
		if [ "$i" = "tarball" ]
		then
			echo "No tarball yet"
		    #mkdir rolisteam
		    #cp ./rolisteam.desktop rolisteam/
		    #cp ./changelog rolisteam/
		    #cd rolisteam
		    #git clone --recursive $git
		    #cp ./rolisteam.desktop rolisteam-$VERSION/
		    #mv rolisteam rolisteam-$VERSION
		    #cp ./changelog rolisteam-$VERSION/
		    #cd rolisteam-$VERSION
		    #rm -rf packaging
        	#    find . -name ".git*" -exec rm -rf {} \;
        	#    lrelease client/client.pro
		    #cd ..
		    #tar -czf rolisteam-$VERSION.tar.gz rolisteam-$VERSION
		    #zip -r rolisteam-$VERSION.zip rolisteam-$VERSION
		fi
		if [ "$i" = "build" ]
		then
			echo "Clone Rolisteam sources from GIT"
			git clone -b $GIT_BRANCH --recursive  $git
			
			echo "\nMove Files"
			mv rolisteam rolisteam-$VERSION
			cp -R $DEBIAN_ROOT rolisteam-$VERSION/
			cp $CHANGE_LOG rolisteam-$VERSION/debian/
			cp $CONFIG_FILE rolisteam-$VERSION/


			echo "\nStart build"
			cd rolisteam-$VERSION
			lrelease server/server.pro
			rm -rf packaging
			rm -rf .git
			#dch -i
			dpkg-buildpackage -rfakeroot
      		pwd
			#echo "y\n" | debuild -S -sa
			cd ..
			#dput ppa:rolisteam/ppa roliserver_${VERSION}ubuntu${PKGVERS}_source.changes
		 	#dput -f ppa:rolisteam/rolisteamdev rolisteam_${VERSION}ubuntu1~ppa$PKGVERS~beta${beta}_source.changes
		 	#dput -f ppa:rolisteam/rolisteamdev rolisteam_${VERSION}ubuntu${PKGVERS}_source.changes
		fi
	done
fi

