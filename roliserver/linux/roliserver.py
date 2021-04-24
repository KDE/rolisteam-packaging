#!/usr/bin/python3

import argparse
import tempfile
import git
import sys
import stat
import subprocess
import glob
import requests
import shutil
import os

def merge_path(path,directory):
    return os.path.join(path, directory)

def run_process(args, path):
    subprocess.call(args,cwd=path)

def clone_repo(path,url_repo,name):
    git.Git(path).clone(url_repo,"--recurse-submodules",name)

def move_content(source_file, to):
    content = os.listdir(source_file)

    for file_name in content:
        shutil.move(os.join.path(source_file, file_name), to)


def get_file(url, destination):
    print("Downloading {}".format(destination))
    r = requests.get(url)
    with open(destination, 'wb') as f:
        f.write(r.content)

def release_translation(path):
    print("release translation")
    print(path)
    proArray = glob.glob(merge_path(path,"*.pro"))
    run_process(["lrelease",proArray[0]],path)

def allow_execution(path):
    st = os.stat(path)
    os.chmod(path, st.st_mode | stat.S_IEXEC)


def icon_path(app_name):
    print("icon_path")
    path_dict={"rolisteam":"resources/logo/rolisteam.svg", "rcse":"resources/logo/rcse.svg","dice":"","rcm":""}
    return path_dict[app_name]


def build_app(path):
    print("build app")
    build_directory=merge_path(path, "build")
    os.mkdir(build_directory)
    release_translation(path)
    run_process(["qmake","-r","../","CONFIG+=release","."],build_directory)
    run_process(["make","-j8"],build_directory)
    return build_directory


def build_appimage(path, version, app_name):
    print("build appimage")
    build_directory = build_app(path)

    linuxdeploy_path=merge_path(path, "linuxdeploy-x86_64.AppImage")
    linuxdeployqtplugin_path=merge_path(path, "linuxdeploy-plugin-qt-x86_64.AppImage")
    get_file("https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage",linuxdeploy_path)
    allow_execution(linuxdeploy_path)
    get_file("https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage",linuxdeployqtplugin_path)
    allow_execution(linuxdeployqtplugin_path)
    move_content(merge_path(build_directory,"AppDir/usr/bin/usr/local/bin"), merge_path(build_directory,"AppDir/usr/bin"))
    run_process([linuxdeploy_path,"--appdir","../","AppDir","-e","AppDir/usr/bin/{}".format(app_name),"-i","../$ICON_PATH","-d","$DESKTOP_FILE_PATH","--plugin","qt","--output","appimage"],build_directory)
    appImageArray = glob.glob(build_directory+"*.AppImage")
    shutil.move(appImageArray[0],merge_path(path,"../"))
    run_process(["make","install","INSTALL_ROOT=../AppDir/usr/bin/"],buildDirectory)

def main():
    parser = argparse.ArgumentParser(description="Helper script to generate new rolisteam version.")
    parser.add_argument("-v","--version", help="Give the version of the software")
    parser.add_argument("-p","--package_version",type=int,default=0, help="The package version, default=0")
    parser.add_argument("-b","--branch",default="master", help="Git branch to checkout to build")
    parser.add_argument("-t","--tarball",action="store_true", help="Generate Tarball")
    parser.add_argument("-z","--zip",action="store_true", help="Generate Zip archive")
    parser.add_argument("-d","--deb",action="count",default=0, help="Create deb on launchpad: -d to upload to the official launchpad, -dd to upload to the dev launchpad.")
    parser.add_argument("-a","--appimage",action="store_true", help="Generate Appimage")
    parser.add_argument("-s","--sourceforge",action="store_true", help="Upload result to sourceforge")
    #parser.add_argument("-s","--software",default="all", choices=["all","rolisteam","rcse","dice","rcm"], help="List software: all builds everything but rcm.")
    parser.add_argument('softwares', metavar='N', nargs='+',choices=["all","rolisteam","rcse","dice","rcm"],
                    help='an integer for the accumulator')
    args = parser.parse_args()

    #repos=["https://invent.kde.org/rolisteam/rolisteam.git","https://invent.kde.org/rolisteam/rcse.git","https://invent.kde.org/rolisteam/rolisteam-diceparser.git","https://github.com/obiwankennedy/rcm"]
    repos=["https://invent.kde.org/rolisteam/rolisteam.git","https://invent.kde.org/rolisteam/rcse.git","https://invent.kde.org/rolisteam/rolisteam-diceparser.git"]
    names=["rolisteam","rcse","rolisteam-diceparser","rcm"]



    tmpdirname = tempfile.mkdtemp() # dir="./"
    print(tmpdirname)
    i = 0
    for software in args.softwares:
        name=software
        repo=""
        if software == "rolisteam":
            repo="https://invent.kde.org/rolisteam/rolisteam.git"
        elif software == "rcse":
            repo="https://invent.kde.org/rolisteam/rcse.git"
        elif software == "dice":
            repo="https://invent.kde.org/rolisteam/rolisteam-diceparser.git"
        elif software == "rcm":
            repo="https://github.com/obiwankennedy/rcm"

        clone_repo("{}".format(tmpdirname),repo, name)
        path = os.path.join(tmpdirname,name)

        if args.appimage:
            build_appimage(path, args.version,name)




        i+=1


if __name__ == '__main__':
    main()
