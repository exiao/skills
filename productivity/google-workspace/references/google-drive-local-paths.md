# Google Drive Local Paths (macOS)

Google Drive for Desktop mounts at:
```
~/Library/CloudStorage/GoogleDrive-<email>/My Drive/
```

On this machine (USER_EMAIL):
```
~/Library/CloudStorage/GoogleDrive-USER_EMAIL/My Drive/
```

Subfolders:
- `My Drive/` — personal files
- `Other computers/` — synced computer backups
- `Shared drives/` — team drives

## Important

`~/Documents/` is a LOCAL-ONLY folder on this machine. It does NOT sync to Google Drive.
If the user asks for something to be "on Google Drive" or "synced", always use the CloudStorage path above.

## Checking if Drive is syncing

```bash
ls ~/Library/CloudStorage/
# Should show: GoogleDrive-USER_EMAIL
```
