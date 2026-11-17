{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}
{-# HLINT ignore "Use list comprehension" #-}
import Data.Time.Clock
import System.IO
import Control.Exception (evaluate)
import Data.Array

-------------------------------------------------------Naive DFA------------------------------------------------------------------
-- Compute next state by checking substring matches
nextState :: String -> Int -> Char -> Int
nextState w i c
    | i < m && (w !! i) == c = i + 1  -- Return next state in case of match
    | otherwise              = backtrack i
    where
        m = length w
        backtrack 0 = 0
        backtrack k = 
            if c == (w !! (k-1))      -- Go back iteratively until a letter matches to c
                && (k-1 == 0 
                            -- [0 .. k - 2] == [i - (k - 1) .. i]
                || and [ w !! (i - k + 1 + j) == w !! j | j <- [0 .. k-2] ]) 
            then k
            else backtrack (k-1)

-- Main naive DFA matching function
naiveDFA :: String -> String -> [Int]
naiveDFA w text = 
    let m = length w
        search i j 
            | j == length text = []
            | otherwise        = 
                let newState = nextState w i (text !! j)
                    matches = if newState == m then [j - m + 1] else []
                in matches ++ search newState (j+1)
    in search 0 0

-------------------------------------------------------Optimized KMP-------------------------------------------------------------------------------
-- Takes input:
-- Pattern array - w_arr
-- Automaton array - a_arr
-- Current Index of pattern - i
-- Current Letter of string - x
step :: Array Int Char -> Array Int Int -> Int -> Char -> Int
step w_arr a_arr i x
    | i < n && w_arr ! i == x = i + 1                           -- Current pattern letter == current letter of string = return next pattern index
    | i == 0                  = 0                               -- Return 0 if no letter matches after backtracking all the way
    | otherwise               = step w_arr a_arr (a_arr ! i) x  -- Otherwise backtrack pattern index using automaton and recurse
    where n = snd (bounds a_arr)                                -- Upper bound of automaton (pattern length)

-- Constructs automaton based on pattern
automaton :: [Char] -> Array Int Int
automaton w 
    | null w    = array (0,0) [(0,0)]  -- Handle empty pattern
    | otherwise = a
    where
        n = length w
        w_arr = listArray (0, n - 1) w
        a = array (0, n) $ 
                -- Construct automaton array by using step function for each element
                -- First two elements lead to the beginning always
                (0,0) : (1,0) : [ (j, step w_arr a (a ! (j - 1)) (w_arr ! (j - 1))) | j <- [2..n] ]

-- Main KMP function
kmp :: String -> String -> [Int]
kmp w str
    | null w   = [0..length str]  -- Empty pattern matches everywhere
    | otherwise = 
        let n = length w
            a_arr = automaton w
            w_arr = listArray (0, n-1) w
            m = length str
            text = listArray (0, m-1) str
            helper :: Int -> Int -> [Int]
            helper i j
                | j == m    = []
                | otherwise = 
                    let newI = step w_arr a_arr i (text ! j)
                    in if newI == n -- then pattern matched
                       then (j - n + 1) : helper (a_arr ! newI) (j + 1) -- add found index to list and recurse
                       else helper newI (j + 1)
        in helper 0 0

-------------------------------------------------------Timing and Comparison-----------------------------------------------------------------------
-- Time a matching algorithm and return results with duration
timeAlgorithm :: (String -> String -> [Int]) -> String -> String -> IO ([Int], Double)
timeAlgorithm algo pattern text = do
    start <- getCurrentTime
    result <- evaluate (algo pattern text)  -- Force evaluation for accurate timing
    end <- getCurrentTime
    let duration = realToFrac (diffUTCTime end start) * 1000  -- Convert to milliseconds
    return (result, duration)

-- Interactive test menu
main :: IO ()
main = do
    putStrLn "String Matching Algorithm Comparison"
    putStrLn "------------------------------------"
    
    -- Algorithm selection
    putStrLn "Choose algorithm:"
    putStrLn "1: Naive DFA (O(n·m²) - slower)"
    putStrLn "2: KMP (O(n+m) - faster)"
    putStr "Enter choice (1-2): "
    hFlush stdout
    algoChoice <- getLine
    
    let algo = case algoChoice of
                "1" -> naiveDFA
                "2" -> kmp
                _   -> error "Invalid algorithm choice"

    -- Input type selection
    putStrLn "\nChoose input type:"
    putStrLn "1: Custom pattern/text"
    putStrLn "2: Worst-case performance test (all 'A's)"
    putStr "Enter choice (1-2): "
    hFlush stdout
    inputChoice <- getLine
    
    (pattern, text) <- case inputChoice of
        "1" -> do
            putStr "Enter pattern: "
            hFlush stdout
            pattern <- getLine
            putStr "Enter text: "
            hFlush stdout
            text <- getLine
            return (pattern, text)
        "2" -> do
            putStr "Enter pattern length (m): "
            hFlush stdout
            m <- readLn
            putStr "Enter text length (n): "
            hFlush stdout
            n <- readLn
            
            -- Generate pattern with unique characters
            let pattern = take m ['A'..]
            -- Generate text with duplciate characters
            let text = replicate n 'A'
            
            putStrLn $ "Generated pattern: " ++ pattern
            putStrLn $ "Generated text: " ++ (if n <= 20 then text else take 20 text ++ "...")
            
            -- Estimate operations
            let opsEstimate = if algoChoice == "1" 
                            then fromIntegral n * fromIntegral m * fromIntegral m 
                            else fromIntegral n + fromIntegral m
            putStrLn $ "Estimated operations: " ++ show opsEstimate ++ 
                        (if algoChoice == "1" then " (O(n·m²))" else " (O(n+m))")
            return (pattern, text)
        _ -> error "Invalid input choice"

    putStrLn $ "\nUsing pattern: " ++ show pattern
    putStrLn $ "Text length: " ++ show (length text)
    putStrLn $ "Algorithm: " ++ (if algoChoice == "1" then "Naive DFA" else "KMP")

    -- Execute with timing
    (matches, duration) <- timeAlgorithm algo pattern text
    let count = length matches

    -- Display results
    putStrLn $ "\nMatches found: " ++ show count
    if count <= 20
        then putStrLn $ "Match positions: " ++ show matches
        else putStrLn "Match positions: [too many to display]"
    
    putStrLn $ "Time taken: " ++ show duration ++ " ms"
    
    return ()