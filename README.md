# seals  • [![tests](https://github.com/abigger87/seals/actions/workflows/tests.yml/badge.svg)](https://github.com/abigger87/seals/actions/workflows/tests.yml) [![lints](https://github.com/abigger87/seals/actions/workflows/lints.yml/badge.svg)](https://github.com/abigger87/seals/actions/workflows/lints.yml) ![GitHub](https://img.shields.io/github/license/abigger87/seals) ![GitHub package.json version](https://img.shields.io/github/package-json/v/abigger87/seals)

Sealed Commitment Auctions with Overcollateralized Bid Bands.

## Architecture

TODO

## Blueprint

```ml
lib
├─ ds-test — https://github.com/dapphub/ds-test
├─ forge-std — https://github.com/brockelmore/forge-std
├─ solmate — https://github.com/Rari-Capital/solmate
├─ clones-with-immutable-args — https://github.com/wighawag/clones-with-immutable-args
src
├─ tests
│  └─ Seal.t — "Seal Tests"
└─ Seal — "The Seal Coordination Contract"
```

## Development

[seals](https://github.com/abigger87/seals) is built with [Foundry](https://github.com/gaskonst/foundry) but remains backwards compatible with [DappTools](https://dapp.tools/).

Set up your environment by following the instructions outlined in [abigger87/foundry-starter](https://github.com/abigger87/foundry-starter#development).


```bash
# Setup
make setup
```

```bash
# Build #
make build
```

```bash
# Testing #
make test
```

#### Configure Foundry

Using [foundry.toml](./foundry.toml), Foundry is easily configurable.

## Install Seals as a Dependency

To install with [DappTools](https://dapp.tools/), run:
```sh
dapp install abigger87/seals
```

To install with [Foundry](https://github.com/gakonst/foundry), run:
```sh
forge install abigger87/seals
```

To install with [Hardhat](https://hardhat.org/), run:
```sh
npm i -D seals
```

## License

[AGPL-3.0-only](https://github.com/abigger87/seals/blob/master/LICENSE)

# Acknowledgements

- [foundry](https://github.com/gakonst/foundry)
- [solmate](https://github.com/Rari-Capital/solmate)
- [forge-std](https://github.com/brockelmore/forge-std)
- [clones-with-immutable-args](https://github.com/wighawag/clones-with-immutable-args).
- [foundry-toolchain](https://github.com/onbjerg/foundry-toolchain) by [onbjerg](https://github.com/onbjerg).
- [forge-template](https://github.com/FrankieIsLost/forge-template) by [FrankieIsLost](https://github.com/FrankieIsLost).
- [Georgios Konstantopoulos](https://github.com/gakonst) for [forge-template](https://github.com/gakonst/forge-template) resource.

## Disclaimer

_These smart contracts are being provided as is. No guarantee, representation or warranty is being made, express or implied, as to the safety or correctness of the user interface or the smart contracts. They have not been audited and as such there can be no assurance they will work as intended, and users may experience delays, failures, errors, omissions, loss of transmitted information or loss of funds. The creators are not liable for any of the foregoing. Users should proceed with caution and use at their own risk._
