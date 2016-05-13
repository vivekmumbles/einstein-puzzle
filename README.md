# Einstein's Puzzle

## Background

The Einstein's Puzzle also known as the Zebra Puzzle is a constraint satisfaction problem. There are accounts that state that Albert Einstein claimed that only 2 percent of people are capable of solving it.

## Puzzle 

The puzzle is the following. Let us assume that there are five houses of different colors next to each other on the same road. In each house lives a man of a different nationality. Every man has his favorite drink, his favorite brand of cigarettes, and keeps pets of a particular kind. Next we are given the following 15 statements.

1. The Englishman lives in the red house.
2. The Swede keeps dogs.
3. The Dane drinks tea.
4. The green house is just to the left of the white one.
5. The owner of the green house drinks coffee.
6. The Pall Mall smoker keeps birds.
7. The owner of the yellow house smokes Dunhills.
8. The man in the center house drinks milk.
9. The Norwegian lives in the first house.
10. The Blend smoker has a neighbor who keeps cats.
11. The man who smokes Blue Masters drinks bier.
12. The man who keeps horses lives next to the Dunhill smoker.
13. The German smokes Prince.
14. The Norwegian lives next to the blue house.
15. The Blend smoker has a neighbor who drinks water.

Assuming all of these statements are true, who keeps fish as a pet?

## Discussion of Approaches

From the problem statment we can see that there are 5 variables each with 5 possible assignments, generating a total of 5^5 = 3125 possible variations. Then all permutations of size 5 would be 3125^5 ~= 3e17. This is too large of a number to brute force and try all the possibilities.

A common approach to solving constraint satisfaction problems using imperative programming languages is backtracking. Backtracking **alone** is not very useful and essentially becomes a bruteforce search, but if we are able to prune/filter the search space we can greatly reduce the amount of candidates we must verify. In the solution we give we use this pruning/filtering idea and couple it with the lazy nature of Haskell to solve the problem.

The paper [_Escape from Zurg: An Exercise in Logic Programming_](https://web.engr.oregonstate.edu/~erwig/papers/Zurg_JFP04.pdf) describes how one can use the lazy nature of Haskell to solve search problems. The paper describes a framework for solving search problems and uses the Escape for Zurg problem, also known as the Bridge and Torch Problem, as an example to demonstrate. The method they propose is creating a search space of different possible states as a list in either a breadth-first or depth-first manneer and filtering them to find the solution. Because Haskell is lazy, only the states that statisfy the filtering constraints will be searched. This allows the programmer to do backtracking with pruning implicitly.

The solution given in this repository is similar to [_Escape from Zurg: An Exercise in Logic Programming_](https://web.engr.oregonstate.edu/~erwig/papers/Zurg_JFP04.pdf) paper, in that it also exploit Haskell's laziness to filter out the bad solutions. The main difference between the two approaches is that the Einstein Puzzle lacks transitions to different states like the Bridge and Torch Problem. In the Bridge and Torch Problem each time a person crosses a bridge we enter a new state. In the Einstein Puzzle there is no explicit transitions. Either the current state is the solution or it is not. The backtracking the Einstein Puzzle if of the form, for lack a better term, nested for-loops (we used list comprehensions in Haskell). Conceptually each loop attempts to make a variable assignment, and when a loop fails to find a valid assignment it drops back to the previous loop. Therefore there are five loops, but since we filter out invalid assignments we greatly reduce the search space.

Most of the work when implementing this solution was creating the data structures and functions for the constraints listed above. The code for finding the solution is actually quite short. The difficulties that arose when implementing the solution in Haskell was determining how much filtering needed to be done and at what stage. Initally I had generated a list of all possible solutions with nearly 3e17 elements. Again this was only possible because of Haskell's lazy evaluation. I then tried to filter the solutions by the listed constraints. This was a brute force solution that never terminated. Next instead of generating a list of all possible solutions, I generated a list of all possible assignments and filtered them by the constraints. This required xnoring the constraints since we were filtering the possible assignments and not possible solutions. If we did not xnor the constraints the resulting list would be empty since no single assignment would be able to satisfy all 15 constraints. Now when I tried filtering all possible solutions with the filtered assignments it was still taking too long to finish. The last step I took was adding filtering based on the locations of the variable assignments before filtering the solutions. This required actual insight into the constraints listed above. For example by rules 8 and 9 state:

> 8\. The man in the center house drinks milk.

> 9\. The Norwegian lives in the first house.

Therefore the first house must belong to a Norwegian who does not drink milk. Once we similarly apply this strategy of filters to the other house positions we were able to find the solution within a few seconds.

## Conclusion

After implementing this problem in Haskell I would find it tedious to implement it in another language. The laziness in Haskell allows the programmer to write solutions to backtracking problems by essentially just running filters on the list of possibilities.
