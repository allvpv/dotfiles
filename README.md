![dotfiles in action: screenshot](screen.png)

### Installation

```shell
bash -c "$(curl --proto '=https' --tlsv1.2 -sSfL https://sh.allvpv.org)"
```

### Notes

- If bash keeps refusing to load multiline history entries properly, make sure
  that the first line in `.bash_history` is a timestamp, i.e. is a hash
  followed by a number.
