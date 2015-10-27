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

hos(no).

isPosition(0).
isPosition(11).
isPosition(02).
isPosition(13).
isPosition(04).
isPosition(15).
isPosition(06).
isPosition(17).

isPosition(20).
isPosition(31).
isPosition(22).
isPosition(33).
isPosition(24).
isPosition(35).
isPosition(26).
isPosition(37).

isPosition(40).
isPosition(51).
isPosition(42).
isPosition(53).
isPosition(44).
isPosition(55).
isPosition(46).
isPosition(57).

isPosition(60).
isPosition(71).
isPosition(62).
isPosition(73).
isPosition(64).
isPosition(75).
isPosition(66).
isPosition(77).

/*position(a2,00).
position(b2,11).
position(c2,02).
position(d2,13).
position(e2,04).
position(f2,15).
position(g2,06).
position(h2,17).

position(a1,60).
position(b1,71).
position(c1,62).
position(d1,73).
position(e1,64).
position(f1,75).
position(g1,66).
position(h1,77).*/

safe(Position):-
    X is Position//10,
    X is 0.

safe(Position):-
    X is Position//10,
    X is 7.

safe(Position):-
    X is Position mod 10,
    X is 0.

safe(Position):-
    X is Position mod 10,
    X is 7.

canMove(Pawn,NewPos):-
    pawn1(Pawn),
    isPosition(NewPos),
    position(Pawn,CurrentPos),
    not(position(_,NewPos)),
    NewPos is CurrentPos - 9.

canMove(Pawn,NewPos):-
    pawn1(Pawn),
    isPosition(NewPos),
    position(Pawn,CurrentPos),
    not(position(_,NewPos)),
    NewPos is CurrentPos - 11.

canMove(Pawn,NewPos):-
    pawn2(Pawn),
    isPosition(NewPos),
    position(Pawn,CurrentPos),
    not(position(_,NewPos)),
    NewPos is CurrentPos + 9.

canMove(Pawn,NewPos):-
    pawn2(Pawn),
    isPosition(NewPos),
    position(Pawn,CurrentPos),
    not(position(_,NewPos)),
    NewPos is CurrentPos + 11.

canMove(Pawn,NewPos):-
    pawn1(Pawn),
    hos(Pawn),
    isPosition(NewPos),
    position(Pawn,CurrentPos),
    not(position(_,NewPos)),
    NewPos2 is NewPos mod 9,
    NewPos2 is CurrentPos mod 9.

canMove(Pawn,NewPos):-
    hos(Pawn),
    isPosition(NewPos),
    position(Pawn,CurrentPos),
    not(position(_,NewPos)),
    NewPos2 is NewPos mod 11,
    NewPos2 is CurrentPos mod 11.

canEat(Pawn,Target,NewPos):-
    pawn1(Pawn),
    pawn2(Target),
    position(Pawn,X),
    position(Target,Y),
    Y is X - 9,
    not(safe(Y)),
    NewPos is Y-9,
    not(position(_,NewPos)).

canEat(Pawn,Target,NewPos):-
    pawn1(Pawn),
    pawn2(Target),
    position(Pawn,X),
    position(Target,Y),
    Y is X - 11,
    not(safe(Y)),
    NewPos is Y-11,
    not(position(_,NewPos)).

canEat(Pawn,Target,NewPos):-
    pawn2(Pawn),
    pawn1(Target),
    position(Pawn,X),
    position(Target,Y),
    Y is X + 9,
    not(safe(Y)),
    NewPos is Y+9,
    not(position(_,NewPos)).

canEat(Pawn,Target,NewPos):-
    pawn2(Pawn),
    pawn1(Target),
    position(Pawn,X),
    position(Target,Y),
    Y is X + 11,
    not(safe(Y)),
    NewPos is Y+11,
    not(position(_,NewPos)).