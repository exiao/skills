# Multiple GitHub Accounts via SSH Host Aliases

Tested workflow for adding a second (or third) GitHub account to the same machine using SSH key pairs and host aliases.

## Steps

1. **Generate a dedicated SSH key per account:**
```bash
ssh-keygen -t ed25519 -C "account-email@example.com" -f ~/.ssh/id_ed25519_<alias> -N ""
```

2. **Add key to SSH agent:**
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519_<alias>
```

3. **Copy public key and add to GitHub:**
```bash
cat ~/.ssh/id_ed25519_<alias>.pub
```
Go to GitHub > Settings > SSH and GPG Keys > New SSH Key.
- Key type: **Authentication Key** (not Signing Key)
- Title: any label (e.g. "Eric's Mac", machine name)
- Paste the public key

4. **Add host alias to ~/.ssh/config:**
```
Host github-<alias>
  HostName github.com
  IdentityFile ~/.ssh/id_ed25519_<alias>
```
Keep the default `Host github.com` entry pointing at your primary key.

5. **Test connection:**
```bash
ssh -T git@github-<alias>
# Expected: "Hi <username>! You've successfully authenticated..."
```

6. **Clone repos using the alias:**
```bash
git clone git@github-<alias>:<org>/<repo>.git
```

7. **Set per-repo identity so commits show the right author:**
```bash
cd repo
git config user.name "Name for this account"
git config user.email "account-email@example.com"
```

## Pitfalls

- **~/.ssh/config is a protected file.** The agent may not be able to write it directly. If write is denied, output the config block and ask the user to paste it, or use `cat >>` append which sometimes passes security checks.
- **`gh` CLI doesn't support multiple accounts natively.** Use `gh auth login` / `gh auth switch` to swap, but SSH host aliases are cleaner for git operations.
- **GitHub SSH key type dropdown:** always pick "Authentication Key." Signing keys are for commit signature verification, not cloning/pushing.
- **SSH agent persistence:** keys added with `ssh-add` don't survive reboot. Add `AddKeysToAgent yes` to ~/.ssh/config or add `ssh-add` to shell profile for persistence.
