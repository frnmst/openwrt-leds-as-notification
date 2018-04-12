# openwrt-leds-as-notification

Use the status leds of your router for any action you want

![DG834GV4 blinking leds](dg834gv4_leds.gif)

## How does this work

The `led_action` function uses the Linux kernel LED API which consists
in writable userspace files. `led_action` simply writes the appropriate
values in those files. This avoids verbosity and simplifies maintenance.

## Add your own profile

Have a look at the `/sys/class/leds` directory of your system and create a
new file based on `./profiles/dg834gv4.profile`.

## Synopsis

led_action $led_name $action $key0:$value0 $key1:$value1 $keyn-1:$valuen-1

## Examples

### Testing directly from the shell

```
. ./profiles/dg834gv4.profile
. ./led.sh

led_action adsl on
led_action power_red blink delay_on:100 delay_off:1000
led_action adsl off
led_action power_red off
```

### Usage through a script

In these examples this script is called `do_ping.sh`.

```shell
#!/bin/ash

. ./profiles/dg834gv4.profile
. ./led.sh

clear_leds()
{
    led_action power_green off
    led_action power_red off
    led_action adsl off
    led_action internet off
}

main()
{
    clear_leds
    while true; do
        # Do your stuff here. For example you could check for
        # internet and DNS functionality on two different leds.
        ping -c 1 8.8.8.8 || led_action adsl blink delay_on:1000 delay_off:20
        ping -c 1 google.com || led_action internet blink delay_on:10 delay_off:10

        # Set a polling timeout.
        sleep 600

        # You are responsible to clear the leds once the timeout ends.
        clear_leds
    done
}

main
```

## OpenWrt stuff

### Start service at boot with routing and DNS settings

This works in case you cannot install packages on your OpenWrt system (this
is my case, due to low memory). In this case touch a new file called
`/etc/init.d/startup` with the following content. This will create a
system service that will run at startup.

```shell
#!/bin/sh /etc/rc.common

START=99
STOP=99

start()
{
        router_address="192.168.1.1"
        DNS_server_address="8.8.8.8"
        sleep 60
        route add default gateway $router_address br-lan
        echo "nameserver $DNS_server_address" > /etc/resolv.conf
        cd /root/leds
        /root/leds/do_ping.sh &

}

stop()
{
        killall do_ping.sh
}
```

Then:

    chmod +x /etc/init.d/startup
    /etc/init.d/startup enable
    /etc/init.d/startup enabled && echo "OK" || echo "ERROR"

## Bugs

- These script have been tested with the OpenWrt distribution `ATTITUDE
  ADJUSTMENT (12.09, r36088)`, kernel version `Linux OpenWrt 3.3.8 #1 Sat
  Mar 23 18:09:20 UTC 2013 mips GNU/Linux` on a [Netgear DG834GV4
  modem/router](https://wikidevi.com/wiki/Netgear_DG834Gv4). Results may
  vary.
- Make sure to change the `SHELL_NAME` variable in the `./led.sh` file to
  the appropriate value (`echo $0` in the shell).

## Resources

### Leds

https://openwrt.org/docs/guide-user/base-system/led_configuration
https://www.kernel.org/doc/Documentation/leds/leds-class.txt

### Other

https://wiki.openwrt.org/doc/techref/initscripts

## License

CC0.
