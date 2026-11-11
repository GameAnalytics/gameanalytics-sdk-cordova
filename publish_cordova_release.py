#!/usr/bin/python
import subprocess
import os
import shutil
import sys
import getopt

CORDOVA_DEV_DIR = os.path.abspath(os.path.join(__file__, '..'))
CORDOVA_DIR = os.path.abspath(os.path.join(__file__, '..', '..', 'GA-SDK-CORDOVA'))

GA_DEV_PLUGIN_DIR = os.path.join(CORDOVA_DEV_DIR, "gameanalytics")
GA_DEV_PLUGIN_SRC_DIR = os.path.join(GA_DEV_PLUGIN_DIR, "src")
GA_DEV_PLUGIN_WWW_DIR = os.path.join(GA_DEV_PLUGIN_DIR, "www")
GA_DEV_PLUGIN_PACKAGE_FILE = os.path.join(GA_DEV_PLUGIN_DIR, "package.json")
GA_DEV_PLUGIN_PLUGIN_FILE = os.path.join(GA_DEV_PLUGIN_DIR, "plugin.xml")

CORDOVA_SRC_DIR = os.path.abspath(os.path.join(CORDOVA_DIR, 'src'))
CORDOVA_WWW_DIR = os.path.abspath(os.path.join(CORDOVA_DIR, 'www'))
CORDOVA_PLUGIN_PACKAGE_FILE = os.path.join(CORDOVA_DIR, "package.json")
CORDOVA_PLUGIN_PLUGIN_FILE = os.path.join(CORDOVA_DIR, "plugin.xml")

GA_ANDROID_FILE = os.path.join(GA_DEV_PLUGIN_DIR, "src", "android", "GameAnalyticsCordova.java")
GA_IOS_FILE = os.path.join(GA_DEV_PLUGIN_DIR, "src", "ios", "GameAnalyticsCordova.m")
README_MD_FILE = os.path.join(CORDOVA_DIR, "README.md")

CHANGELOG_TOP_TAG = '<!--(CHANGELOG_TOP)-->'
ANDROID_VERSION_TAG = '    private static final String VERSION = '
IOS_VERSION_TAG = '#define VERSION @'
PACKAGE_VERSION_TAG = '    "version": '
PLUGIN_VERSION_TAG = '<plugin xmlns="http://apache.org/cordova/ns/plugins/1.0" xmlns:android="http://schemas.android.com/apk/res/android" id="cordova-plugin-gameanalytics" version='


def call_process(process_arguments, process_workingdir="", silent=False):
    print('Call process ' + str(process_arguments))
    current_workingdir = os.getcwd()

    if process_workingdir != "":
        os.chdir(process_workingdir)

    if silent is True:
        subprocess.check_call(process_arguments, stdout=open(os.devnull, 'wb'))
    else:
        subprocess.check_call(process_arguments)

    os.chdir(current_workingdir)


def main(argv):
    version = ''
    usage = 'Usage: publish_cordova_release.py -v <version> -c <changelog> [-b <branch>]'
    changelogRaw = ''
    changelogDelimeter = '::'
    branch = 'master'

    try:
        opts, args = getopt.getopt(argv, "hv:c:b:", ["version=", "changelog=", "branch="])
    except getopt.GetoptError:
        print(usage)
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print(usage)
            sys.exit()
        elif opt in ("-v", "--version"):
            version = arg
        elif opt in ("-c", "--changelog"):
            changelogRaw = arg
        elif opt in ("-b", "--branch"):
            branch = arg

    if version == "":
        print(usage)
        sys.exit(2)

    if changelogRaw == "":
        print(usage)
        sys.exit(2)

    print('--- publishing version: ' + version + ' ----')

    print('--- updating version in files ----')
    tagFound = False
    f = open(GA_ANDROID_FILE, "r+b")
    lines = f.readlines()
    for i in range(len(lines)):
        if lines[i].decode().startswith(ANDROID_VERSION_TAG):
            lines[i] = (ANDROID_VERSION_TAG + '"' +
                        version + '";\n').encode("utf-8")
            tagFound = True
            break

    f.seek(0)
    f.writelines(lines)
    f.truncate()
    f.close()

    if tagFound is False:
        print('Version not found in GameAnalyticsCordova.java')
        sys.exit(2)

    tagFound = False
    f = open(GA_IOS_FILE, "r+b")
    lines = f.readlines()
    for i in range(len(lines)):
        if lines[i].decode().startswith(IOS_VERSION_TAG):
            lines[i] = (IOS_VERSION_TAG + '"' +
                        version + '"\n').encode("utf-8")
            tagFound = True
            break

    f.seek(0)
    f.writelines(lines)
    f.truncate()
    f.close()

    if tagFound is False:
        print('Version not found in GameAnalyticsCordova.m')
        sys.exit(2)

    tagFound = False
    f = open(GA_DEV_PLUGIN_PACKAGE_FILE, "r+b")
    lines = f.readlines()
    for i in range(len(lines)):
        if lines[i].decode().startswith(PACKAGE_VERSION_TAG):
            lines[i] = (PACKAGE_VERSION_TAG + '"' +
                        version + '",\n').encode("utf-8")
            tagFound = True
            break

    f.seek(0)
    f.writelines(lines)
    f.truncate()
    f.close()

    if tagFound is False:
        print('Version not found in package.json')
        sys.exit(2)

    tagFound = False
    f = open(GA_DEV_PLUGIN_PLUGIN_FILE, "r+b")
    lines = f.readlines()
    for i in range(len(lines)):
        if lines[i].decode().startswith(PLUGIN_VERSION_TAG):
            lines[i] = (PLUGIN_VERSION_TAG + '"' +
                        version + '">\n').encode("utf-8")
            tagFound = True
            break

    f.seek(0)
    f.writelines(lines)
    f.truncate()
    f.close()

    if tagFound is False:
        print('Version not found in plugin.xml')
        sys.exit(2)

    print('--- done updating version in files ----')

    print('--- copying cordova files ----')
    shutil.copy(GA_DEV_PLUGIN_PACKAGE_FILE, CORDOVA_PLUGIN_PACKAGE_FILE)
    shutil.copy(GA_DEV_PLUGIN_PLUGIN_FILE, CORDOVA_PLUGIN_PLUGIN_FILE)

    if os.path.exists(CORDOVA_SRC_DIR):
        shutil.rmtree(CORDOVA_SRC_DIR)
    shutil.copytree(GA_DEV_PLUGIN_SRC_DIR, CORDOVA_SRC_DIR)

    if os.path.exists(CORDOVA_WWW_DIR):
        shutil.rmtree(CORDOVA_WWW_DIR)
    shutil.copytree(GA_DEV_PLUGIN_WWW_DIR, CORDOVA_WWW_DIR)
    print('--- done copying cordova files ----')

    print('--- updating README.md ----')
    tagFound = False
    f = open(README_MD_FILE, "r+b")
    lines = f.readlines()
    for i in range(len(lines)):
        if lines[i].decode().startswith(CHANGELOG_TOP_TAG):
            lines.insert(i + 1, ('**' + version + '**\n').encode("utf-8"))
            changelogLines = changelogRaw.split(changelogDelimeter)

            j = 2
            for line in changelogLines:
                lines.insert(i + j, ('* ' + line + '\n').encode("utf-8"))
                j += 1

            lines.insert(i + j, ('\n').encode("utf-8"))
            tagFound = True
            break

    f.seek(0)
    f.writelines(lines)
    f.truncate()
    f.close()

    if tagFound is False:
        print('Changelog not found in README.md')
        sys.exit(2)
    print('--- done updating README.md ----')

    print('--- pushing commit ----')

    call_process(
        [
            'git',
            'add',
            '-A'
        ],
        CORDOVA_DIR
    )
    call_process(
        [
            'git',
            'commit',
            '-m',
            'Updated to v' + version
        ],
        CORDOVA_DIR
    )
    call_process(
        [
            'git',
            'push',
            'origin',
            branch
        ],
        CORDOVA_DIR
    )
    call_process(
        [
            'git',
            'tag',
            version
        ],
        CORDOVA_DIR
    )
    call_process(
        [
            'git',
            'push',
            'origin',
            '--tags'
        ],
        CORDOVA_DIR
    )
    print('--- done pushing commit ----')

    print('--- updating npm ----')

    call_process(
        [
            'npm',
            'publish'
        ],
        CORDOVA_DIR
    )

    print('--- done updating npm ----')


if __name__ == '__main__':
    main(sys.argv[1:])
