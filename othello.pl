%%%%%%%%%%%%%%%%%%
% OTHELLO PROLOG %
%%%%%%%%%%%%%%%%%%

%Rules : https://www.ultraboardgames.com/othello/game-rules.php

%Creation du plateau de jeu et debut de la partie
%%The board will start with 2 black discs and 2 white discs at the centre of the board.
%%They are arranged with black forming a North-East to South-West direction.
%%Black always moves first.
init :- length(Board,64),nth0(28,Board,'b'),nth0(35,Board,'b'),nth0(27,Board,'w'),nth0(36,Board,'w'),assert(board(Board)),play('b').


%Tour de jeu : si pas de gagnant, on fait un tour de jeu pour un joueur.
play(_) :- gameover(Winner),!,write('Game is over. Winner : '), writeln(Winner), displayBoard.
play(Player) :- moveAvailable(Player), ! , write('New turn for : '), writeln(Player),board(Board), displayBoard, ia(Board,Move,Player), playMove(Board,Move,NewBoard,Player),applyIt(Board,NewBoard),changePlayer(Player,NextPlayer),play(NextPlayer).
play(Player) :- write('Player "'), write(Player), writeln('" can not play.'), changePlayer(Player,NextPlayer), play(NextPlayer).


%Fin de partie
%%When it is no longer possible for either player to move, the game is over.
gameover(Winner) :- not(moveAvailable('b')),not(moveAvailable('w')),board(Board),findWinner(Board,Winner).


%Trouver le gagnant, si quelqu'un a une meilleur soluce..
%%Permet de trouver qui a le plus de disque sur le plateau
countDisk([],[],'Draw').
countDisk([],L2,'w').
countDisk(L1,[],'b').
countDisk([X|L1],[Y|L2]],Winner) :- countDisk(L1,L2,Winner).

%Separe les disques blancs et noirs
%%L1 de longeur le nombre de disque noir
%%L2 de longeur le nombre de disque blanc
separate([],L1,L2).
separate(['b'|Board],['b'|L1],L2) :- separate(Board,L1,L2).
separate(['w'|Board],L1,['w'|L2]) :- separate(Board,L1,L2).
separate([E|Board],L1,L2) :- separate(Board,L1,L2).
%%separate([E|Board],L1,L2) :- var(E), separate(Board,L1,L2).

findWinner(Board,Winner) :- separate(Board,L1,L2), countDisk(L1,L2,Winner). 


%TODO
moveAvailable(_) :- 1 = 1.


%TODO
ia(Board,Move,Player).


%Ajoute le disque sur le plateau
%TODO retourne les disques encercles
playMove(Board,Move,NewBoard,Player):‐Board=NewBoard,nth0(Move,NewBoard,Player).


%Eregistre le plateau
applyIt(Board, NewBoard) :- retract(board(Board)),assert(board(NewBoard)).


%Permet de switch de joueur
changePlayer('b','w').
changePlayer('w','b').


%Affiche le plateau de jeu visuellementi
%%TODO voir le cours 
%%X = Ligne
%%Y = Colonne
displayBoard :- writeln('----------'),board(Board),displayRow(Board,0),writeln('----------').
displayRow(_,8).
displayRow(Board,X) :- displayCol(Board,X,0).
displayCol(Board,X,8) :- Y is X+1,writeln(''),displayRow(Board,Y).
displayCol([C|Board],X,Y) :- displayCell(C), Z is Y+1, displayCol(Board,X,Z).
displayCell(C) :- var(C), write('O').
displayCell(C) :- write(C).
