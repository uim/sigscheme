# NEWS

## 0.9.5 - 2026-03-28

### Improvements

  * Added `expt`
    * GH-26
    * Patch by jpellegrini

  * Added `gcd` and `lcm`
    * GH-25
    * Patch by jpellegrini

  * Added support for system BDWGC
    * BDWGC 8.3.0 will have the feature that is provided by
      libgcroots. We'll deprecate libgcroots and migrate to BDWGC
      eventually.
    * GH-29
    * Patch by Ivan Maidanski

### Thanks

  * jpellegrini
  * Ivan Maidanski

## 0.9.4 - 2025-11-29

### Fixes

  * Fixed a bug that loaded symbol may have garbage at the end.
  * Fixed a bug that loaded symbol may have garbage filename.
    * GH-20
    * GH-21
    * Patch by mkotha

### Thanks

  * mkotha

## 0.9.3 - 2025-05-06

### Improvements

  * Cleaned up internal function call dispatch implementation.

## 0.9.2 - 2025-05-04

### Improvements

  * Added support for C23.
    * Reported by SteelDynamite

### Thanks

  * SteelDynamite
