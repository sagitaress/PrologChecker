pawn1(a1).
pawn1(b1).
pawn1(c1).
pawn1(d1)
pawn1(e1).
pawn1(f1).
pawn1(g1).
pawn1(h1).

pawn2(a2).
pawn2(b2).
pawn2(c2).
pawn2(d2).
pawn2(e2).
pawn2(f2).
pawn2(g2).
pawn2(h2).

position(a1,60).
position(b1,71).
position(c1,62).
position(d1,73).
position(e1,64).
position(f1,75).
position(g1,66).
position(h1,77).

position(a2,00).
position(b2,11).
position(c2,02).
position(d2,13).
position(e2,04).
position(f2,15).
position(g2,06).
position(h2,17).

canMove(Pawn,NewPos):-
  pawn1(Pawn),
  position(Pawn,CurrentPos),
  NewPos is CurrentPos - 9.

canMove(Pawn,NewPos):-
  pawn1(Pawn),
  position(Pawn,CurrentPos),
  NewPos is CurrentPos - 11.

canMove(Pawn,NewPos):-
  pawn2(Pawn),
  position(Pawn,CurrentPos),
  NewPos is CurrentPos + 9.

canMove(Pawn,NewPos):-
  pawn2(Pawn),
  position(Pawn,CurrentPos),
  NewPos is CurrentPos + 11.
