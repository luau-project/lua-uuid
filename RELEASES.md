# Releases

## Overview

This document provides guidance to publish a new release for `lua-uuid`.

## Steps before pushing a new tag

1. Create a feature branch for the changes;

2. Bump the version on `LUA_UUID_VERSION` macro defined in the file [src/lua-uuid.h](./src/lua-uuid.h);

> [!IMPORTANT]
> 
> The version assigned to `LUA_UUID_VERSION` must match the following regex pattern: `^[0-9]+(\.[0-9]+)+$`. Thus, `0.3` is allowed, `0.3.1` is also allowed, but a single number `1` is **NOT** allowed (*unless this pattern is fixed on every spot at [./.github/workflows/publish.yml](./.github/workflows/publish.yml)*).

3. Within the makefiles for Unix (`Makefile.unix`) and Windows (`Makefile.win`), change `PKG_VERSION` variable to the same value defined on `LUA_UUID_VERSION` macro defined in the file [src/lua-uuid.h](./src/lua-uuid.h);

4. On Unix, in the project directory, run

    ```bash
    make -f Makefile.unix create-rockspecs
    ```

    to generate new rockspecs from the template ([rockspecs/rockspec.in](./rockspecs/rockspec.in));

5. Make sure the created rockspec (**CHANGE** `rockspecs/lua-uuid-0.2.0-1.rockspec` below to the new name) prints the expected output running the following script from the terminal or command line:

    ```bash
    lua -e "dofile(arg[0]); print(); print('package  :', package); print('version  :', version); print('branch   :', source.branch); print('tag      :', source.tag); print('url      :', source.url); print('homepage :', description.homepage); print();" -- rockspecs/lua-uuid-0.2.0-1.rockspec
    ```

6. Make sure `luarocks make` is able to build the project correctly for the fresh rockspec;

7. Commit the changes and push them to the remote repository;

## Tagging a new release

After all the previous steps were performed:

1. Create a new annotated tag (e.g.: `git tag -a "v0.2.0" -m "Release v0.2.0"`) changing `0.2.0` in the previous command to contain the exact **SAME VERSION** on `LUA_UUID_VERSION` macro defined in the file [src/lua-uuid.h](./src/lua-uuid.h);

2. Push the new tag to the remote repository (e.g.: `git push origin v0.2.0`);

## Publish to LuaRocks and GitHub Releases

Once a new tag was released, select the `Publish` action on GitHub Web to trigger it manually:

1. In the UI, select the latest tag pushed in the previous step;
2. Hit the button to run the `Publish` action using the chosen tag.
