--       _           _       _                             _
--   ___(_)_ __  ___| |_ ___(_)_ __    _ __  _   _ _______| | ___
--  / _ \ | '_ \/ __| __/ _ \ | '_ \  | '_ \| | | |_  /_  / |/ _ \
-- |  __/ | | | \__ \ ||  __/ | | | | | |_) | |_| |/ / / /| |  __/
--  \___|_|_| |_|___/\__\___|_|_| |_| | .__/ \__,_/___/___|_|\___|
--                                    |_|

-- Author: Vivek Ramadoss

-- Premise:

--  1. The Englishman lives in the red house.
--  2. The Swede keeps dogs.
--  3. The Dane drinks tea.
--  4. The green house is just to the left of the white one.
--  5. The owner of the green house drinks coffee.
--  6. The Pall Mall smoker keeps birds.
--  7. The owner of the yellow house smokes Dunhills.
--  8. The man in the center house drinks milk.
--  9. The Norwegian lives in the first house.
-- 10. The Blend smoker has a neighbor who keeps cats.
-- 11. The man who smokes Blue Masters drinks bier.
-- 12. The man who keeps horses lives next to the Dunhill smoker.
-- 13. The German smokes Prince.
-- 14. The Norwegian lives next to the blue house.
-- 15. The Blend smoker has a neighbor who drinks water.

-- Who keeps fish?

module EinsteinPuzzle where

import Data.List (isInfixOf)

data House = House
    { color :: Color
    , man   :: Man
    , drink :: Drink
    , smoke :: Smoke
    , pet   :: Pet
    }
    deriving (Eq, Show)

data Color = Red | Green | Blue | Yellow | White
    deriving (Eq, Show, Enum)

data Man = Eng | Swe | Dan | Nor | Ger
    deriving (Eq, Show, Enum)

data Drink = Coffee | Tea | Milk | Beer | Water
    deriving (Eq, Show, Enum)

data Smoke = PallMall | Dunhill | Blend | BlueMaster | Prince
    deriving (Eq, Show, Enum)

data Pet = Dog | Bird | Cat | Horse | Fish
    deriving (Eq, Show, Enum)

houses :: [House]
houses = [House c m d s p | c <- [Red ..], m <- [Eng ..], d <- [Coffee ..], s <- [PallMall ..], p <- [Dog ..]]

xnor :: Bool -> Bool -> Bool
xnor a b = (a || (not b)) && (b || (not a))

rules :: [(House -> Bool)]
rules = [
    \h -> ((man   h) == Eng   ) `xnor` ((color h) == Red),
    \h -> ((man   h) == Swe   ) `xnor` ((pet   h) == Dog),
    \h -> ((man   h) == Dan   ) `xnor` ((drink h) == Tea),
    \h -> ((color h) == Green ) `xnor` ((drink h) == Coffee),
    \h -> ((pet   h) == Bird  ) `xnor` ((smoke h) == PallMall),
    \h -> ((color h) == Yellow) `xnor` ((smoke h) == Dunhill),
    \h -> ((drink h) == Beer  ) `xnor` ((smoke h) == BlueMaster),
    \h -> ((man   h) == Ger   ) `xnor` ((smoke h) == Prince)
    ]

compRules :: [(House -> Bool)] -> House -> Bool
compRules [r] x = r x
compRules (r:rs) x = r x && (compRules rs x)

is :: Eq a => (House -> a) -> a -> House -> Bool
is get attr h = (get h) == attr

hasNeighbor :: (a -> Bool) -> (a -> Bool) -> [a] -> Bool
hasNeighbor p q (a:b:xs) = if (p a || q a) && (p b || q b) then True else hasNeighbor p q xs
hasNeighbor p q _ = False

positionalRules:: [House] -> Bool
positionalRules hs =
  [Green,White] `isInfixOf` map color hs &&
  hasNeighbor (smoke `is` Blend  ) (pet   `is` Cat  ) hs &&
  hasNeighbor (smoke `is` Dunhill) (pet   `is` Horse) hs &&
  hasNeighbor (color `is` Blue   ) (man   `is` Nor  ) hs &&
  hasNeighbor (smoke `is` Blend  ) (drink `is` Water) hs

eq :: House -> House -> Bool
eq (House a b c d e) (House f g h i j)
  | a == f = True
  | b == g = True
  | c == h = True
  | d == i = True
  | e == j = True
  | otherwise = False

uniq :: [House] -> Bool
uniq xs = length xs == length (aux xs)
  where aux [] = []
        aux (x:xs) = x:filter (\y -> (eq x y) == False) (aux xs)

r8 :: House -> Bool
r8 h = drink h == Milk

r9 :: House -> Bool
r9 h = man h == Nor

r14 :: House -> Bool
r14 h = color h == Blue

houses' :: [House]
houses' = filter (compRules rules) houses

solutions :: [[House]]
solutions = [ [h1, h2, h3, h4, h5] | h1 <- filter (compRules [(not . r8),        r9 , (not . r14)]) houses',
                                     h2 <- filter (compRules [(not . r8), (not . r9),        r14 ]) houses',
                                     h3 <- filter (compRules [       r8 , (not . r9), (not . r14)]) houses',
                                     h4 <- filter (compRules [(not . r8), (not . r9), (not . r14)]) houses',
                                     h5 <- filter (compRules [(not . r8), (not . r9), (not . r14)]) houses',
                                     let hs = [h1, h2, h3, h4, h5],
                                     uniq hs == True,
                                     positionalRules hs == True]

pprint :: House -> [Char]
pprint h = "House { \n\
           \  color = " ++ (show $ color h) ++ ", \n\
           \  man   = " ++ (show $ man   h) ++ ", \n\
           \  drink = " ++ (show $ drink h) ++ ", \n\
           \  smoke = " ++ (show $ smoke h) ++ ", \n\
           \  pet   = " ++ (show $ pet   h) ++ " \n}"

pprint2 :: House -> [Char]
pprint2 h = let c = show $ color h
                m = show $ man   h
                d = show $ drink h
                s = show $ smoke h
                p = show $ pet   h
            in "House { \
               \color = " ++ c ++ ", " ++ (replicate (6  - (length c)) ' ') ++ "\
               \man = "   ++ m ++ ", " ++ (replicate (3  - (length m)) ' ') ++ "\
               \drink = " ++ d ++ ", " ++ (replicate (6  - (length d)) ' ') ++ "\
               \smoke = " ++ s ++ ", " ++ (replicate (10 - (length s)) ' ') ++ "\
               \pet = "   ++ p ++ (replicate (5 - (length p)) ' ') ++ " }"

einsteinPuzzleStr :: [Char]
einsteinPuzzleStr = 
  "      _           _       _                             _       \n" ++
  "  ___(_)_ __  ___| |_ ___(_)_ __    _ __  _   _ _______| | ___  \n" ++
  " / _ \\ | '_ \\/ __| __/ _ \\ | '_ \\  | '_ \\| | | |_  /_  / |/ _ \\ \n" ++
  "|  __/ | | | \\__ \\ ||  __/ | | | | | |_) | |_| |/ / / /| |  __/ \n" ++
  " \\___|_|_| |_|___/\\__\\___|_|_| |_| | .__/ \\__,_/___/___|_|\\___| \n" ++
  "                                   |_|                          \n"

main :: IO ()
main = do 
          putStrLn einsteinPuzzleStr
          let sol = head solutions
          mapM_ (\(i,h) -> putStrLn $ (show i) ++ " " ++ pprint2 h) (zip [1..5] sol)
          putStrLn ""
