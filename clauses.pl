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

hos(dummy).
/*
%Player Red
position(a2,00).
position(b2,11).
position(c2,02).
position(d2,13).
position(e2,04).
position(f2,15).
position(g2,06).
%position(h2,17).
position(h2,33).

%Player Blue
position(a1,60).
position(b1,71).
position(c1,62).
position(d1,73).
position(e1,64).
position(f1,75).
position(g1,66).
%position(h1,77).
position(h1,44).
*/

initializePosition([]).

initializePosition([[Pawn,Position]|T]):-
    asserta(position(Pawn,Position)),
    initializePosition(T).

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
    not(hos(Pawn,Hoses)),
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
    not(position(_,NewPos,States)),
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
maxTreeDepth(3).

modifyHoses([],_,[]).

%hos for player1
modifyHoses([[Pawn,Position]|StatesTail],Hoses,[Pawn|NewHosesTail]):-
    pawn1(Pawn),
    %not(hos(Pawn,Hoses)),
    Position // 10 < 1,
    modifyHoses(StatesTail,Hoses,NewHosesTail),!.

%hos for player2
modifyHoses([[Pawn,Position]|StatesTail],Hoses,[Pawn|NewHosesTail]):-
    pawn2(Pawn),
    %not(hos(Pawn,Hoses)),
    Position // 10 > 6,
    modifyHoses(StatesTail,Hoses,NewHosesTail),!.

modifyHoses([[Pawn,Position]|StatesTail],Hoses,NewHosesTail):-
    modifyHoses(StatesTail,Hoses,NewHosesTail).

removeHoses(_, [], Ans, Ans):-!.

removeHoses(States, [Hos|Tail], RemainingHoses, Ans):-
    not(member([Hos,_], States)),
    removeHoses(States, Tail, RemainingHoses, Ans),!.

removeHoses(States, [Hos|Tail], RemainingHoses, Ans):-
    removeHoses(States, Tail, [Hos|RemainingHoses], Ans).

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
    not(canEat(Name,_,_,States,Hoses)),
    modifyStates(States,Name,Position,NewStates).

%punish
generateMoves([Name,_],NewStates,States,Hoses):-
    canMove(Name,Position,States,Hoses),
    canEat(Name,_,_,States,Hoses),
    delete(States,[Name,_],NewStates).


generateCapturing([Name,Position],States,States,Hoses,Chaining):-
    Chaining > 0,
    not(canEat(Name,Target,NewPosition,States,Hoses)).

%Tail = tail of state1 or 2
generateCapturing([Name,Position],NewStates,States,Hoses,Chaining):-
    canEat(Name,Target,NewPosition,States,Hoses),
    %write('Capture!'),nl,
    modifyStates(States,Name,NewPosition,ModifiedStates),
    delete(ModifiedStates,[Target,_],DeletedStates),
    Chaining1 is Chaining+1,
    generateCapturing([Name,NewPosition],NewStates,DeletedStates,Hoses,Chaining1).

%all moves of a given states(change the position of X in the given states)
allMoves([H|T],H,NewStates,States,Hoses):-
    generateMoves(H,NewStates,States,Hoses).

%For capturing
allMoves([H|T],H,NewStates,States,Hoses):-
    generateCapturing(H,NewStates,States,Hoses,0).

allMoves([H|T],X,NewStates,States,Hoses):-
    allMoves(T,X,NewStates,States,Hoses).

%not the first of the depth (max)
%max turn so we check whether the value is less than the least value so far
modifiedMinimaxVal(Depth,States,Hoses):-
   not(minimaxVal(empty,Depth,_)),
   %0 is Depth mod 2,
   minimaxVal(OldVal,Depth,_),
   Depth1 is Depth+1,
   minimaxVal(NewVal,Depth1,_),
   NewVal > OldVal,
   retractall(minimaxVal(_,Depth,_)),
   asserta(minimaxVal(NewVal,Depth,States)),
   !.

%not the first of the depth (max) no modification
%max turn so we check whether the value is less than the least value so far
modifiedMinimaxVal(Depth,States,Hoses):-
   not(minimaxVal(empty,Depth,_)),
   %0 is Depth mod 2,
   minimaxVal(OldVal,Depth,_),
   Depth1 is Depth+1,
   minimaxVal(NewVal,Depth1,_),
   NewVal =< OldVal,
   !.

%the first, not leaf
modifiedMinimaxVal(Depth,States,Hoses):-
   minimaxVal(empty,Depth,_),
   Depth1 is Depth + 1,
   minimaxVal(NewVal,Depth1,_),
   retractall(minimaxVal(_,Depth,_)),
   asserta(minimaxVal(NewVal,Depth,States)).

%leaf node playerRed(2,or max)
modifiedMinimaxVal(Depth,States,Hoses,NewVal):-
   0 is Depth mod 2,
   %write('leafRed'),nl,
   maxTreeDepth(Depth),
   eval(playerRed,States,Hoses,NewVal).

%leaf node playerBlue(1,or min)
modifiedMinimaxVal(Depth,States,Hoses,NewVal):-
   %write('test'),nl,
   1 is Depth mod 2,
   %write('leafBlue'),nl,
   maxTreeDepth(Depth),
   eval(playerBlue,States,Hoses,NewVal).

minimax(States,Hoses,NewStates):-
    maxTreeDepth(Depth),
    minimax_sub(States,Hoses,0,Val,NewStates).
    %findall([Val,States],minimax_sub(States,Hoses,0,Val,NewStates),List),
    %write('List: '),write(List),nl,
    %maxValState(List,empty,[_,NewStates])
    %write(NewStates),nl.

maxValState([], [CurrentMaxVal,CurrentMaxState], [CurrentMaxVal,CurrentMaxState]):-!.

maxValState([[Val, States]|Tail], empty, AnsMaxPair):-
    maxValState(Tail, [Val,States], AnsMaxPair).

maxValState([[Val, States]|Tail], [CurrentMaxVal,CurrentMaxState], AnsMaxPair):-
    Val >= CurrentMaxVal,
    maxValState(Tail, [Val,States], AnsMaxPair),!.

maxValState([[Val, States]|Tail], [CurrentMaxVal,CurrentMaxState], AnsMaxPair):-
    Val < CurrentMaxVal,
    maxValState(Tail, [CurrentMaxVal,CurrentMaxState], AnsMaxPair),!.

%Tree terminated!
%Second parameter is the limit of the search depth
   minimax_sub(States,Hoses,Depth,Val,States):-
   maxTreeDepth(Depth),
   %write('Height: '),write(Depth),nl,
   %write('State: '),write(States),nl,
   %write('tree terminated'),nl,
   modifiedMinimaxVal(Depth,States,Hoses,Val),
   %write('val = '),
   %write(States),nl,
   !.

%min(player2) turn(tree height is even)
minimax_sub(States,Hoses,Depth,MaxVal,MaxState):-
    0 is Depth mod 2,
    Depth1 is Depth+1,
    separate(States,States1,States2),
    %write('sub_even'),nl,
    findall(NewStates,allMoves(States2,All,NewStates,States,Hoses),NewStateList),
    %write('NEWSTATE: '),write(NewStateList),nl,
    minimax_helper(NewStateList,Hoses,Depth1,empty,[MaxVal,MaxState]).
    %write('Height: '),write(Depth),nl,
    %write(MaxState),nl.

%min(player1) turn(tree height is odd)
minimax_sub(States,Hoses,Depth,MaxVal,MaxState):-
    %write('sub_odd'),nl,
    1 is Depth mod 2,
    Depth1 is Depth+1,
    separate(States,States1,States2),
    findall(NewStates,allMoves(States1,All,NewStates,States,Hoses),NewStateList),
    %write('NEWSTATE: '),write(NewStateList),nl,
    minimax_helper(NewStateList,Hoses,Depth1,empty,[MaxVal,MaxState]).
    %write('Height: '),write(Depth),nl,
    %write(MaxState),nl.

minimax_helper([],_,_,[CurrentVal,CurrentState],[CurrentVal,CurrentState]):-!.

minimax_helper([States|Tail],Hoses,Depth,empty,AnsPair):-
    %findall([NewVal,NewMaxState],minimax_sub(States,Hoses,Depth,NewVal,NewMaxState),List),
    minimax_sub(States,Hoses,Depth,MaxVal,MaxState),
    %write('List: '),
    %write(List),nl,
    %maxValState(List,empty,[MaxVal,MaxState]),
    minimax_helper(Tail,Hoses,Depth,[MaxVal,States],AnsPair).

minimax_helper([States|Tail],Hoses,Depth,[CurrentVal,CurrentState],AnsPair):-
    %findall([NewVal,NewMaxState],minimax_sub(States,Hoses,Depth,NewVal,NewMaxState),List),
    minimax_sub(States,Hoses,Depth,MaxVal,MaxState),
    %write('List: '),
    %write(List),nl,
    %maxValState(List,empty,[MaxVal,MaxState]),
    MaxVal > CurrentVal,
    minimax_helper(Tail,Hoses,Depth,[MaxVal,States],AnsPair),!.

minimax_helper([States|Tail],Hoses,Depth,[CurrentVal,CurrentState],AnsPair):-
    %findall([NewVal,NewMaxState],minimax_sub(States,Hoses,Depth,NewVal,NewMaxState),List),
    minimax_sub(States,Hoses,Depth,MaxVal,MaxState),
    %write('List: '),
    %write(List),nl,
    %maxValState(List,empty,[MaxVal,MaxState]),
    MaxVal =< CurrentVal,
    minimax_helper(Tail,Hoses,Depth,[CurrentVal,CurrentState],AnsPair),!.

%eval(_,_,1).%:-
    %write('Terminated'),nl,!.

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
    findall([Piece,Pos], (pawn2(Piece), pawn1(Enemy),canEat(Piece, Enemy, Pos, States, Hoses)), NewPos),
    stateUpdate(playerRed, States, Hoses, NewPos, [], Value).

eval(playerBlue, States, Hoses, Value):-
    findall([Piece,Pos], (pawn1(Piece), pawn2(Enemy),canEat(Piece, Enemy, Pos, States, Hoses)), NewPos),
    stateUpdate(playerBlue, States, Hoses, NewPos, [], Value).

stateUpdate(_,_,_,[],[],0):-!.

stateUpdate(_,_,_,[],ValueList, MaxValue):-
    max_list(ValueList, MaxValue),!.

stateUpdate(Player, States, Hoses, [[Piece,NewPos]|Remaining], ValueList, MaxValue):-
    %modifyHoses(NewStates, Hoses, NewHoses),
    canEat(Piece, Enemy, NewPos, States, Hoses),
    subtract(States, [[Enemy,_]], States2),
    modifyStates(States2, Piece, NewPos, NewStates),
    modifyHoses(NewStates, Hoses, NewHoses),
    evalChain(Player, Piece, NewStates, NewHoses, Val),
    stateUpdate(Player, States, Hoses, Remaining,[Val|ValueList], MaxValue).

evalChain(playerRed, CurrentPiece, States, Hoses, Value):-
    findall(Pos, (isOpposite(CurrentPiece,Enemy),canEat(CurrentPiece, Enemy, Pos, States, Hoses)), []),
    separate(States, RedPieces, BluePieces),
    length(RedPieces, PlayerCount),
    length(BluePieces, EnemyCount),
    removeHoses(States, Hoses, [], RemainingHoses),
    separateHoses(RemainingHoses, RedHoses, BlueHoses),
    length(RedHoses, PlayerHosesCount),
    length(BlueHoses, EnemyHosesCount),
    Value is PlayerCount + 2 * PlayerHosesCount - EnemyCount - 2 * EnemyHosesCount,
    !.

evalChain(playerBlue, CurrentPiece, States, Hoses, Value):-
    findall([CurrentPiece,Pos], (isOpposite(CurrentPiece,Enemy),canEat(CurrentPiece, Enemy, Pos, States, Hoses)), []),
    separate(States, RedPieces, BluePieces),
    length(RedPieces, EnemyCount),
    length(BluePieces, PlayerCount),
    removeHoses(States, Hoses, [], RemainingHoses),
    separateHoses(RemainingHoses, RedHoses, BlueHoses),
    length(RedHoses, EnemyHosesCount),
    length(BlueHoses, PlayerHosesCount),
    Value is PlayerCount + 2 * PlayerHosesCount - EnemyCount - 2 * EnemyHosesCount,!.

evalChain(Player, CurrentPiece, States, Hoses, Value):-
    findall([CurrentPiece,Pos], (isOpposite(CurrentPiece,Enemy),canEat(CurrentPiece, Enemy, Pos, States, Hoses)), NewPos),
    stateUpdate(Player, States, Hoses, NewPos, [], Value).

generateStates(States):-
    findall([Piece,Pos], position(Piece, Pos), States).

generateHoses(Hoses):-
    findall(Piece, hos(Piece), Hoses).


%----------------------------------------------
%------------------Unused----------------------

/*
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
*/
