# KMP String Search in Haskell

This project uses the Knuth-Morris-Pratt (KMP) algorithm to find every position where a pattern shows up in a piece of text, without redoing a bunch of pointless comparisons along the way.

I also wrote a simpler finite automaton based search (I call it the "naive DFA" in the code and benchmarks) so there's something to compare KMP against. It gets the same answers, it just gets there a lot more slowly in the worst case.

## What's in here

- `kmp.hs` - all of the code, both algorithms included
- `benchmarks.txt` - results from some worst-case runs I did (see below)

## How to run it

1. Load `kmp.hs` in `ghci`, or use any other Haskell compiler you like.
2. Run the program. It will first ask you to type 1 or 2 to pick which algorithm to use.
3. Next it asks you to pick the kind of input by typing a number:
    - **Custom pattern/text**: you type in a pattern and a text, and it searches for the pattern in the text.
    - **Worst-case performance test**: runs a stress test built to hit the worst time complexity, which is handy for comparing the two algorithms.
4. Just follow the prompts for whichever option you chose.
5. If the pattern is found, you get back the starting index of each match, along with how long the search took.

A quick example with ghci:

```
ghci kmp.hs
ghci> main
```

(If your copy of the code uses a different entry point than `main`, run that instead.)

## Benchmarks

The numbers in `benchmarks.txt` come from the worst-case test. In every run the text is just a long list of 'A' characters and the pattern is a string of different letters, so nothing ever matches. That is a rough situation for the automaton approach, and KMP handles it much better.

| Pattern length | Text length | Naive DFA | KMP | Roughly |
|----------------|-------------|-----------|-----|---------|
| 10 ("ABCDEFGHIJ") | 10,000 | 450.1 ms | 22.0 ms | KMP is about 20x faster |
| 20 ("ABCDEFGHIJKLMNOPQRST") | 100,000 | 25,276.3 ms | 209.7 ms | KMP is about 120x faster |

Both algorithms found 0 matches in these tests, so the match list was empty each time.

Two things worth noting. The gap gets bigger as the pattern and text get longer, which is what you'd expect from the complexity difference. Also, these are just single runs on my own machine, so treat the timings as ballpark figures and not as a rigorous benchmark.

## Notes

This was written as a learning project, so the focus is on getting the algorithms right and comparing them, not on making the code as polished or fast as possible.