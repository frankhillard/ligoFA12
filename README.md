# FA1.2 in cameligo
Implementation of a FA1.2 library (TZIP-7) in Cameligo

This implementation follows the TZIP-7 standard
<https://gitlab.com/marigold/tzip/-/blob/master/proposals/tzip-7/tzip-7.md>


## How to use this library

### Install

Install the library with ligo CLI (with docker)
```
ligo install ligo_fa1.2
```

This command will add a dependency in a package.json file.

Here is an example of the resulting package.json file.
```
{ "dependencies": { "ligo_fa1.2": "^1.0.0" } }
```

### Example

The test directory contains a basic example of asset using this library : `asset.instance.mligo`

Anyone can start from this basic example and enhanced it with `Mint`, `Burn`, `Pause` entrypoints !


## How to play with this repository

### Compiling

To produce the Michelson (TZ file) from Cameligo source code
```
make compile
```

### Tests

To launch tests
```
make test
```

### Publishing to Ligolang

To publish this repository on https://packages.ligolang.org/packages
(For members only)
```
make login
make publish
```
