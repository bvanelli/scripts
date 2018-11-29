# Installing

For global installations, simply use:

```bash
sudo pip3 install -r requirements.txt
```
If you are into virtualenv and copy-pasting stuff:

```bash
sudo /usr/bin/easy_install3 virtualenv
```

Then:

```
git clone https://github.com/bvanelli/scripts
cd scripts/image-compression
virtualenv -p python3 .
pip3 install -r requirements
```
# Usage

```
usage: compress.py [-h] [--quiet] [-r] [-s SCALE] [-q QUALITY] path

Compress and resize images in bulk.

positional arguments:
  path                  Folders to compress.

optional arguments:
  -h, --help            show this help message and exit
  --quiet               Turns off verbose mode.
  -r, --recursive       Uses recursion in target folder.
  -s SCALE, --scale SCALE
                        Scale of output image (default is 2).
  -q QUALITY, --quality QUALITY
                        Quality of output image from 0 to 100 (default is
                        100).
```

# Example

Compressing the current folder and all child folders:

```bash
./compress.py --recursive --scale 2 --quality 85 .
```

Or for short:

```bash
./compress.py -r -s 2 -q 85 .
```
