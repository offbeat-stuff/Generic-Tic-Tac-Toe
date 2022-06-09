proc dump*(start, finish: SomeNumber) =
  echo "-----------------"
  for i in countup(start, finish, 8):
    echo i, " ", min(i + 8, finish)

for i in 10 .. 100:
  dump(i, 100)
