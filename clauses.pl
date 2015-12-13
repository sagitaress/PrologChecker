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

%For using in a search tree------------------------------------
hos(Pawn,[Pawn|HosesTail]).

hos(Pawn,[H|HosesTail]):-
    hos(Pawn,HosesTail).
%--------------------------------------------------------------

% To test the program, comment out these
%/*
hos(dummy).
position(a2,00).
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
position(h1,77).
%*/

%The third parameter is the states, used in a search tree----------
position(Pawn,Position,[[Pawn,Position]|T]).

position(Pawn,Position,[H|T]):-
    position(Pawn,Position,T).
%------------------------------------------------------------------

isOpposite(P1,P2):-
    pawn1(P1),
    pawn2(P2).

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
validMove(Pawn,NewPos,States,Hoses):-
    position(Pawn,X,States),
    isPosition(NewPos),
    direction(X,NewPos,Dir),
    validDirection(Pawn,Dir),
    NewPos is X+Dir.

validMove(Pawn,NewPos,States,Hoses):-
    position(Pawn,X,States),
    isPosition(NewPos),
    hos(Pawn,Hoses),
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

%canMove/5, for minimax, used in a search tree------------------------------------------------------------
canMove(Pawn,NewPos,States,Hoses):-
    hos(Pawn,Hoses),
    validMove(Pawn,NewPos,States,Hoses),
    position(Pawn,OldPos,States),
    direction(OldPos,NewPos,Dir),
    clearPath(OldPos,NewPos,Dir,States).

canMove(Pawn,NewPos,States,Hoses):-
    pawn1(Pawn),
    validMove(Pawn,NewPos,States,Hoses),
    position(Pawn,OldPos,States),
    OldPos > NewPos,
    not(position(_,NewPos,States)).

canMove(Pawn,NewPos,States,Hoses):-
    pawn2(Pawn),
    validMove(Pawn,NewPos,States,Hoses),
    position(Pawn,OldPos,States),
    OldPos < NewPos,
    not(position(_,NewPos,States)).

canEat(Pawn,Target,NewPos,States,Hoses):-
    isOpposite(Pawn,Target),
    position(Pawn,X,States),
    position(Target,Y,States),
    validMove(Pawn,Y,States,Hoses),
    direction(X,Y,Dir),
    NewPos is Y + Dir,
    isPosition(NewPos),
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

%---------------------------- Predicates used in a search tree ------------------------------(working on)
modifyHoses([],_,[]).

modifyHoses([[Pawn,Position]|StatesTail],Hoses,NewHoses):-
    pawn1(Pawn),
    not(hos(Pawn,Hoses)),
    Position // 10 < 1.

%hos for player1
modifyHoses([[Pawn,Position]|StatesTail],Hoses,[Pawn|NewHosesTail]):-
    pawn1(Pawn),
    not(hos(Pawn,Hoses)),
    Position // 10 < 1,
    modifyHoses(StatesTail,Hoses,NewHosesTail).

%hos for player2
modifyHoses([[Pawn,Position]|StatesTail],Hoses,[Pawn|NewHosesTail]):-
    pawn2(Pawn),
    not(hos(Pawn,Hoses)),
    Position // 10 > 7.

modifyStates([],_,_,[]).

modifyStates([[Pawn2,Position2]|STail],Pawn,Position,[[Pawn2,Position2]|ResultTail]):-
    not(Pawn2==Pawn),
    modifyStates(STail,Pawn,Position,ResultTail).

modifyStates([[Pawn,_]|STail],Pawn,Position,[[Pawn,Position]|ResultTail]):-
    modifyStates(STail,Pawn,Position,ResultTail).

separate([],[],[]).

separate([[Pawn,Position]|STail],[[Pawn,Position]|S1Tail],States2):-
    pawn1(Pawn),
    separate(STail,S1Tail,States2).

separate([[Pawn,Position]|STail],States1,[[Pawn,Position]|S2Tail]):-
    pawn2(Pawn),
    separate(STail,States1,S2Tail).

generateMoves([Name,_],NewStates,States,Hoses):-
    canMove(Name,Position,States,Hoses),
    modifyStates(States,Name,Position,NewStates).

generateCapturing([Name,Position],States,States,Hoses,Chaining):-
    Chaining > 0,
    not(canEat(Name,Target,NewPosition,States,Hoses)).

%Tail = tail of state1 or 2
generateCapturing([Name,Position],NewStates,States,Hoses,Chaining):-
    canEat(Name,Target,NewPosition,States,Hoses),
    write('Capture!'),nl,
    modifyStates(States,Name,NewPosition,ModifiedStates),
    delete(ModifiedStates,[Target,_],DeletedStates),
    Chaining1 is Chaining+1,
    generateCapturing([Name,NewPosition],NewStates,DeletedStates,Chaining1).

%all moves of a given states(change the position of X in the given states)
allMoves([H|T],H,NewStates,States,Hoses):-
    generateMoves(H,NewStates,States,Hoses).

%For capturing
allMoves([H|T],H,NewStates,States,Hoses):-
    generateCapturing(H,NewStates,States,Hoses,0).

allMoves([H|T],X,NewStates,States,Hoses):-
    allMoves(T,X,NewStates,States).

minimax(States,Hoses):-
    minimax_sub(States,Hoses,0,1).

%Second parameter is the limit of the search depth
minimax_sub(States,Hoses,2,1):-!.
%   eval(States,Hoses,Value),
%   minimaxVal2(OldVal),
%   Value < OldVal,
%   retractall('minimaxVal2(_)'),
%   asserta('minimaxVal2()'),


%minimax_sub(States,Hoses,2,1):-!.

%   eval(States,Hoses)

%max(player2) turn(tree height is even)
minimax_sub(States,Hoses,H,Val):-
    0 is H mod 2,
    H1 is H+1,
    separate(States,States1,States2),
    allMoves(States2,All,NewStates,States,Hoses),
    separate(NewStates,NewStates1,NewStates2),
    write('Height: '),write(H1),nl,
    %write('State1: '),write(NewStates1),nl,
    write('State2: '),write(NewStates2),nl,
    minimax_sub(NewStates,Hoses,H1,Val).


%min(player1) turn(tree height is odd)
minimax_sub(States,Hoses,H,Val):-
    1 is H mod 2,
    H1 is H+1,
    separate(States,States1,States2),
    allMoves(States1,All,NewStates,States,Hoses),
    separate(NewStates,NewStates1,NewStates2),
    write('Height: '),write(H1),nl,
    write('State1: '),write(NewStates1),nl,
    %write('State2: '),write(NewStates2),nl,
    minimax_sub(NewStates,Hoses,H1,Val).

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


