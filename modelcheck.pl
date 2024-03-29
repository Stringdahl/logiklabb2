% For SICStus, uncomment line below: (needed for member/2)
%:- use_module(library(lists)).

verify(Input) :-
	see(Input), read(T), read(L), read(S), read(F), seen,
	check(T, L, S, [], F).

% check(T, L, S, U, F)
% T - The transitions in form of adjacency lists
% L - The labeling
% S - Current state
% U - Currently recorded states
% F - CTL Formula to check.
%
% Should evaluate to true iff the sequent below is valid.
%
% (T,L), S |- F
% U
% To execute: consult(’your_file.pl’). verify(’input.txt’).

% Literals - check for the state S and its axiom list that is does contain X
check(_, L, S, [], X) :-
	member([S,Z],L), 
	member(X, Z).

%neg(X) - check for the state S and its axiom list that is does NOT contain X
check(_, L, S, [], neg(X)) :-
	member([S,Z],L), 
	\+ member(X, Z).

% And - check for the state S and its axiom list if F AND G is valid
check(T, L, S, [], and(F,G)) :-
	check(T, L, S, [], F),
	check(T, L, S, [], G).

% Or - check for the state S and its axiom list if F OR G is valid
check(T, L, S, [], or(F,G)) :- 
	check(T, L, S, [], F);
	check(T, L, S, [], G).

% AX F - all next states satisfies F
check(T, L, S, [], ax(F)) :-
	member([S, Z], T), % Fetch list Z of neighbors to S from tranistions T
	check_all(T, L, Z, [], F, F). % Check for all neighbours Z

% AG F - F is satisfied in every future state
% Success if loop is found
check(T, L, S, U, ag(F)):-
	member(S, U).
check(T, L, S, U, ag(F)) :-
	\+ member(S, U),
	check(T, L, S, [], F), % check if true in current state S
	member([S, Z], T), % Fetch list Z of neighbors to S from tranistions T
	check_all(T, L, Z, [S|U], F, ag(F)). % Check for all neighbours Z, Add S to recorded states U

% AF F - all paths will satisfy F eventually
% Fail if loop found
check(T, L, S, U, af(F)):-
	\+ member(S, U),
	check(T, L, S, [], F).

check(T, L, S, U, af(F)) :- % check if true in current state S
	\+ member(S, U),
	member([S, Z], T), % Fetch list Z of neighbors to S from tranistions T
	check_all(T, L, Z, [S|U], F, af(F)). % Check for all neighbours Z, Add S to recorded states U

% EG - check if some path will always satisfy F
check(T, L, S, U, eg(F)):-
	member(S, U).
check(T, L, S, U, eg(F)) :-
	\+ member(S, U),
	check(T, L, S, [], F), % check if true in current state S
	member([S, Z], T), % Fetch list Z of neighbors to S from tranistions T
	check_exist(T, L, Z, [S|U], F, eg(F)). % Check for all neighbours Z, Add S to recorded states U
	

% EF F - some path will satisfy F eventually
check(T, L, S, U, ef(F)):-
	\+ member(S, U),
	check(T, L, S, [], F). % check if true in current state S
check(T, L, S, U, ef(F)) :-
	\+ member(S, U),
	member([S, Z], T), % Fetch list Z of neighbors to S from tranistions T
	check_exist(T, L, Z, [S|U], F, ef(F)). % Check for all neighbours Z, Add S to recorded states U

% EX F - some next state will satify F
check(T, L, S, [], ex(F)) :-
	member([S, Z], T), % Fetch list Z of neighbors to S from tranistions T
	check_exist(T, L, Z, [], F, F). % Check for all neighbours Z

% Help predicate for A-formulas
check_all(_,_,[],_,_,_). % All neighbours check
check_all(T, L, [H|TAIL], U, X, A) :-
	check(T, L, H, U, A), % True in the head H of the neighbour list
	check_all(T, L, TAIL, U, X, A). %True in the TAIL of the neighbour list

% Help predicate for E-formulas
check_exist(_,_,[],_,_,_):- fail. %Fails if list is empty
check_exist(T, L, [H|TAIL], U, X, A) :-
	check(T, L, H, U, A); %True and the head H of the neighbour list
	check_exist(T, L, TAIL, U, X, A). % or true in the TAIL of the neighbour list
