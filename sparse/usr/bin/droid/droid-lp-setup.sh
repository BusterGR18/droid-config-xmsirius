#!/bin/sh
# Create dm-linear devices for Android dynamic partitions (liblp metadata),
# retrofit layout (metadata at start of first block device, slot 0).
# POSIX sh + busybox-friendly: needs dd, od, tr, dmsetup.
# DRYRUN=1 prints the dmsetup tables instead of creating anything.
# LP_SRC=<file> reads metadata from a file (testing).
FIRST=${FIRST:-system}          # partition name holding the metadata
set -u

rd() { # rd <file> <offset> <nbytes>  -> little-endian unsigned integer
    v=0; m=1
    for b in $(dd if="$1" bs=1 skip="$2" count="$3" 2>/dev/null | od -An -v -t u1); do
        v=$((v + b * m)); m=$((m * 256))
    done
    echo "$v"
}
rdname() { dd if="$1" bs=1 skip="$2" count=36 2>/dev/null | tr -d '\000'; }

devfor() { # partition name -> block device node
    if [ -n "${DRYRUN:-}" ]; then echo "BLK:$1"; return; fi
    for u in /sys/class/block/*/uevent; do
        if grep -qx "PARTNAME=$1" "$u" 2>/dev/null; then
            echo "/dev/$(basename "$(dirname "$u")")"; return
        fi
    done
    return 1
}

SRC=${LP_SRC:-$(devfor "$FIRST")} || { echo "no device for $FIRST" >&2; exit 1; }
[ "$(rd "$SRC" 4096 4)" = $((0x616c4467)) ] || { echo "no LP geometry in $SRC" >&2; exit 1; }  # 'gDla'

maxsz=$(rd "$SRC" 4136 4)
hdr=12288                        # 4096 reserved + 2 * 4096 geometry copies (slot 0)
[ "$(rd "$SRC" $hdr 4)" = $((0x414c5030)) ] || { echo "bad LP header" >&2; exit 1; }   # '0PLA'
hsz=$(rd "$SRC" $((hdr+8)) 4)
tsz=$(rd "$SRC" $((hdr+44)) 4)
T=$((hdr + hsz))                 # table area; descriptor offsets are relative to it
p=$((hdr + 80))
po=$(rd "$SRC" $p 4);        pn=$(rd "$SRC" $((p+4)) 4);   pe=$(rd "$SRC" $((p+8)) 4)
eo=$(rd "$SRC" $((p+12)) 4); ee=$(rd "$SRC" $((p+20)) 4)
bo=$(rd "$SRC" $((p+36)) 4); bn=$(rd "$SRC" $((p+40)) 4);  be=$(rd "$SRC" $((p+44)) 4)

# block device index -> node
i=0; while [ $i -lt "$bn" ]; do
    n=$(rdname "$SRC" $((T + bo + i*be + 24)))
    eval "BD$i=\$(devfor \"$n\")" || { echo "missing partition $n" >&2; exit 1; }
    i=$((i+1))
done

i=0; while [ $i -lt "$pn" ]; do
    b=$((T + po + i*pe))
    name=$(rdname "$SRC" $b)
    fe=$(rd "$SRC" $((b+40)) 4); ne=$(rd "$SRC" $((b+44)) 4)
    i=$((i+1))
    [ "$ne" -gt 0 ] || continue
    [ -e "/dev/mapper/$name" ] && [ -z "${DRYRUN:-}" ] && continue
    table=""; off=0; k=0
    while [ $k -lt "$ne" ]; do
        e=$((T + eo + (fe+k)*ee))
        ns=$(rd "$SRC" $e 8); tt=$(rd "$SRC" $((e+8)) 4)
        td=$(rd "$SRC" $((e+12)) 8); ts=$(rd "$SRC" $((e+20)) 4)
        [ "$tt" = 0 ] || { echo "unsupported extent type $tt in $name" >&2; exit 1; }
        eval "dev=\$BD$ts"
        table="$table$off $ns linear $dev $td
"
        off=$((off+ns)); k=$((k+1))
    done
    if [ -n "${DRYRUN:-}" ]; then echo "[$name]"; printf '%s' "$table"
    else printf '%s' "$table" | dmsetup create --readonly "$name" || exit 1
    fi
done
