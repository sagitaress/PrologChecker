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

hos(e1).

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

/*position(a2,31).
position(b2,11).
position(c2,02).
position(d2,13).
position(e2,04).
position(f2,15).
position(g2,06).
position(h2,66).

position(a1,60).
position(b1,71).
position(c1,62).
position(d1,73).
position(e1,20).
position(f1,75).
position(g1,66).
position(h1,77).*/

validMove(Pawn,NewPos):-
    position(Pawn,X),
    isPosition(NewPos),
    direction(X,NewPos,Dir),
    NewPos is X+Dir.

validMove(Pawn,NewPos):-
    position(Pawn,X),
    isPosition(NewPos),
    hos(Pawn),
    direction(X,NewPos,Dir),
    NewPos2 is NewPos mod abs(Dir),
    X2 is X mod abs(Dir),
    NewPos2 is X2.

canMove(Pawn,NewPos):-
    hos(Pawn),
    validMove(Pawn,NewPos),
    position(Pawn,OldPos),
    direction(OldPos,NewPos,Dir),
    clearPath(OldPos,NewPos,Dir).

canMove(Pawn,NewPos):-
    validMove(Pawn,NewPos),
    not(position(_,NewPos)).

canEat(Pawn,Target,NewPos):-
    position(Pawn,X),
    position(Target,Y),
    validMove(Pawn,Y),
    direction(X,Y,Dir),
    NewPos is Y + Dir,
    isPosition(NewPos),
    not(position(_,NewPos)).

clearPath(Pos1,Pos2,Dir):-
    isPosition(Pos1),
    isPosition(Pos2),
    Res is Pos1 + Dir,
    Pos2 = Res.

clearPath(Pos1,Pos2,Dir):-
    isPosition(Pos1),
    isPosition(Pos2),
    NewPos is Pos1 + Dir,
    not(position(_,NewPos)),
    clearPath(NewPos,Pos2,Dir).

direction(P1,P2,Dir):-
    isUpperLeft(P1,P2),
    Dir is 11.

direction(P1,P2,Dir):-
    isUpperRight(P1,P2),
    Dir is 9.

direction(P1,P2,Dir):-
    isLowerLeft(P1,P2),
    Dir is -9.

direction(P1,P2,Dir):-
    isLowerRight(P1,P2),
    Dir is -11.

isUpperLeft(P1,P2):-
    isUpper(P1,P2),
    onLeft(P1,P2).

isUpperRight(P1,P2):-
    isUpper(P1,P2),
    onRight(P1,P2).

isLowerRight(P1,P2):-
    isLower(P1,P2),
    onRight(P1,P2).

isLowerLeft(P1,P2):-
    isLower(P1,P2),
    onLeft(P1,P2).

isUpper(P1,P2):-
    P1 // 10 < P2 // 10.

isLower(P1,P2):-
    P1 // 10 > P2 // 10.

onLeft(P1,P2):-
    P1 mod 10 < P2 mod 10.

onRight(P1,P2):-
    P1 mod 10 > P2 mod 10.

