# KMP String Search in Haskell

This project uses the Knuth-Morris-Pratt (KMP) algorithm to find every spot where a pattern shows up in a piece of text, without redoing a pile of pointless comparisons along the way.

I also wrote a simpler finite automaton search (called "Naive DFA" in the code) so there's something to compare KMP against. Both give the same answers. The difference is how long they take when things get ugly.

## What's in here

- `kmp.hs` - all the code, both algorithms and the interactive menu
- `benchmarks.txt` - results from a few worst-case runs (summarized below)

## How the two algorithms differ

**KMP** builds a small automaton array from the pattern once (a failure-style table), then walks through the text a single time. When a character doesn't match, it uses the table to fall back to the right spot in the pattern instead of starting over. That gives O(n + m) time, where n is the text length and m is the pattern length.

**Naive DFA** doesn't build anything ahead of time. Every time it needs the next state, it works it out on the spot by checking substrings of the pattern against each other when there's a mismatch. That's much more work per character, and it comes out to roughly O(n * m^2) in the worst case. It also leans on list indexing (`!!`), which doesn't help.

## How to run it

1. Load `kmp.hs` in `ghci` (or compile it with `ghc` or any other Haskell setup you like). It uses the `time` and `array` packages, which come with a normal GHC install.
2. Run `main`. It first asks you to type 1 or 2 to pick an algorithm:
    - 1 = Naive DFA
    - 2 = KMP
3. Then it asks what kind of input you want:
    - 1 = **Custom pattern/text**: you type a pattern and a text, and it searches for the pattern in the text.
    - 2 = **Worst-case performance test**: you give a pattern length (m) and a text length (n). It builds a pattern of m different letters starting at 'A' (A, B, C, ...) and a text that is just n copies of 'A'. Nothing ever fully matches, which is about as bad as it gets for the naive version.
4. Follow the prompts for whichever option you picked.
5. At the end you get the number of matches, the starting index of each match (if there are 20 or fewer, otherwise it just says there are too many to show), and the time taken in milliseconds.

Quick example:

```
ghci kmp.hs
ghci> main
```

A couple of small details: indexes start at 0, and an empty pattern counts as matching at every position, including the very end of the text.

## Benchmarks

These come from the worst-case test described above. The text is a long run of 'A' characters and the pattern is made of different letters, so there are 0 matches every time.

| Pattern length | Text length | Naive DFA | KMP | Roughly |
|----------------|-------------|-----------|-----|---------|
| 10 ("ABCDEFGHIJ") | 10,000 | 450.1 ms | 22.0 ms | KMP is about 20x faster |
| 20 ("ABCDEFGHIJKLMNOPQRST") | 100,000 | 25,276.3 ms | 209.7 ms | KMP is about 120x faster |

The gap gets bigger as the inputs grow, which is what you'd expect from the complexity difference. These are single runs on my own machine though, so treat the timings as ballpark numbers and not a rigorous benchmark.

## Notes

This was written as a learning project, so the focus was on getting both algorithms right and comparing them, not on squeezing out every last bit of speed.
