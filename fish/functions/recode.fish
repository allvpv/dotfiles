function recode
  if test (count $argv) -ne 1
    echo "Provide exactly one argument (video file)" 1>&2
    return 1
  end

  set -l path (realpath "$argv[1]")
  set -l recode_path (echo $path | sed 's/\.[^.]*$//').mp4

  echo "'$path' -> '$recode_path'"
  echo Running ffmpeg...

  ffmpeg -i $path -map 0:a -map 0:s\? -map 0:v -acodec copy -vcodec copy -c:s mov_text $recode_path
end

