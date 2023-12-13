import Data.Char (isDigit)
import System.Environment (getArgs)

main :: IO ()
main = do
  [input] <- getArgs
  solve input

solve :: String -> IO ()
solve filepath = do
  input <- lines <$> readFile filepath

  let seedNumbers = map (read :: String -> Integer) . tail . words . head $ input
  let seeds = map (\x -> mkRange x (x + 1)) seedNumbers
  let megaSeeds = parseMegaSeeds seedNumbers

  let rangeMappers = map applyRangeMaps . parseRangeMaps . tail $ input
  let applyRangeMappers x = minimum . map (\(Range (x, _)) -> x) . foldr (=<<) x $ rangeMappers

  putStr "Result 1: "
  print . applyRangeMappers $ seeds

  putStr "Result 2: "
  print . applyRangeMappers $ megaSeeds

newtype Range = Range (Integer, Integer)

mkRange :: Integer -> Integer -> Range
mkRange l r
  | l < r = Range (l, r)
  | otherwise = error "Malformed Range"

newtype RangeMap = RangeMap (Integer, Range)

parseMegaSeeds :: [Integer] -> [Range]
parseMegaSeeds xss
  | (l : r : xs) <- xss = mkRange l (l + r) : parseMegaSeeds xs
  | otherwise = []

parseRangeMaps :: [String] -> [[RangeMap]]
parseRangeMaps = foldl gatherRangeMaps []
  where
    gatherRangeMaps :: [[RangeMap]] -> String -> [[RangeMap]]
    gatherRangeMaps acc "" = acc
    gatherRangeMaps acc str@(x : _)
      | False <- isDigit x = [] : acc
      | [new, old, width] <- map read . words $ str = (RangeMap (new - old, mkRange old (old + width)) : head acc) : tail acc
      | otherwise = error "Failed to parse maps"

rangeIntersect :: Range -> Range -> Maybe Range
rangeIntersect (Range (lx, ly)) (Range (rx, ry)) =
  let x = max lx rx
      y = min ly ry
   in if x < y then Just $ Range (x, y) else Nothing

rangeSubtract :: Range -> Range -> [Range]
rangeSubtract (Range (ogx, ogy)) (Range (subx, suby)) =
  let l = mkRange ogx subx
      r = mkRange suby ogy
   in case (subx <= ogx, ogy <= suby) of
        (True, True) -> []
        (True, False) -> [r]
        (False, True) -> [l]
        (False, False) -> [l, r]

rangeShift :: Range -> Integer -> Range
rangeShift (Range (l, r)) x = Range (l + x, r + x)

applyRangeMaps :: [RangeMap] -> Range -> [Range]
applyRangeMaps [] range = [range]
applyRangeMaps ((RangeMap (shift, oldrange)) : maps) range
  | Just intrx <- rangeIntersect oldrange range = rangeShift intrx shift : (rangeSubtract range oldrange >>= applyRangeMaps maps)
  | otherwise = applyRangeMaps maps range
