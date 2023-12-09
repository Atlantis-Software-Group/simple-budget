#!/bin/sh

cd envs
git update-index --no-skip-worktree api.env
git update-index --no-skip-worktree bff.env
git update-index --no-skip-worktree identity.env
git update-index --no-skip-worktree mssql.env
git update-index --no-skip-worktree seq.env
git update-index --no-skip-worktree ui.env
cd ..