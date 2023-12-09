#!/bin/sh

cd ..
cd envs
git update-index --skip-worktree api.env
git update-index --skip-worktree bff.env
git update-index --skip-worktree identity.env
git update-index --skip-worktree mssql.env
git update-index --skip-worktree seq.env
git update-index --skip-worktree ui.env
cd ..
cd utilities