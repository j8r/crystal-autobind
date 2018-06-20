# Autobind

[![ISC](https://img.shields.io/badge/License-ISC-blue.svg?style=flat-square)](https://en.wikipedia.org/wiki/ISC_license)

### Automatic C bindings generator for Crystal 

Built from the awesome [clang.cr](https://github.com/ysbaddaden/clang.cr) done by [ysbaddaden](https://github.com/ysbaddaden)

## How to use (recommended)

## Installation

Add this block to your application's shard.yml:

```yaml
dependencies:
  autobind:
    github: j8r/crystal-autobind

scripts:
  postinstall: mkdir -p src/libc && lib/autobind/bin/autobind -I/usr/include errno.h > src/libc/errno.cr
```

This latest command will generate the bindings for `errno` at `src/libc/errno.cr`

## Usage

The newly generated `.cr` bindings can be used to create a documented shard wrapper, that can be then require and used as a shard in your application.

The development headers of the library are required whether the bindings are previously generated or not.

The only caveat is to have `libclang` installed to regenerate the bindings.

The bindings directory can thus be ignored in `.gitignore` to avoid versioning:

```
bin
lib
shard.lock
src/libc
```

## Build

Ensure to have `libclang` installed

Install dependencies:

`shards install`

Build autobind:

`crystal build src/autobind.cr`

## Usage examples

You will need the development headers of your targeted library, usually coming inside the `dev` packages of you distribution.

```sh
./autobind -I/usr/include errno.h > errno.cr

./autobind -I/usr/lib/llvm-6.0/include llvm-c/Core.h --remove-enum-prefix=LLVM --remove-enum-suffix > Core.cr

./autobind -I/usr/lib/llvm-6.0/include clang-c/Index.h --remove-enum-prefix > Index.cr
```

## Reference

- [C interface to Clang](http://clang.llvm.org/doxygen/group__CINDEX.html)

## License

ISC License
