%%%%%%%%%%%%%%%%%%
% OTHELLO PROLOG %
%%%%%%%%%%%%%%%%%%

%Rules : https://www.ultraboardgames.com/othello/game-rules.php
%Heuristics : https://courses.cs.washington.edu/courses/cse573/04au/Project/mini1/RUSSIA/Final_Paper.pdf

%Creation of the boarding game at the begin of the play
%%The board will start with 2 black discs and 2 white discs at the centre of the board.
%%They are arranged with black forming a North-East to South-West direction.
%%Black always moves first.
init :- length(Board,64),nth0(28,Board,'b'),nth0(35,Board,'b'),nth0(27,Board,'w'),nth0(36,Board,'w'),assert(board(Board)),play('b').


%Tour de jeu : si pas de gagnant, on fait un tour de jeu pour un joueur.
play(_) :- gameover(Winner),!,write('Game is over. Winner : '), writeln(Winner), displayBoard.
play(Player) :- board(Board), moveAvailable(Board,Player) , write('New turn for : '), writeln(Player), displayBoard, ia(Board,Move,Player), playMove(Board,Move,NewBoard,Player),applyIt(Board,NewBoard),changePlayer(Player,NextPlayer), !, play(NextPlayer).
play(Player) :- write('Player "'), write(Player), writeln('" can not play.'), changePlayer(Player,NextPlayer), play(NextPlayer).


%Fin de partie
%%When it is no longer possible for either player to move, the game is over.
gameover(Winner) :- board(Board), not(moveAvailable(Board, _)), findWinner(Board,Winner).


%Trouver le gagnant, si quelqu'un a une meilleur soluce..
%%Permet de trouver qui a le plus de disque sur le plateau
countDisk([],[],'Draw').
countDisk([],_,'w').
countDisk(_,[],'b').
countDisk([_|L1],[_|L2],Winner) :- countDisk(L1,L2,Winner).

%Separe les disques blancs et noirs
%%L1 de longeur le nombre de disque noir
%%L2 de longeur le nombre de disque blanc
separate([],_,_). % plus d'element a separer
separate(['b'|Board],['b'|L1],L2) :- separate(Board,L1,L2).
separate(['w'|Board],L1,['w'|L2]) :- separate(Board,L1,L2). 
separate([_|Board],L1,L2) :- separate(Board,L1,L2). % autre que b ou w
%%separate([E|Board],L1,L2) :- var(E), separate(Board,L1,L2).

findWinner(Board,Winner) :- separate(Board,L1,L2), countDisk(L1,L2,Winner). 


%On cherche si il existe encore un mouvement possible
%%A move is made by placing a disc of the player's color on the board in a position that "out-flanks" one or more of the opponent's discs.
%%A disc or row of discs is outflanked when it is surrounded at the ends by discs of the opposite color.
%%A disc may outflank any number of discs in one or more rows in any direction (horizontal, vertical, diagonal).
%On cherche si on trouve un mouvement possible dans une ligne, puis une colonnes, puis les deux diagonales. P est le player qui a le move
moveAvailable(Board,P) :- moveAvailableRow(Board,[],0,P).
moveAvailable(Board,_) :- moveAvailableCol(Board,_).
moveAvailable(Board,_) :- moveAvailableDiagR(Board,_).
moveAvailable(Board,_) :- moveAvailableDiagL(Board,_).

%Création d'une liste par ligne et on teste si un move est possible dans la liste
moveAvailableRow([],B,_,P) :- moveAvailableArray(B,P).
moveAvailableRow(B2,B,8,P) :- B2\==[], moveAvailableArray(B,P).
moveAvailableRow(B,_,8,P) :- B\==[], moveAvailableRow(B,[],0,P).
moveAvailableRow([E|B],B2,Pos,P) :- Pos \== 8, NewPos is Pos+1, moveAvailableRow(B,[E|B2],NewPos,P).

%TODO
%Création d'une liste par colonne et test
moveAvailableCol(_,_) :- 1=2.
%Création d'une liste par diag hautgauche vers basdroite
moveAvailableDiagR(_,_) :- 1=2.
%Création d'une liste par diag hautdroite vers basgauche
moveAvailableDiagL(_,_) :- 1=2.


%On cherche si on trouve une place valide dans une liste cad deux couleurs différentes côte à côte
moveAvailableArray(B,P) :- moveAvailableArrayClearDisk(B,P). %On test dans un sens
moveAvailableArray(B,P) :- inv(B, B2), moveAvailableArrayClearDisk(B2,P). %On test dans l'autre

moveAvailableArrayClearDisk([D|B], P) :- nonvar(D), moveAvailableArrayClearDisk(B,P). %On dépile tant que case pleine
moveAvailableArrayClearDisk([D|B], P) :- var(D), moveAvailableArray1(B,_,P). %Après la case vide, on recherche un changement de couleur

moveAvailableArray1([D|B],_,P) :- var(D), moveAvailableArray1(B,_,P). %tant que l on a des places libres, on les retire
moveAvailableArray1([D|B],PrevD,P) :- nonvar(D), var(PrevD), moveAvailableArray1(B,D,P). %On trouve le premier élément
moveAvailableArray1([D|B],PrevD,P) :- nonvar(D), nonvar(PrevD), D==PrevD, moveAvailableArray1(B,D,P). %Il existe un précédent mais meme couleur
moveAvailableArray1([D|_],PrevD,D) :- nonvar(D), nonvar(PrevD), D\==PrevD. %Il existe un précédent et il est de couleur différente. Il existe un move

%Inversion d'une liste
inv(L,R) :- inv(L,[],R).
inv([],A,A).
inv([T|Q],A,R) :- inv(Q,[T|A],R).



%TODO : Create different versions
ia(Board,Move,Player) :- repeat, Move is random(64), nth0(Move,Board,Elem), var(Elem), !.

%Heuristics
% P1 is the current player while P2 is the ennemy
% Corners Captured
%P1 is the current player
heuristic_cornersCaptured(Board, P1, P2, H) :-
    %Récupérer tous les disques
    getCorners(Board, Corners),
    %Compter le nombre de disques occupés par joueur
    countByPlayer(Corners, P1, NbDiskP1),
    countByPlayer(Corners, P2, NbDiskP2),
    %Somme des disques sur les coins
    Somme is NbDiskP1 + NbDiskP2,
    %Calculer l'heuristique
    heuristic_compute(NbDiskP1, NbDiskP2, Somme, H).

getCorners(Board, Corners) :- getCorners(Board, Corners, 0).
getCorners([],[],64).
getCorners([D|B], [D|C], I) :- (I==0 ; I==7 ; I==56; I==63) , J is I+1, getCorners([D|B], [D|C], J).

countByPlayer([], P, 0).
countByPlayer([D|C], P, NbDiskP) :- var(D), countByPlayer(C, P, NbDiskP).
countByPlayer([P|C], P, NbDiskP) :- countByPlayer(C, P, NewNbDiskP), NbDiskP is NewNbDiskP + 1.
countByPlayer([D|C], P, NbDiskP) :- countByPlayer(C, P, NbDiskP).

heuristic_compute(_,_,0,0).
heuristic_compute(NbDiskP1, NbDiskP2, Somme, H) :- H is 100 * (NbDiskP1-NbDiskP2) / Somme.

% Stability
% TODO : compléter les stables/instables, possibilité d'utiliser le statique
heuristic_stability(Board, P1, P2, H) :-
    %Compter les stables de P1 (impossible à retourner dans la partie)
    countStable(Board, P1, NbDiskStableP1),
    %Compter les stables de P2
    countStable(Board, P2, NbDiskStableP2),
    %Compter les instables de P1 (retournable au tour suivant)
    countUnstable(Board, P1, NbDiskUnstableP1),
    %Compter les instables de P2
    countUnstable(Board, P2, NbDiskUnstableP2),
    %Calculer les stabilités
    StabilityP1 is NbDiskStableP1 - NbDiskUnstableP1,
    StabilityP2 is NbDiskStableP2 - NbDiskUnstableP2,
    Somme is StabilityP1 + StabilityP2,
    %Calculer l'heuristique
    heuristic_stability_compute(StabilityP1, StabilityP2, Somme, H).

%Ajoute le disque sur le plateau
%TODO retourne les disques encercles
playMove(Board, Move, NewBoard, Player) :- Board=NewBoard, nth0(Move,NewBoard,Player).


%Enregistre le plateau
applyIt(Board, NewBoard) :- retract(board(Board)),assert(board(NewBoard)).

%Permet de switch de joueur
changePlayer('b','w').
changePlayer('w','b').


%Affiche le plateau de jeu visuellement
%%X = Ligne
%%Y = Colonne
displayBoard :- writeln('----------'),board(Board),displayRow(Board,0),writeln('----------').
displayRow(_,8).
displayRow(Board,X) :- displayCol(Board,X,0).
displayCol(Board,X,8) :- Y is X+1,writeln(''),displayRow(Board,Y).
displayCol([C|Board],X,Y) :- displayCell(C), Z is Y+1, displayCol(Board,X,Z).
displayCell(C) :- var(C), write('O').
displayCell(C) :- write(C).
