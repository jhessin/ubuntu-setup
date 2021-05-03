#!/usr/bin/env zsh

pluck export | sed '/^block/d' > pluck.settings
