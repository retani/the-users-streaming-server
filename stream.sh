#! /bin/bash
#
# Diffusion youtube avec ffmpeg

# Configurer youtube avec une résolution 720p. La vidéo n'est pas scalée.

VBR="1600k"                                    # Bitrate de la vidéo en sortie
FPS="30"                                       # FPS de la vidéo en sortie
QUAL="medium"                                  # Preset de qualité FFMPEG
YOUTUBE_URL="rtmp://stream.theusers.live/live"  # URL de base RTMP youtube

SOURCE="$1"              # Source UDP (voir les annonces SAP)
KEY="test"                                     # Clé à récupérer sur l'event youtube

ffmpeg \
    -i "$SOURCE" -deinterlace \
    -vcodec libx264 -pix_fmt yuv420p -preset $QUAL -r $FPS -g $(($FPS * 2)) -b:v $VBR \
    -acodec libmp3lame -ar 44100 -threads 4 -qscale 3 -b:a 712000 -bufsize 512k \
    -f flv "$YOUTUBE_URL/$KEY"