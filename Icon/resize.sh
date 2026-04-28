#!/usr/bin/env sh

SOURCE="Time_Penguin_App.png"
DEST="AppIcon.appiconset"
mkdir -p "$DEST"

for SIZE in 16 32 128 256 512 1024; do
    sips -z $SIZE $SIZE "$SOURCE" --out "$DEST/icon_${SIZE}x${SIZE}.png"
done

for SIZE in 16 32 128 256 512; do
    DOUBLE=$((SIZE * 2))
    sips -z $DOUBLE $DOUBLE "$SOURCE" --out "$DEST/icon_${SIZE}x${SIZE}@2x.png"
done

echo "Done!"
