%%%%%%%%%%%%%%%%%%%%%%%%%%%% Library Solution in Prolog %%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Rule 1
books_borrowed_by_student(Student, L) :-
    findall(Book, borrowed(Student, Book), L).

%% Rule 2
borrowers_count(Book, N) :-
    findall(Student, borrowed(Student, Book), L),
    length(L, N).

%% Rule 3
most_borrowed_book(B) :-
    setof(Book, Author^book(Book, Author), Books),
    most_borrowed_from_list(Books, B).

most_borrowed_from_list([B], B).
most_borrowed_from_list([B1,B2|Rest], Max) :-
    borrowers_count(B1, N1),
    borrowers_count(B2, N2),
    (N1 >= N2 ->
        most_borrowed_from_list([B1|Rest], Max)
    ;
        most_borrowed_from_list([B2|Rest], Max)
    ).

%% Rule 4
ratings_of_book(Book, L) :-
    findall((Student,Score), rating(Student, Book, Score), L).

%% Rule 5
top_reviewer(Student) :-
    setof(Score-S, B^rating(S,B,Score), List),
    last(List, _MaxScore-Student).

%% Rule 6
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
