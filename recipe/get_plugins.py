import collections
import contextlib
import hashlib
import os
import subprocess
import shutil
import zipfile

try:
    from urllib.request import (
        urlopen,
        urlretrieve,
    )
except ImportError:
    from urllib2 import urlopen
    from urllib import urlretrieve


def read(fh, block_sz=8192):
    while True:
        buf = fh.read(block_sz)
        if not buf:
            break

        yield buf


def download(url, fname=None):
    if fname is None:
        fname = url.rsplit("/", 1)[1]
        fname = os.path.join(os.getcwd(), fname)

    with contextlib.closing(urlopen(url)) as rq:
        with open(fname, "wb") as fh:
            for buf in read(rq):
                fh.write(buf)

    return fname


def checksum(htname, fname):
    h = getattr(hashlib, htname)()

    with open(fname, "rb") as fh:
        for buf in read(fh):
            h.update(buf)

    return h.hexdigest()


def unzip(fname, dname=None):
    src_dname, ext = os.path.splitext(fname)
    if dname is None:
        dname = src_dname

    if ext == ".7z":
        subprocess.check_call(["7za", "x", "-aos", "-o" + dname, "--", fname])
    else:
        with zipfile.ZipFile(fname, "r") as fh:
            common_prefix_parts = os.path.commonprefix(fh.namelist()).split("/")
            if len(common_prefix_parts) > 1:
                # If everything is inside a single top-most folder (e.g., like in GitHub archives),
                # skip recreating that part of the hierarchy.
                root_folder = common_prefix_parts[0] + "/"
                members = []
                for zip_info in fh.infolist():
                    new_file_name = zip_info.filename[len(root_folder):]
                    if new_file_name:
                        zip_info.filename = new_file_name
                        members.append(zip_info)
                fh.extractall(dname, members)
            else:
                fh.extractall(dname)

    os.remove(fname)

    return dname


def check_hash(src, fname):
    hashval = checksum(src.hashtype, fname)
    if src.hashval != hashval:
        raise ValueError(
            "Checksum mismatch in file '%s' %s != %s" % (fname, src.hashval, hashval)
        )


Download = collections.namedtuple("Download", ["url", "hashtype", "hashval", "dname"])

urls = [
    Download(
        url="http://code.kliu.org/misc/elevate/elevate-1.3.0-redist.7z",
        hashtype="sha256",
        hashval="b1b3f070353a0eadee2cea3a575049d10df9763ff24e39313da4cec9455382e1",
        dname="elevate"
    ),
    Download(
        url="http://nsis.sourceforge.net/mediawiki/images/7/79/UAC_v0.2.2d.zip",
        hashtype="sha256",
        hashval="9e64d93185e468fb873925db887f637778d926b864b5ff85600b7c9fce92660d",
        dname="UAC",
    ),
    Download(
        url="https://github.com/mingwandroid/nsis-untgz/archive/5c814c5f2c8a9a14e3a6ddd3e594fcc76db5b86a.zip",
        hashtype="sha256",
        hashval="ae68c41493abbb8800640acdf67a06c63bcceaaf21b539c50c348a20dc4b2803",
        dname="untgz",
    ),
    Download(
        url="https://github.com/mingwandroid/nsis-UnicodePathTest/archive/fa74caef553883f1820049d89e169aff57551796.zip",
        hashtype="sha256",
        hashval="1a4dc09f0fbb7d6be88835c50a7c95dbd37470c65e29cf676b14e3ad9c4d7494",
        dname="UnicodePathTest",
    ),
]

for each_url in urls:
    each_fname = download(each_url.url)
    check_hash(each_url, each_fname)
    each_dname = unzip(each_fname, each_url.dname)

# check if we are using the same files as in repo.continuum.io/pkgs/free/
HashedFile = collections.namedtuple("File", ["fname", "hashtype", "hashval"])
files = [
    HashedFile(
        fname=os.path.join("elevate", "bin.x86-32", "elevate.exe"),
        hashtype="md5", hashval="7178d69ded53b7683dd52cd1ca0a20ff",
    ),
    HashedFile(
        fname=os.path.join("UAC", "U", "UAC.dll"),
        hashtype="md5", hashval="c71733d8ef33afcc99050ba2b0c56614",
    ),
    HashedFile(
        fname=os.path.join("UnicodePathTest", "Plugin", "UnicodePathTest.dll"),
        hashtype="md5", hashval="be71dfd1419eb91778cfde6bb8a44320",
    ),
    HashedFile(
        fname=os.path.join("untgz", "Plugins", "x86-unicode", "untgz.dll"),
        hashtype="md5", hashval="832c58ba1567ab9dec35e115f0b50e8f",
    ),
]

for hashed_file in files:
    check_hash(hashed_file, hashed_file.fname)
