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

% To test the program, comment these
%/*
hos(dummy).

%Player Red
position(a2,00).
position(b2,11).
position(c2,02).
position(d2,13).
position(e2,04).
position(f2,15).
position(g2,06).
position(h2,17).
%position(h2,33).

%Player Blue
position(a1,60).
position(b1,71).
position(c1,62).
position(d1,73).
position(e1,64).
position(f1,75).
position(g1,66).
position(h1,77).
%position(h1,44).
%*/

%The third parameter is the states, used in a search tree----------
position(Pawn,Position,[[Pawn,Position]|T]).

position(Pawn,Position,[H|T]):-
    position(Pawn,Position,T).
%------------------------------------------------------------------

isOpposite(P1,P2):-
    pawn1(P1),
    pawn2(P2),!.

isOpposite(P1,P2):-
    pawn2(P1),
    pawn1(P2).

validDirection(Pawn,Dir):-
    not(hos(Pawn)),
    pawn1(Pawn),
    Dir < 0.

validDirection(Pawn,Dir):-
    not(hos(Pawn)),
    pawn2(Pawn),
    Dir > 0.

%valid move, no constraint on moving on top of another pawn.
validMove(Pawn,NewPos):-
    position(Pawn,X),
    isPosition(NewPos),
    direction(X,NewPos,Dir),
    validDirection(Pawn,Dir),
    NewPos is X+Dir.

validMove(Pawn,NewPos):-
    position(Pawn,X),
    isPosition(NewPos),
    hos(Pawn),
    direction(X,NewPos,Dir),
    NewPos2 is NewPos mod abs(Dir),
    X2 is X mod abs(Dir),
    NewPos2 is X2.

%for use in a search tree-----------------------------------------------------------
validMove(Pawn,NewPos,States):-
    position(Pawn,X,States),
    isPosition(NewPos),
    direction(X,NewPos,Dir),
    validDirection(Pawn,Dir),
    NewPos is X+Dir.

validMove(Pawn,NewPos,States):-
    position(Pawn,X,States),
    isPosition(NewPos),
    hos(Pawn),
    direction(X,NewPos,Dir),
    NewPos2 is NewPos mod abs(Dir),
    X2 is X mod abs(Dir),
    NewPos2 is X2.
%-----------------------------------------------------------------------------------

%can move, cannot move on top of others and normal pawn cannot go backward
canMove(Pawn,NewPos):-
    hos(Pawn),
    validMove(Pawn,NewPos),
    position(Pawn,OldPos),
    direction(OldPos,NewPos,Dir),
    clearPath(OldPos,NewPos,Dir).

canMove(Pawn,NewPos):-
    pawn1(Pawn),
    validMove(Pawn,NewPos),
    position(Pawn,OldPos),
    OldPos > NewPos,
    not(position(_,NewPos)).

canMove(Pawn,NewPos):-
    pawn2(Pawn),
    validMove(Pawn,NewPos),
    position(Pawn,OldPos),
    OldPos < NewPos,
    not(position(_,NewPos)).

%canMove/3, for minimax, used in a search tree------------------------------------------------------------(working on)
canMove(Pawn,NewPos,States):-
    hos(Pawn),
    validMove(Pawn,NewPos,States),
    position(Pawn,OldPos,States),
    direction(OldPos,NewPos,Dir),
    clearPath(OldPos,NewPos,Dir,States).

canMove(Pawn,NewPos,States):-
    pawn1(Pawn),
    validMove(Pawn,NewPos,States),
    position(Pawn,OldPos,States),
    OldPos > NewPos,
    not(position(_,NewPos,States)).

canMove(Pawn,NewPos,States):-
    pawn2(Pawn),
    validMove(Pawn,NewPos,States),
    position(Pawn,OldPos,States),
    OldPos < NewPos,
    not(position(_,NewPos,States)).
%----------------------------------------------------------------------------------------------------------

canEat(Pawn,Target,NewPos):-
    isOpposite(Pawn,Target),
    position(Pawn,X),
    position(Target,Y),
    validMove(Pawn,Y),
    direction(X,Y,Dir),
    NewPos is Y + Dir,
    isPosition(NewPos),
    not(position(_,NewPos)).


%---------------------------- Predicates used in a search tree ------------------------------
/*append([],X,X).

append([[Pawn,Position]],List,[[Pawn,Position]|C]):-
    append([],List,C).*/

generateMoves([Name|Position],Tail,Result,States):-
    canMove(Name,X,States),
    append([[Name,X]],Tail,Result).

%all moves of a given states(change the position of X in the given states)
allMoves([H|T],H,List,States):-
    generateMoves(H,T,List,States).

allMoves([H|T],X,[H|List],States):-
    allMoves(T,X,List,States).

minimax(States1,States2):-
    minimax_sub(States1,States2,0).

%Third parameter is the limit of the search depth
minimax_sub(_,_,5):-!.

%max(player2) turn(tree height is even)
minimax_sub(States1,States2,H):-
    0 is H mod 2,
    H1 is H+1,
    append(States1,States2,States),
    allMoves(States2,All,NewStates,States),
    write('Height: '),write(H1),nl,
    %write('State1: '),write(States1),nl,
    write('State2: '),write(NewStates),nl,
    minimax_sub(States1,NewStates,H1).

%min(player1) turn(tree height is odd)
minimax_sub(States1,States2,H):-
    1 is H mod 2,
    H1 is H+1,
    append(States1,States2,States),
    allMoves(States1,All,NewStates,States),
    write('Height: '),write(H1),nl,
    write('State1: '),write(NewStates),nl,
    %write('State2: '),write(States2),nl,
    minimax_sub(NewStates,States2,H1).

%-------------------------------------------------------------------------------------------

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

%clearPath/4, used in a search tree------------------------------------------------------------------------
clearPath(Pos1,Pos2,Dir,States):-
    isPosition(Pos1),
    isPosition(Pos2),
    Res is Pos1 + Dir,
    Pos2 = Res.

clearPath(Pos1,Pos2,Dir,States):-
    isPosition(Pos1),
    isPosition(Pos2),
    NewPos is Pos1 + Dir,
    not(position(_,NewPos,States)),
    clearPath(NewPos,Pos2,Dir,States).
%----------------------------------------------------------------------------------------------

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


minimax(List, MaxPair):-
    !.

findMin([], LowestPair, LowestPair):-!.
findMin([[CurrentPiece,CurrentValue]|List], [CurrentLowestPiece|CurrentLowestValue], LowestPair):-
    CurrentValue < CurrentLowestValue,
    findMin(List, [CurrentPiece,CurrentValue], LowestPair),
    !.

findMin([[CurrentPiece,CurrentValue]|List], [CurrentLowestPiece|CurrentLowestValue], LowestPair):-
    findMin(List, [CurrentLowestPiece|CurrentLowestValue], LowestPair).

findMax([], HighestPair, HighestPair):-!.
findMax([[CurrentPiece,CurrentValue]|List], [CurrentHighestPiece|CurrentHighestValue], HighestPair):-
    CurrentValue > CurrentHighestValue,
    findMin(List, [CurrentPiece,CurrentValue], HighestPair),
    !.

findMax([[CurrentPiece,CurrentValue]|List], [CurrentHighestPiece|CurrentHighestValue], HighestPair):-
    findMin(List, [CurrentLowestPiece|CurrentLowestValue], HighestPair).

eval(playerRed, States, Hoses, Value):-
    assertStates(States),
    assertHoses(Hoses),
    assertz(evalHos(dummy)),
    countEatable(playerRed, Value),
    retractall(evalPosition(_,_)),
    retractall(evalHos(_)).


eval(playerBlue, States, Hoses, Value):-
    assertStates(States),
    assertHoses(Hoses),
    assertz(evalHos(dummy)),
    countEatable(playerBlue, Value),
    retractall(evalPosition(_,_)),
    retractall(evalHos(_)).

assertStates([]):-!.
assertStates([[Piece,Position]|List]):-
    assertz(evalPosition(Piece,Position)),
    assertStates(List).

assertHoses([]):-!.
assertHoses([Hos|List]):-
    assertz(evalHos(Hos)),
    assertStates(List).

evalCanEat(Pawn,Target,NewPos):-
    isOpposite(Pawn,Target),
    evalPosition(Pawn,X),
    evalPosition(Target,Y),
    evalValidMove(Pawn,Y),
    direction(X,Y,Dir),
    NewPos is Y + Dir,
    isPosition(NewPos),
    not(position(_,NewPos)).

%for eval
evalValidMove(Pawn,NewPos):-
    evalPosition(Pawn,X),
    isPosition(NewPos),
    direction(X,NewPos,Dir),
    evalValidDirection(Pawn,Dir),
    NewPos is X+Dir,!.

evalValidMove(Pawn,NewPos):-
    evalPosition(Pawn,X),
    isPosition(NewPos),
    evalHos(Pawn),
    evalValidDirection(X,NewPos,Dir),
    NewPos2 is NewPos mod abs(Dir),
    X2 is X mod abs(Dir),
    NewPos2 is X2.

evalValidDirection(Pawn,Dir):-
    not(evalHos(Pawn)),
    pawn1(Pawn),
    Dir < 0.

evalValidDirection(Pawn,Dir):-
    not(evalHos(Pawn)),
    pawn2(Pawn),
    Dir > 0.

countEatable(playerRed, Count):-
    findall(RedPiece, (pawn1(RedPiece), evalPosition(RedPiece,_), pawn2(BluePiece), evalPosition(BluePiece,_), evalCanEat(RedPiece,BluePiece,_)), Eatable),
    length(Eatable, Plus),
    %findall(BluePiece, (pawn1(RedPiece), evalPosition(RedPiece,_), pawn2(BluePiece), evalPosition(BluePiece,_), evalCanEat(BluePiece,RedPiece,_)), Eaten),
    %length(Eaten, Minus),
    Count is Plus.

countEatable(playerBlue, Count):-
    findall(BluePiece, (pawn1(RedPiece), evalPosition(RedPiece,_), pawn2(BluePiece), evalPosition(BluePiece,_), evalCanEat(BluePiece,RedPiece,_)), Eatable),
    length(Eatable, Plus),
    %findall(RedPiece, (pawn1(RedPiece), evalPosition(RedPiece,_), pawn2(BluePiece), evalPosition(BluePiece,_), evalCanEat(RedPiece,BluePiece,_)), Eaten),
    %length(Eaten, Minus),
    Count is Plus.

