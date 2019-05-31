#!/usr/bin/env bash
sudo reflector --country China --sort rate --save /etc/pacman.d/mirrorlist
