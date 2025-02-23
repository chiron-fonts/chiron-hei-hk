# Chiron Hei HK: Source Files

Source files of Chiron Hei HK.

This branch reflects the ongoing progress of separating the font building process from the authoring tool. The hope is
that ultimately all files in the `release` branch will be built from the source files in this branch. Currently only
building font files from sources are supported.

## Building

The easiest way to build the font files is through Docker. First, build the Docker image.

```bash
docker build -t chiron-hei-builder:latest .
```

Then, run the builder with the current directory mounted to `/source` in the container. The font files will be output to
the `build` directory.

```bash 
docker run --rm -it -v $(pwd):/source -v /path/to/build/output:/build chiron-hei-builder
```

Replace `$(pwd)` with `%cd%` on Windows, and replace `/path/to/build/output`
with the directory where you want the binary font files to be written to. 
