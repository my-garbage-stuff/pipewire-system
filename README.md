# PipeWire System-wide Daemon Package (Arch Linux)

This package configures PipeWire, WirePlumber, and PipeWire-Pulse to run as a **single system-wide daemon** as the `root` user. This setup is optimized for headless media servers, HTPCs, or multi-user audio environments.

## Expert Configuration & Rationale

This project addresses several non-obvious hurdles required to make PipeWire stable in a root context.

### 1. System-wide Profile Inheritance (`wireplumber-bluetooth.conf`)
We use the WirePlumber 0.5.x `main-systemwide` profile, but with critical modifications.
- **Problem**: WirePlumber's default `main-systemwide` profile (defined in `wireplumber.conf`) inherits from `mixin.systemwide-session`, which **disables** `support.reserve-device` and `monitor.alsa.reserve-device`.
- **Solution**: We explicitly re-enable these in our override:
  ```lua
  wireplumber.profiles = { main-systemwide = { support.reserve-device = required ... } }
  ```
- **Rationale**: Without device reservation, the root PipeWire instance cannot "claim" ALSA hardware through D-Bus, leading to the "Dummy Output" issue.
- **Reference**: [WirePlumber 0.5 Migration Guide](https://pipewire.pages.freedesktop.org/wireplumber/main/daemon/configuration/migration.html)

### 2. D-Bus Policy & Ownership (`org.pipewire.system.conf`)
Root requires explicit permissions to own specific "well-known" names that are normally requested by session users.
- **`org.pulseaudio.Server`**: Required for `pipewire-pulse` to be discoverable by PulseAudio clients.
- **`org.freedesktop.ReserveDevice1`**: Required for ALSA hardware claiming. Reference: [Device Reservation Specification](https://www.freedesktop.org/wiki/Software/PulseAudio/Documentation/Developer/Clients/DeviceReservation/).
- **`org.pipewire.Telephony` & `org.bluez.Telephony1`**: Required for PipeWire's `native` telephony backend to expose its API.
- **`org.bluez.Profile1`**: Necessary for PipeWire to register A2DP and HFP/HSP profiles with BlueZ.

### 3. Bluetooth Telephony Conflict (`bluetooth-dropin.conf`)
- **Problem**: Bluetooth Hands-Free Profile (HFP/HSP) requires a "backend" to handle voice data on the SCO socket. By default, `bluetoothd` (BlueZ) may attempt to handle this internally via a plugin.
- **Solution**: We use a systemd drop-in to start `bluetoothd` with `--noplugin=hfp,sap`.
- **Rationale**: This prevents BlueZ from binding to the RFCOMM/SCO socket, allowing PipeWire's `native` backend to take over. This resolves the `Address already in use` and `RegisterProfile failed` errors.
- **Reference**: [PipeWire Bluetooth Backend Docs](https://gitlab.freedesktop.org/pipewire/pipewire/-/blob/master/spa/plugins/bluez5/README.md)

### 4. Bypassing Seat Monitoring
- **Rationale**: In a root system-wide context, there is no "active user seat" tracked by `logind`. By using the `main-systemwide` profile and setting `monitor.bluez.seat-monitoring = false`, we allow the Bluetooth monitor to activate even when no user is logged into a physical session.

### 5. Runtime Directory & Permissions
- **`XDG_RUNTIME_DIR` Redirect**: Redirected to `/run/pipewire` via systemd units.
- **Permissions**: Mode `0755` is used for `/run/pipewire` and specifically the `/pulse` subdirectory to allow non-root users (like GDM or your local user) to "traverse" the directory and connect to the socket.

## Installation & AUR Submission

1. **Build**: `makepkg -f`
2. **Verify**: `namcap PKGBUILD` and `namcap *.pkg.tar.zst`
3. **Generate Metadata**: `makepkg --printsrcinfo > .SRCINFO`
4. **Install Locally**: `sudo pacman -U pipewire-system-*.pkg.tar.zst`
5. **AUR Submission**: 
   - Create a new repository on AUR.
   - Add the AUR remote: `git remote add aur ssh://aur@aur.archlinux.org/pipewire-system.git`
   - Push: `git push aur master`

6. **Permission Setup**: Ensure your user is a member of the `audio` group to access the sockets:
   ```bash
   sudo usermod -aG audio $USER
   ```
7. **Clean Restart**:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl reload dbus
   sudo systemctl restart bluetooth
   sudo systemctl restart wireplumber pipewire-pulse pipewire
   ```

