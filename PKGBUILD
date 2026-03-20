# Maintainer: Iddo
pkgname=pipewire-system
pkgver=1.0.0
pkgrel=1
pkgdesc="Runs PipeWire as a system-wide root daemon, provides PulseAudio sockets, and disables user units"
arch=('any')
url="https://github.com/iddo/pipewire-system"
license=('MIT')
depends=('pipewire' 'pipewire-pulse' 'wireplumber' 'bluez' 'dbus' 'bluez-utils')
optdepends=('pipewire-libcamera: for camera support and cleaner logs')
provides=('pipewire-system')
backup=('etc/profile.d/pipewire.sh'
        'etc/wireplumber/wireplumber.conf.d/11-bluetooth.conf'
        'etc/systemd/system/bluetooth.service.d/pipewire-system.conf')
source=("pipewire.service"
        "pipewire.socket"
        "pipewire-pulse.service"
        "pipewire-pulse.socket"
        "wireplumber.service"
        "pipewire.sh"
        "pipewire-tmpfiles.conf"
        "org.pipewire.system.conf"
        "wireplumber-bluetooth.conf"
        "bluetooth-dropin.conf")
sha256sums=('a5944aa0a5aa77c4b91004c4c0ed51d06f1f716be8f43dff6d4e9ec3200d1991'
            '36c64c0390a07b3732979f57de6178983a04b2a3c7c83dbb70ec222b261756bc'
            'f661fcd1056ca8343a6705a821424ddd42174c316a0e7b71c81bce19eb84adf7'
            'fcd0878cda2e7e64486da5296cc73c860a2083d4823dafbd328541504232c46d'
            '1e87170cba03738c8b56a66c5c73191ecc16db49cc66cd4a6f87f17283aa8953'
            '84811a115451b8edb5a53186347959b41e9fe764d5d6db19e4c7791ed3831d1a'
            'e344232b4665c273b2713bd38d90ef7f1c7bf69cee36a2fd616d790af6f63c57'
            '286212e37d074e0cea3e9f8bdfc4a7d4844d63b6ddd54c9d3d636d06984df576'
            'cde3a722217d072fc0ecce65b0344847757459a1c711380b09e300d37bab1e52'
            '9a9f89ddcfa32576b53e6256fc35cb311ece122317c8635ae689556af647b214')

package() {
    # Install systemd system units
    install -Dm644 pipewire.service "$pkgdir/usr/lib/systemd/system/pipewire.service"
    install -Dm644 pipewire.socket "$pkgdir/usr/lib/systemd/system/pipewire.socket"
    install -Dm644 pipewire-pulse.service "$pkgdir/usr/lib/systemd/system/pipewire-pulse.service"
    install -Dm644 pipewire-pulse.socket "$pkgdir/usr/lib/systemd/system/pipewire-pulse.socket"
    install -Dm644 wireplumber.service "$pkgdir/usr/lib/systemd/system/wireplumber.service"

    # Install environment variables profile script
    install -Dm644 pipewire.sh "$pkgdir/etc/profile.d/pipewire.sh"

    # Install tmpfiles.d conf for /run/pipewire directory
    install -Dm644 pipewire-tmpfiles.conf "$pkgdir/usr/lib/tmpfiles.d/pipewire.conf"

    # Install D-Bus policy
    install -Dm644 org.pipewire.system.conf "$pkgdir/usr/share/dbus-1/system.d/org.pipewire.system.conf"

    # Install WirePlumber Bluetooth config
    install -Dm644 wireplumber-bluetooth.conf "$pkgdir/etc/wireplumber/wireplumber.conf.d/11-bluetooth.conf"

    # Install bluetoothd drop-in to avoid HFP conflicts
    install -Dm644 bluetooth-dropin.conf "$pkgdir/etc/systemd/system/bluetooth.service.d/pipewire-system.conf"

    # Disable user units by masking them in /etc/systemd/user
    install -d "$pkgdir/etc/systemd/user/"
    ln -sf /dev/null "$pkgdir/etc/systemd/user/pipewire.service"
    ln -sf /dev/null "$pkgdir/etc/systemd/user/pipewire.socket"
    ln -sf /dev/null "$pkgdir/etc/systemd/user/pipewire-pulse.service"
    ln -sf /dev/null "$pkgdir/etc/systemd/user/pipewire-pulse.socket"
    ln -sf /dev/null "$pkgdir/etc/systemd/user/wireplumber.service"
}
