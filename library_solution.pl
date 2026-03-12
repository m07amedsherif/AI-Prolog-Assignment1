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

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Rule 4: List all ratings for a specific book as a list of tuples %%%%%%%%%%%%%%%%%%%%%%%%%%%%
ratings_of_book(Book, L) :-
    collect_ratings(Book, [], L), !.

collect_ratings(Book, Visited, [(Student, Score)|Rest]) :-
    rating(Student, Book, Score),
    not_member((Student, Score), Visited),
    collect_ratings(Book, [(Student, Score)|Visited], Rest).

collect_ratings(_, _, []).
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Rule 5: Find the top reviewer in the library %%%%%%%%%%%%%%%%%%%%%%%%%%%%
top_reviewer(Student) :-
    collect_all_ratings([], Ratings),
    top_reviewer_from_list(Ratings, Student), !.

collect_all_ratings(Visited, [(Student, Book, Score)|Rest]) :-
    rating(Student, Book, Score),
    not_member((Student, Book, Score), Visited),
    collect_all_ratings([(Student, Book, Score)|Visited], Rest).

collect_all_ratings(_, []).

top_reviewer_from_list([(Student, _, _)], Student).

top_reviewer_from_list([(S1, B1, Score1), (S2, B2, Score2)|Rest], Student) :-
    Score1 >= Score2,
    top_reviewer_from_list([(S1, B1, Score1)|Rest], Student).

top_reviewer_from_list([(S1, B1, Score1), (S2, B2, Score2)|Rest], Student) :-
    Score1 < Score2,
    top_reviewer_from_list([(S2, B2, Score2)|Rest], Student).
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Rule 6: Find the most common topic in books borrowed by a specific student %%%%%%%%%%%%%%%%%%%%%%%%%%%%
most_common_topic_for_student(Student, Topic) :-
    books_borrowed_by_student(Student, Books),
    collect_borrowed_topics(Books, AllTopics),
    collect_unique_topics(AllTopics, [], UniqueTopics),
    most_common_from_unique(UniqueTopics, AllTopics, Topic), !.

%% Collect all topics from all borrowed books into one big list
collect_borrowed_topics([], []).
collect_borrowed_topics([Book|RestBooks], AllTopics) :-
    topics(Book, BookTopics),
    collect_borrowed_topics(RestBooks, RestTopics),
    merge_lists(BookTopics, RestTopics, AllTopics).

%% Merge two lists manually
merge_lists([], L, L).
merge_lists([H|T], L, [H|Rest]) :-
    merge_lists(T, L, Rest).

%% Collect unique topics only once
collect_unique_topics([], _, []).
collect_unique_topics([Topic|Rest], Visited, [Topic|UniqueRest]) :-
    not_member(Topic, Visited),
    collect_unique_topics(Rest, [Topic|Visited], UniqueRest).

collect_unique_topics([Topic|Rest], Visited, UniqueRest) :-
    is_member(Topic, Visited),
    collect_unique_topics(Rest, Visited, UniqueRest).

%% Manual member check
is_member(X, [X|_]).
is_member(X, [_|T]) :-
    is_member(X, T).

%% Count how many times a topic appears
count_topic(_, [], 0).
count_topic(X, [X|T], N) :-
    count_topic(X, T, N1),
    N is N1 + 1.
count_topic(X, [H|T], N) :-
    X \= H,
    count_topic(X, T, N).

%% Find the most frequent topic among unique topics
most_common_from_unique([Topic], _, Topic).

most_common_from_unique([T1, T2 | Rest], AllTopics, Topic) :-
    count_topic(T1, AllTopics, C1),
    count_topic(T2, AllTopics, C2),
    C1 >= C2,
    most_common_from_unique([T1 | Rest], AllTopics, Topic).

most_common_from_unique([T1, T2 | Rest], AllTopics, Topic) :-
    count_topic(T1, AllTopics, C1),
    count_topic(T2, AllTopics, C2),
    C1 < C2,
    most_common_from_unique([T2 | Rest], AllTopics, Topic).
