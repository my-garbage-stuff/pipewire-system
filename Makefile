build:
	: do nothing
install:
	# Install environment variables profile script
	install -Dm644 pipewire.sh "$(DESTDIR)/etc/profile.d/pipewire.sh"
	# Install D-Bus policy
	install -Dm644 org.pipewire.system.conf "$(DESTDIR)/usr/share/dbus-1/system.d/org.pipewire.system.conf"
	# Install WirePlumber Bluetooth config
	install -Dm644 wireplumber-bluetooth.conf "$(DESTDIR)/etc/wireplumber/wireplumber.conf.d/11-bluetooth.conf"
	# Install bluetoothd drop-in to avoid HFP conflicts
	install -Dm644 bluetooth-dropin.conf "$(DESTDIR)/etc/systemd/system/bluetooth.service.d/pipewire-system.conf"
	# Install openrc services
	install -Dm755 pipewire.initd "$(DESTDIR)/etc/init.d/pipewire"
	install -Dm755 pipewire-pulse.initd "$(DESTDIR)/etc/init.d/pipewire-pulse"
	install -Dm755 wireplumber.initd "$(DESTDIR)/etc/init.d/wireplumber"

