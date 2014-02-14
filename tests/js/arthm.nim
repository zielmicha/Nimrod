block:
  let i = 0.5
  let j = int(i)
  assert j == 0

block:
  let i = -0.5
  let j = int(i)
  assert j == 0
