#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$DIR/build_var.sh"
bash "$DIR/build_woff2.sh"
bash "$DIR/build_static.sh"