# AUTO-WOKUAN -- Auto boost bandwidth

## What is wokuan
[wokuan](http://wokuan.bbn.com.cn/) is an (rogue & annoy) software by Beijing Unicom. It has ability of boosting bandwidth to 100Mbps.

## What is auto boost
auto-wokuan can automatically apply bandwidth boost and restore, regarding realtime traffic.
No more official wokuan is required

## Requirements

* basic tools (awk, cut, grep, sed)
* wget or curl
* bmon, with output module ``format'' (bmon -o format)

auto-wokuan is tested on OpenWRT and busybox environment

## Configuration
Configuration is written in the script

* IF: the interface to inspect traffic, only one. Wildcard works
* THRESHOLD_BOOST, COUNT_BOOST: Boost if traffic higher than THRESHOLD_BOOST KB/s and last for COUNT_BOOST*2 s
* THRESHOLD_RESTORE, COUNT_RESTORE: Restore if traffic lower than THRESHOLD_RESTORE KB/s and last for COUNT_RESTORE*2 s
* RESERVE_HOURS: Reserve some hours. Don't boost if our remaining time is lower than that


