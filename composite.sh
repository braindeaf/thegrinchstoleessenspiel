#!/bin/bash

convert red-background.jpeg -resize 1920x1080^ \
                            -gravity Center    \
                            -extent 1920x1080  \
                            \( images/$1.jpg -resize x750 \) -gravity NorthWest -geometry +90+50 -composite \
                            \( iplayred.png -resize x200 \) -gravity SouthEast -geometry +30+10 -composite \
                            \( spiel.digital.png -resize x150 \) -gravity NorthEast -geometry +50+50 -composite \
                            \( -background transparent -fill white -font Palatino -pointsize 72 label:"$2" \) -gravity SouthWest -geometry +90+140 -composite \
                            \( -background transparent -fill white -font Palatino-Bold -pointsize 65 label:"$3" \) -gravity SouthWest -geometry +95+60 -composite \
        images-composited/$1.jpg
