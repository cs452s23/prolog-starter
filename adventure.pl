% These are predicates.
:- dynamic location/2.
:- dynamic nextto/3.
:- dynamic over/1.

over(false).

% location / 2
% location(X, Y)
% X is in Y.
location(egg, duck_pen). 
location(ducks, duck_pen). 
location(fox, woods). 
location(you, house).

% nextto / 3
% Placement of locations
nextto(duck_pen, yard, closed).
nextto(yard, house, open).
nextto(yard, woods, open).

sym_nextto(X, Y, Z) :- nextto(X, Y, Z).
sym_nextto(X, Y, Z) :- nextto(Y, X, Z).

nearby :- 
    findall(Y, (location(you, X), sym_nextto(X, Y, _)), Z),
    write(Z), nl.
    
% Can move between two places if they
% are next to each other and open
connect(X, Y) :- sym_nextto(X, Y, open).

% Actions

% Can we build fast-travel via transitive connection?
goto(X) :-
    location(you, L),
    connect(L, X),
    retract(location(you, L)),
    assert(location(you, X)),
    write('You are in the '), write(X), nl.

goto(_) :-
    write("You can't get there from here."), nl.

openPen :-
    location(you, yard),
    retract(nextto(duck_pen, yard, _)), 
    assert(nextto(duck_pen, yard, open)).

closePen :-
    location(you, yard),
    retract(nextto(duck_pen, yard, _)), 
    assert(nextto(duck_pen, yard, closed)).

closeFence :-
    location(you, yard),
    retract(nextto(yard, woods, open)), 
    assert(nextto(yard, woods, closed)).

take(X) :-
    location(you, L),
    location(X, L),
    assert(you_have(X)).

fox :-
    location(ducks, yard),
    connect(yard, woods),
    assert(over(true)),
    write("The fox eats the ducks, you lose.").
fox.

you_have(self).

go :- done.
go :- over(true).
go :-
    help,
    write(">> "), nl,
    catch(read(X), _, (write('Bad action'), nl)),
    catch(call(X), E, (write(E), nl)),
    write(X), nl,
    ducks,
    fox,
    go.

% Actions
ducks :-
    location(ducks, duck_pen),
    location(you, duck_pen),
    connect(duck_pen, yard),
    retract(location(ducks, duck_pen)),
    assert(location(ducks, yard)),
    write("The ducks have run into the yard."), nl.
ducks.

done :-
    location(you, house),
    you_have(egg),
    write("Thanks for getting the egg."), nl.

%%% USAGE %%%
% Every location should have a usage

help :-
    location(you, X),
    usage(X).
help.

usage(house) :-
    write("You are in the house."), nl,
    write("Commands: goto/1, nearby/3"), nl.

usage(yard) :-
    write("You are in the yard."), nl,
    write("Commands: nearby, openPen, closeFence"), nl.

usage(woods) :-
    write("You are in the woods. There is a hostile fox. You want to go back to the yard."), nl,
    write("Commands: goto/1."), nl.
