pawn1(a1).
pawn1(b1).
pawn1(c1).
pawn1(d1).
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

