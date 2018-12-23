#!/usr/bin/env python3

import os
import sys
import argparse
import time

from PIL import Image
import filetype


def compressMe(path, file, scale, quality, verbose=False):
    filepath = os.path.join(path, file)
    oldsize = os.stat(filepath).st_size
    picture = Image.open(filepath)
    dim = picture.size
    filename = "miniature_" + file

    # make copy and resize
    picture.copy()
    picture.thumbnail((dim[0] / scale, dim[1] / scale), Image.ANTIALIAS)

    args = {
        'optimize': True,
        'quality': quality
    }
    # add exif if it exists
    if ('exif' in picture.info):
        args['exif'] = picture.info['exif']
    # save image
    picture.save(os.path.join(path, filename), "JPEG", **args)

    # stats for nerds
    newsize = os.stat(os.path.join(path, filename)).st_size
    percent = (oldsize - newsize) / float(oldsize) * 100
    if (verbose):
        print("File {3} compressed from {0} to {1} or {2}%".format(
            oldsize, newsize, percent, file))
    return percent


def traversePath(path, args, recursive):

    dirs = [d for d in os.listdir(path) if os.path.isdir(os.path.join(path, d))]
    files = [f for f in os.listdir(path) if os.path.isfile(os.path.join(path, f))]

    if(recursive):
        for dir in dirs:
            traversePath(os.path.join(path, dir), args, recursive)

    for file in files:
        kind = filetype.guess(os.path.join(path, file))

        if (str.startswith(file, 'miniature_')):
            continue

        if (args.force and (('miniature_' + file) in files)):
            print('Skipping file {}: it was already compressed.'.format(file))
            continue

        if ((kind is not None) and (kind.extension in ('jpg', 'jpeg'))):
            compressMe(path, file, args.scale, int(args.quality), args.quiet)


def main():
    parser = argparse.ArgumentParser(
        description='Compress and resize images in bulk.')
    parser.add_argument(
        '--quiet', help='Turns off verbose mode.', action='store_false')
    parser.add_argument(
        '-f', '--force', help='Force recompression of images.', action='store_false')
    parser.add_argument(
        '-r', '--recursive', help='Uses recursion in target folder.', action='store_true')
    parser.add_argument('-s', '--scale', type=float,
        help='Scale of output image (default is 2).', default=2)
    parser.add_argument(
        '-q', '--quality', help='Quality of output image from 0 to 100 (default is 100).', type=int, default=100)
    parser.add_argument('paths', metavar='path',
        type=str, nargs=1, help='Folders to compress.')
    args = parser.parse_args()

    # finds present working dir
    dir = args.paths[0]

    start = time.time()
    traversePath(dir, args, args.recursive)
    end = time.time()

    print("Done in {} seconds".format(end - start))

if __name__ == "__main__":
    main()
