import Numeric

main :: IO ()
main = do
  putStrLn "DEPTH = 65536;"
  putStrLn "WIDTH = 16;"
  putStrLn "ADDRESS_RADIX = HEX;"
  putStrLn "DATA_RADIX = BIN;"
  putStrLn "CONTENT"
  putStrLn "BEGIN"
  interact $ unlines . countLines 0 . lines
  putStrLn "END;"

countLines :: Int -> [String] -> [String]
countLines count (s:ll) = (padLeft 4 '0' (showHex count "") ++ " : " ++ s ++ ";") : countLines (count+1) ll
countLines _     []     = []

padLeft :: Int -> a -> [a] -> [a]
padLeft tl p s
  | sl < tl = replicate (tl - sl) p ++ s
  | otherwise = s
  where
    sl = length s