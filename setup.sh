#!/bin/bash
# Uso: ./setup.sh SEU_TEAM_ID [com.seudominio.carmirror]
# Gera o projeto Xcode já com seu time e bundle ID, e abre o Xcode.
set -e
TEAM="$1"; BID="${2:-com.shaks.carmirror}"
if [ -z "$TEAM" ]; then echo "Uso: ./setup.sh SEU_TEAM_ID [bundle.id]  (Team ID: developer.apple.com > Membership)"; exit 1; fi
command -v xcodegen >/dev/null || brew install xcodegen
sed -i '' "s/DEVELOPMENT_TEAM: \"\"/DEVELOPMENT_TEAM: \"$TEAM\"/" project.yml
sed -i '' "s/com\.shaks\.carmirror/$BID/g" project.yml CarMirror/ContentView.swift
xcodegen generate
open CarMirror.xcodeproj
echo "Pronto. No Xcode: selecione seu iPhone, aperte Run (▶)."
