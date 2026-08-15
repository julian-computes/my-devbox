---
name: tshark
description: Inspect packet captures or collect narrowly scoped network traffic with TShark.
---

# TShark

Use `tshark` for network troubleshooting, incident analysis, and protocol
inspection. Prefer an existing PCAP/PCAPNG file. Treat packet data as sensitive.
Keep live captures narrowly scoped, bounded, and stored securely.

## Start with an existing capture

```bash
# Packet summaries. `-n` prevents additional name-resolution traffic.
tshark -n -r capture.pcapng

# Decode a selected packet in detail; `-x` also shows packet bytes.
tshark -n -r capture.pcapng -Y 'frame.number == 42' -V -x

# Read only the first 100 packets while troubleshooting a large capture.
tshark -n -r capture.pcapng -c 100
```

`-r` reads a capture file (`-` reads standard input). `-Y` is a Wireshark
display filter: it filters decoded output and can also select packets written
while reading a file. Quote filters containing spaces or shell metacharacters.
Use `-n` unless name resolution is specifically needed.

## Filter correctly

Capture filters (`-f`) use libpcap/BPF syntax and discard unmatched traffic
before dissection. They are efficient for live capture. Display filters (`-Y`)
use Wireshark syntax and operate on decoded fields; use them
when reading a PCAP or narrowing displayed results.

```bash
# BPF capture-filter examples.
-f 'host 192.0.2.10 and tcp port 443'
-f 'udp port 53'
-f 'icmp or icmp6'

# Wireshark display-filter examples.
-Y 'dns.flags.response == 0'
-Y 'http.request'
-Y 'tls.handshake'
-Y 'tcp.flags.reset == 1'
-Y 'ip.addr == 192.0.2.10 && tcp.port == 443'
```

Do not substitute `-Y` syntax into `-f`: the syntaxes are different. For
single-pass reading, use `-Y`. `-R` is a read filter for the first pass of
`-2` two-pass analysis.

## Extract fields and export decoded output

```bash
# Tabular, script-friendly output.
tshark -n -r capture.pcapng -Y http.request -T fields \
  -E header=y -E separator=$'\t' -E quote=d -E occurrence=f \
  -e frame.time_epoch -e ip.src -e ip.dst -e http.host -e http.request.uri

# JSON representation of matching packets.
tshark -n -r capture.pcapng -Y dns -T json > dns.json

# Decode only named protocol trees in verbose text output.
tshark -n -r capture.pcapng -Y tls -V -O tls,tcp,ip
```

`-T fields` prints fields named by `-e`; `-E` controls headings, separators,
quoting, and repeated-field handling. `-V` prints packet-detail trees, `-O`
limits those trees to listed protocols, and `-x` appends raw hex/ASCII bytes.
Avoid `-x` or broad `-V` output unless necessary because it can expose payloads.

## Summaries, flows, and diagnostics

```bash
# Protocol hierarchy and endpoint/conversation summaries.
tshark -n -r capture.pcapng -q -z io,phs
tshark -n -r capture.pcapng -q -z endpoints,ip
tshark -n -r capture.pcapng -q -z conv,tcp

# Expert diagnostics and time-series packet counts.
tshark -n -r capture.pcapng -q -z expert
tshark -n -r capture.pcapng -q -z 'io,stat,1,COUNT(frame)'

# List all supported statistics on this installation.
tshark -z help
```

`-q` suppresses ordinary per-packet output so statistics are easier to read.
Most `-z` reports accept an optional display filter of their own; a main `-Y`
does not generally constrain statistics.

## Live capture

```bash
# Identify interfaces and their available link-layer types.
tshark -D
tshark -i eth0 -L

# Bounded, narrowly filtered sample. Use sudo only if capture permissions
# have not been delegated through an approved capture setup.
sudo tshark -i eth0 -n -f 'udp port 53' -a duration:30 \
  -w /path/to/dns-sample.pcapng

# Stop after a packet count instead of a duration; avoid promiscuous mode.
sudo tshark -i eth0 -n -p -f 'icmp or icmp6' -c 50 \
  -w /path/to/icmp-sample.pcapng
```

`-i` selects an interface from `-D`; otherwise TShark chooses a default.
`-a duration:NUM` and `-c NUM` bound collection. `-w` writes raw packet data
(PCAPNG by default), not text; add `-P` only when packet summaries must also
be printed. `-p` requests no promiscuous mode, but does not guarantee that no
other traffic is visible. Capture permissions may require `sudo` or an
approved `CAP_NET_RAW`/`CAP_NET_ADMIN` setup.

For longer collection, rotate files rather than growing one indefinitely:

```bash
sudo tshark -i eth0 -f 'tcp port 443' \
  -b duration:60 -b files:5 -a duration:300 \
  -w /path/to/https.pcapng
```

## Protocol decoding and output files

```bash
# Decode traffic on a nonstandard port as HTTP while reading a PCAP.
tshark -n -r capture.pcapng -d tcp.port==8888,http -Y http

# List supported output capture formats; pcapng is the default.
tshark -F
```

Use `-d layer_type==selector,protocol` only when the protocol and port are
known. Do not use `-w` to create a text report; redirect decoded standard
output instead.

## Handling

Record the interface, filters, timestamps, purpose, and destination for each
live capture. Store PCAPs with restricted access; remove temporary captures
when no longer needed. Do not disclose credentials, session material, or
personal data found in packet contents.
