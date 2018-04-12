# openwrt-leds-as-notification - Use the status leds of your router for
#                                any action you want
#
# Written in 2018 by Franco Masotti/frnmst <franco.masotti@student.unife.it>
#
# To the extent possible under law, the author(s) have dedicated all 
# copyright and related and neighboring rights to this software to the public 
# domain worldwide. This software is distributed without any warranty.
#
# You should have received a copy of the CC0 Public Domain Dedication along 
# with this software. If not, see 
# <http://creativecommons.org/publicdomain/zero/1.0/>. 

SHELL_NAME="-ash"

raise()
{
    r_error="${1}"
    r_exit_code="${2}"

    printf "%s\n" "${r_error}"
    if [ "$(basename -- "${0}")" = "${SHELL_NAME}" ]; then
        return ${r_exit_code}
    else
        exit ${r_exit_code}
    fi
} 1>&2

assert_param()
{
    param="${1}"
    if [ -z "${param}" ]; then
        raise "missing or wrong parameter" 1
    fi
}

die()
{
    raise "unsupported action or non-exising device" 2
}

led_action()
{
    led_name="${1}"
    led_action="${2}"; shift 2
    parameters="$*"
    { assert_param "${led_name}" && assert_param "${led_action}"; } || return

    led_name=$(eval echo \$"${led_name}")
    led_action=$(eval echo \$"${led_action}")
    { assert_param "${led_name}" && assert_param "${led_action}"; } || return

    led=""${directory}"/"${led_name}""
    echo "${led_action}" > "${led}"/trigger || die

    for param in $parameters; do
        (
            IFS=':'
            i=0
            for k in $param; do
                if [ $i -eq 0 ]; then
                    key=$k
                elif [ $i -eq 1 ]; then
                    value=$k
                else
                    die
                fi
                i=$(($i + 1))
            done
            echo "${value}" > "${led}"/"${key}"
        ) || die
    done
}

