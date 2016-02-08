# ums-cpufreq
cpufreq wrapper for Universal Media Server

## Overview
ums-cpufreq wraps the default encoders bundled in UMS with a script that changes the default CPU frequency from an energy-efficient ondemand governor to performance. conservative and ondemand dynamically up the frequency, but at least on my transcoding machine, the sample/adjustment rate is insufficient to avoid frame lag. 

UMS sends a SIGALRM (14) to its transcoding process. This signals the wrapper script to exit, which must communicate the signal too to the actual bin (ffmpeg for example). The bin operates in a subshell so the governor may be reset once it finishes. Otherwise the governor is never reset back to ondemand from performance. 

## Configuring UMS
In a new directory, **outside your PATH**, symlink ffmpeg, mencoder, mplayer, and tsMuxeR to wrapper.sh, e.g. in ~/.config/UMS/wrappers:

    ln -s wrapper.sh ffmpeg
    ln -s wrapper.sh mplayer
    ln -s wrapper.sh mencoder
    ln -s wrapper.sh tsMuxeR

Edit ~/.config/UMS/UMS.conf to add the custom wrapper paths:

    mencoder_path = /home/ums/.config/UMS/wrappers/mencoder
    ffmpeg_path = /home/ums/.config/UMS/wrappers/ffmpeg
    mplayer_path = /home/ums/.config/UMS/wrappers/mplayer
    tsmuxer_path = /home/ums/.config/UMS/wrappers/tsMuxeR

Expand ~ to the proper home directory. UMS.conf doesn't accept home directory shorthand tilde (~) notation. 

Restart UMS and enjoy.
