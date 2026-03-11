%%%%%%%%%%%%%%%%%%%%%%%%%%%% Rule 1: Books borrowed by a student %%%%%%%%%%%%%%%%%%%%%%%%%%%%
books_borrowed_by_student(Student, L) :-
    collect_books(Student, [], L).

collect_books(Student, Visited, [Book|Rest]) :-
    borrowed(Student, Book),
    not_member(Book, Visited),
    collect_books(Student, [Book|Visited], Rest).

collect_books(_, _, []).

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Rule 2: Number of borrowers for a book %%%%%%%%%%%%%%%%%%%%%%%%%%%%
borrowers_count(Book, N) :-
    collect_students(Book, [], L),
    list_length(L, N).

collect_students(Book, Visited, [Student|Rest]) :-
    borrowed(Student, Book),
    not_member(Student, Visited),
    collect_students(Book, [Student|Visited], Rest).

collect_students(_, _, []).

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Rule 3: Most borrowed book %%%%%%%%%%%%%%%%%%%%%%%%%%%%
most_borrowed_book(B) :-
    collect_books_list([], Books),
    most_borrowed_from_list(Books, B).

%% Collect all books from the database (no duplicates)
collect_books_list(Visited, [Book|Rest]) :-
    book(Book, _),
    not_member(Book, Visited),
    collect_books_list([Book|Visited], Rest).

collect_books_list(_, []).

%% Find the book with the maximum number of borrowers
most_borrowed_from_list([Book], Book).

most_borrowed_from_list([B1, B2 | Rest], Max) :-
    borrowers_count(B1, N1),
    borrowers_count(B2, N2),
    N1 >= N2,
    most_borrowed_from_list([B1 | Rest], Max).

most_borrowed_from_list([B1, B2 | Rest], Max) :-
    borrowers_count(B1, N1),
    borrowers_count(B2, N2),
    N1 < N2,
    most_borrowed_from_list([B2 | Rest], Max).

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Helper predicates %%%%%%%%%%%%%%%%%%%%%%%%%%%%
list_length([], 0).
list_length([_|T], N) :-
    list_length(T, N1),
    N is N1 + 1.

not_member(_, []).
not_member(X, [H|T]) :-
    X \= H,
    not_member(X, T).

%% Rule 4
most_borrowed_from_list([B], B).
most_borrowed_from_list([B1,B2|Rest], Max) :-
    borrowers_count(B1, N1),
    borrowers_count(B2, N2),
    (N1 >= N2 ->
        most_borrowed_from_list([B1|Rest], Max)
    ;
        most_borrowed_from_list([B2|Rest], Max)
    ).

ratings_of_book(Book, L) :-
    findall((Student,Score), rating(Student, Book, Score), L).

top_reviewer(Student) :-
    setof(Score-S, B^rating(S,B,Score), List),
    last(List, _MaxScore-Student).

most_common_topic_for_student(Student, Topic) :-
    books_borrowed_by_student(Student, Books),
    collect_topics(Books, Topics),
    flatten(Topics, AllTopics),
    most_frequent(AllTopics, Topic).

collect_topics([], []).
collect_topics([B|Rest], [T|RT]) :-
    topics(B, T),
    collect_topics(Rest, RT).

most_frequent(List, Topic) :-
    setof(X, member(X, List), Unique),
    most_frequent_from_list(Unique, List, Topic).

most_frequent_from_list([T], _, T).
most_frequent_from_list([T1,T2|Rest], List, Max) :-
    count(T1, List, C1),
    count(T2, List, C2),
    (C1 >= C2 ->
        most_frequent_from_list([T1|Rest], List, Max)
    ;
        most_frequent_from_list([T2|Rest], List, Max)
    ).

count(_, [], 0).
count(X, [X|T], N) :-
    count(X, T, N1),
    N is N1 + 1.
count(X, [_|T], N) :-
    count(X, T, N).
