#!/usr/bin/env bash

# generate from csv
fvm dart run arb_generator

# generate localization delegates
fvm flutter gen-l10n
