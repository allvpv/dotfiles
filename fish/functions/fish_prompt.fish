function cutted_pwd
  prompt_pwd | awk '{
  n = split($0, s, "/");

  if(n - 2 > 0)
    start = n - 2;
      else
        start = 1;

        printf("%s", s[start]);

        for (i = start + 1; i <= n ; i++)
            printf("/%s", s[i]);

        printf("\n");
   }'
end

function fish_prompt
  set color ""

  if test $status = 0
    set color (set_color --bold green)
  else
    set color (set_color --bold red)
  end

  if test $CURRENTMACHINE = macbook_air_m1
    set arrow "$color גּ "
  else if test $CURRENTMACHINE = fedora_vm_arm64
    set arrow "$color  "
  else
    set arrow "$color ? "
  end

  set -l cwd (cutted_pwd)

  echo -n -s  $arrow \
             (set_color white)         $cwd   \
             (set_color normal)       ' '
end

