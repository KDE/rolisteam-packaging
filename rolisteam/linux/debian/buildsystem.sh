#!/bin/sh

VERSION=1.9.0
PKGVERS=34
beta=34

rm -rf rolisteam
rm -rf rolisteam-packaging
rm -rf rolisteam.desktop

GIT_BRANCH="-b compile_qt-5-9 --single-branch"
PACKAGING_ROLISTEAM_ROOT="rolisteam-packaging/rolisteam"
DEBIAN_ROOT=$PACKAGING_ROLISTEAM_ROOT"/linux/debian"
ICON_PATH="rolisteam/resources/logo/rolisteam.svg"


git=git@invent.kde.org:kde/rolisteam.git
gitpackaging=git@invent.kde.org:kde/rolisteam-packaging.git

git clone $gitpackaging

cp $PACKAGING_ROLISTEAM_ROOT/rolisteam.desktop ./

if [  $# -gt 0 ]
then
	for i in "$@"; do
		if [ "$i" = "clean" ]
		then
		    	rm -rf rolisteam
		fi
        if [ "$i" = "appimage" ]
        then
					  export QML_SOURCES_PATHS="/home/renaud/documents/rolisteam/package/softwares/rolisteam/rolisteam/rolisteam/client/charactersheet/qml"
            mkdir rolisteam
            cp ./changelog rolisteam/
            cd rolisteam
            git clone --recursive $git
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
            ./linuxdeploy-x86_64.AppImage --appdir AppDir -e AppDir/usr/bin/rolisteam -i ../$ICON_PATH -d ../../rolisteam.desktop --plugin qt --output appimage
            mv Rolisteam*.AppImage ../../
            cd ..

        fi
		if [ "$i" = "tarball" ]
		then
		    mkdir rolisteam
		    cp ./rolisteam.desktop rolisteam/
		    cp ./changelog rolisteam/
		    cd rolisteam
		    git clone --recursive $git
		    cp ./rolisteam.desktop rolisteam-$VERSION/
		    mv rolisteam rolisteam-$VERSION
		    cp ./changelog rolisteam-$VERSION/
		    cd rolisteam-$VERSION
		    rm -rf packaging
            find . -name ".git*" -exec rm -rf {} \;
            lrelease client/client.pro
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
			mkdir rolisteam
			cp ./rolisteam.desktop rolisteam/
			cd rolisteam
	    git clone --recursive $GIT_BRANCH $git
			mv rolisteam rolisteam-$VERSION
			mv ./rolisteam.desktop rolisteam-$VERSION/
			cp -R ../$DEBIAN_ROOT rolisteam-$VERSION/
			cp ../changelog rolisteam-$VERSION/debian/
			cd rolisteam-$VERSION
			lrelease client/client.pro
			rm -rf packaging
			rm -rf .git
			#dch -i
			#dpkg-buildpackage -rfakeroot
      echo "###################################"
      pwd
			echo "y\n" | debuild -S -sa
			cd ..
			#dput ppa:rolisteam/ppa rolisteam_${VERSION}ubuntu${PKGVERS}_source.changes
		 	#dput -f ppa:rolisteam/rolisteamdev rolisteam_${VERSION}ubuntu1~ppa$PKGVERS~beta${beta}_source.changes
		 	dput -f ppa:rolisteam/rolisteamdev rolisteam_${VERSION}ubuntu${PKGVERS}_source.changes
		fi
	done
fi

