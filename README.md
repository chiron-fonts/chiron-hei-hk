# Chiron Hei HK: Source Files

Source files of Chiron Hei HK.

This branch reflects the ongoing effort of separating the font building process from the authoring tool. The goal is
that ultimately all files in the `release` branch will be built from the source files in this branch. Currently only
building font files from sources are supported.

**NOTE: This is a work in progress. The font files built from this branch may not be identical to the ones in the `release` branch.**

## Building

It is recommended to use build the font files with Docker. First, prepare the builder image.

```bash
docker build -t chiron-hei-builder:latest .
```

Then, run the builder with the current directory mounted to `/source` in the container. The font files will be output to
the `build` directory, so you should mount the directory where you want the font files to be written to `/build`.

```bash 
docker run --rm -it -v $(pwd):/source -v /path/to/build/output:/build chiron-hei-builder
```

Replace `/path/to/build/output`
with the directory where you want the binary font files to be written to. On Windows, replace `$(pwd)` with `%cd%` (in Command Prompt) or `${PWD}` (in PowerShell).

To build the Variable OTF for Google Fonts, run the following command:

```bash 
docker run --rm -it -v $(pwd):/source --entrypoint /source/bin/build_var_gf.sh chiron-hei-builder
```

