import collections
import contextlib
import hashlib
import os
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
    if dname is None:
        dname = os.path.splitext(fname)[0]

    with zipfile.ZipFile(fname, "r") as fh:
        fh.extractall(dname)

    os.remove(fname)

    return dname


Download = collections.namedtuple("Download", ["url", "hashtype", "hashval"])

urls = [
    Download(
        url="http://nsis.sourceforge.net/mediawiki/images/8/8f/UAC.zip",
        hashtype="sha256",
        hashval="20e3192af5598568887c16d88de59a52c2ce4a26e42c5fb8bee8105dcbbd1760",
    ),
    Download(
        url="http://nsis.sourceforge.net/mediawiki/images/a/a7/UnicodePathTest_1.0.zip",
        hashtype="sha256",
        hashval="8e6d82dd2f6baf7256423d513f12ffd0906853c4d0cd14d41818038e05b33193",
    ),
    Download(
        url="http://nsis.sourceforge.net/mediawiki/images/9/9d/Untgz.zip",
        hashtype="sha256",
        hashval="3c2a088b82b27b6183ea6479d61a6c0ecc54f52e484577b641ca21867bd81a4b",
    ),
]

for each_url in urls:
    each_fname = download(each_url.url)
    each_hashval = checksum(each_url.hashtype, each_fname)
    if each_url.hashval != each_hashval:
        raise ValueError(
            "Checksum mismatch. %s != %s" % (each_url.hashval, each_hashval)
        )
    each_dname = unzip(each_fname)
