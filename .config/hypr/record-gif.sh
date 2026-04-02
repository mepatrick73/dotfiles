#!/usr/bin/env bash
# Toggle GIF screen recording of a selected region.
# First press: select region and start recording.
# Second press: stop recording and save as GIF to ~/Videos/.

TMPVIDEO=/tmp/screen-recording.mp4
OUTDIR="$HOME/Videos"
OUTFILE="$OUTDIR/recording-$(date +%Y%m%d-%H%M%S).gif"
PALETTE=/tmp/screen-recording-palette.png

mkdir -p "$OUTDIR"

if pgrep -x wf-recorder > /dev/null; then
    pkill -SIGINT wf-recorder
    # Wait for wf-recorder to finish writing the file
    while pgrep -x wf-recorder > /dev/null; do sleep 0.1; done

    notify-send "GIF" "Converting recording..." -t 2000

    LOGFILE=/tmp/record-gif-ffmpeg.log

    ffmpeg -y -i "$TMPVIDEO" \
        -vf "fps=15,scale=800:-1:flags=lanczos,palettegen" \
        -update 1 "$PALETTE" > "$LOGFILE" 2>&1 && \
    ffmpeg -y -i "$TMPVIDEO" -i "$PALETTE" \
        -filter_complex "fps=15,scale=800:-1:flags=lanczos[x];[x][1:v]paletteuse" \
        "$OUTFILE" >> "$LOGFILE" 2>&1

    if [[ -f "$OUTFILE" ]]; then
        rm -f "$PALETTE" "$TMPVIDEO"
        notify-send "GIF saved" "$OUTFILE" -t 5000
    else
        notify-send "GIF failed" "Check $LOGFILE for details" -t 8000
    fi
else
    REGION=$(slurp) || exit 1
    notify-send "GIF" "Recording... Press Shift+PrtSc to stop." -t 3000
    setsid wf-recorder -g "$REGION" -f "$TMPVIDEO" > /dev/null 2>&1 &
fi
