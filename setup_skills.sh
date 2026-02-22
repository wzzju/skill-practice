#!/bin/bash -ex
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

if [ -n "$SYSTEM" ]; then
  rm -rf ~/.trae/skills
  mkdir -p ~/.trae/skills
  cp -R "$SCRIPT_DIR/anthropics/skills/skills/"* ~/.trae/skills
  cp -R "$SCRIPT_DIR/superpowers/skills/"* ~/.trae/skills
  cp -R "$SCRIPT_DIR/planning-with-files/skills/"* ~/.trae/skills
  cp -R "$SCRIPT_DIR/obsidian-skills/skills/defuddle" ~/.trae/skills
  cp -R "$SCRIPT_DIR/obsidian-skills/skills/json-canvas" ~/.trae/skills
  cp -R "$SCRIPT_DIR/suggest-git-commit" ~/.trae/skills
fi

if [ -n "$RUST" ]; then
  rm -rf "${RUST}/.trae/skills"
  mkdir -p "${RUST}/.trae/skills"
  cp -R "$SCRIPT_DIR/rust10x" "${RUST}/.trae/skills"
  cp -R "$SCRIPT_DIR/rust-skills/skills/"* "${RUST}/.trae/skills"
  if [ -n "$MAKEPAD" ]; then
    cp -R "$SCRIPT_DIR/makepad-skills/skills/"* "${RUST}/.trae/skills"
  fi
fi
