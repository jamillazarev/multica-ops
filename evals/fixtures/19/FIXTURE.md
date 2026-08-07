Scenario 19 — six levels down, and the board says `0/1`.

Workspace half (`eval-fixture.py 19 build`): a root issue whose child has a child, and so on.
The point is that **nothing rolls up** — the root reports only its direct children — so the
depth has to be walked rather than read off a counter.
