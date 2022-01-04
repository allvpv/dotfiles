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
  set arrow " גּ "

  if test $status = 0
    set -p arrow (set_color --bold green)
  else
    set -p arrow (set_color --bold red)
  end

  set -l cwd (cutted_pwd)
  #set -l git (_pure_prompt_git)

  echo -n -s  $arrow \
             (set_color white)         $cwd   \
             (set_color normal)       ' '
end

