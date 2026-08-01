#!/usr/bin/env bash
# The migration-state fact travels with the plugin: a workspace cannot be asked to install the
# thing that tells it whether it was migrated.
exec python3 "$(cd "$(dirname "$0")" && pwd)/migration-state.py"
