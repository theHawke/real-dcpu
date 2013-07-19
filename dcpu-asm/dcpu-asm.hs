import Data.Int
import Data.Word
import Data.Char
import Data.List

safeTail :: [a] -> [a]
safeTail (_:xs) = xs
safeTail []     = []

data Line = Empty | Label String | Data [Int16] | Instr Word8 Operand Operand | SpInstr Word8 Operand deriving (Show)

data Operand = Reg GPReg | MemReg GPReg | MemRegOffs GPReg Value | PushPop | Peek | PickN Value | SP | PC | EX | Mem Value | Lit Value deriving (Show)

data Value = VLabel String | VInt Int16 deriving (Show)

data GPReg = A | B | C | X | Y | Z | I | J deriving (Enum,Show)

type Token = String

specialToken :: Char -> Bool
specialToken = flip elem ":[],;+-"

isSpecialInstruction :: Token -> Bool
isSpecialInstruction = flip elem ["JSR","INT","IAG","IAS","RFI","IAQ","HWN","HWQ","HWI"]

opcode :: Token -> Maybe Word8
opcode = flip lookup [("SET",1),("ADD",2),("SUB",3),("MUL",4),("MLI",5),("DIV",6),("DVI",7),("MOD",8),("MDI",9),("AND",10),("BOR",11),("XOR",12),("SHR",13),("ASR",14),("SHL",15),
                      ("IFB",16),("IFC",17),("IFE",18),("IFN",19),("IFG",20),("IFA",21),("IFL",22),("IFU",23),("ADX",26),("SBX",27),("STI",30),("STD",31)]

spOpcode :: Token -> Maybe Word8
spOpcode = flip lookup [("JSR",1),("INT",8),("IAG",9),("IAS",10),("RFI",11),("IAQ",12),("HWN",16),("HWQ",17),("HWI",18)]

tokenise :: String -> [Token]
tokenise str = tokenise' [] str
tokenise' :: String -> String -> [Token]
tokenise' acc (c:s)
  | specialToken c = if null acc then [c] : (tokenise' [] s) else (reverse acc) : [c] : (tokenise' [] s)
  | isSpace c      = if null acc then tokenise' [] s else (reverse acc) : (tokenise' [] s)
  | otherwise      = tokenise' (c:acc) s
tokenise' acc [] = [reverse acc]

analyseLine :: [Token] -> Line
analyseLine tokens =
  if null tkns then
    Empty
  else if op == ":" then
    if (length tkns) /= 2 then
      error $ "Error: too many tokens on a line with a label: \"" ++ (intercalate " " tkns) ++ "\""
    else
      Label (tkns !! 1)
  else if (map toUpper op) == "DAT" then
    Data (map (read :: String -> Int16) $ filter (/= ",") operands)
  else if isSpecialInstruction op then
    case spOpcode op of
      Nothing -> error $ "Error: invalid opcode: \"" ++ (intercalate " " tkns) ++ "\""
      Just a  -> SpInstr a operand1
  else
    case opcode op of
      Nothing -> error $ "Error: invalid opcode: \"" ++ (intercalate " " tkns) ++ "\""
      Just a  -> Instr a operand1 operand2
  where
    tkns = filter (/= "") $ takeWhile (/= ";") tokens
    operands = tail tkns
    op = head tkns
    operand1 = parseOperand $ takeWhile (/= ",") operands
    operand2 = parseOperand $ safeTail $ dropWhile (/= ",") operands

parseOperand tkns
  | null tkns = error "Error: No Operand"
  | length tkns == 1 = case map toUpper $ head tkns of
    "A"    -> Reg A
    "B"    -> Reg B
    "C"    -> Reg C
    "X"    -> Reg X
    "Y"    -> Reg Y
    "Z"    -> Reg Z
    "I"    -> Reg I
    "J"    -> Reg J
    "PUSH" -> PushPop
    "POP"  -> PushPop
    "PEEK" -> Peek
    "SP"   -> SP
    "PC"   -> PC
    "EX"   -> EX
    _      -> case (reads (head tkns) :: [(Int16,String)]) of
      (a,""):[] -> Lit (VInt a)
      _         -> Lit (VLabel (head tkns))
  | length tkns == 2 =
    if head tkns == "PICK" then
      case (reads (tkns !! 1) :: [(Int16,String)]) of
        (a,""):[] -> PickN (VInt a)
        _         -> PickN (VLabel (head tkns))
    else if head tkns == "-" then
      case (reads (tkns !! 1) :: [(Int16,String)]) of
        (a,""):[] -> Lit (VInt (-a))
        _         -> error $ "Error: Can't use minus sign (-) with label: " ++ (intercalate " " tkns) ++ "\""
    else
      error $ "Error: Invalid Operand: " ++ (intercalate " " tkns) ++ "\""
  | head tkns == "[" && last tkns == "]" = case init $ tail tkns of
    ["A"]          -> MemReg A
    ["B"]          -> MemReg B
    ["C"]          -> MemReg C
    ["X"]          -> MemReg X
    ["Y"]          -> MemReg Y
    ["Z"]          -> MemReg Z
    ["I"]          -> MemReg I
    ["J"]          -> MemReg J
    ["-","-","SP"] -> PushPop
    ["SP","+","+"] -> PushPop
    ["SP"]         -> Peek
    ["A","+",nw]   -> case (reads nw :: [(Int16,String)]) of
                        (a,""):[] -> MemRegOffs A (VInt a)
                        _         -> MemRegOffs A (VLabel nw)
    ["B","+",nw]   -> case (reads nw :: [(Int16,String)]) of
                        (a,""):[] -> MemRegOffs B (VInt a)
                        _         -> MemRegOffs B (VLabel nw)
    ["C","+",nw]   -> case (reads nw :: [(Int16,String)]) of
                        (a,""):[] -> MemRegOffs C (VInt a)
                        _         -> MemRegOffs C (VLabel nw)
    ["X","+",nw]   -> case (reads nw :: [(Int16,String)]) of
                        (a,""):[] -> MemRegOffs X (VInt a)
                        _         -> MemRegOffs X (VLabel nw)
    ["Y","+",nw]   -> case (reads nw :: [(Int16,String)]) of
                        (a,""):[] -> MemRegOffs Y (VInt a)
                        _         -> MemRegOffs Y (VLabel nw)
    ["Z","+",nw]   -> case (reads nw :: [(Int16,String)]) of
                        (a,""):[] -> MemRegOffs Z (VInt a)
                        _         -> MemRegOffs Z (VLabel nw)
    ["I","+",nw]   -> case (reads nw :: [(Int16,String)]) of
                        (a,""):[] -> MemRegOffs I (VInt a)
                        _         -> MemRegOffs I (VLabel nw)
    ["J","+",nw]   -> case (reads nw :: [(Int16,String)]) of
                        (a,""):[] -> MemRegOffs J (VInt a)
                        _         -> MemRegOffs J (VLabel nw)
    ["SP","+",nw]  -> case (reads nw :: [(Int16,String)]) of
                        (a,""):[] -> PickN (VInt a)
                        _         -> PickN (VLabel nw)
    [nw]           -> case (reads nw :: [(Int16,String)]) of
                        (a,""):[] -> Mem (VInt a)
                        _         -> Mem (VLabel nw)
    ["-",nw]           -> case (reads nw :: [(Int16,String)]) of
                        (a,""):[] -> Mem (VInt (-a))
                        _         -> error $ "Error: Can't use minus sign (-) with label: " ++ (intercalate " " tkns) ++ "\""
    _              -> error $ "Error: Invalid operand: \"" ++ (intercalate " " tkns) ++ "\""
  | otherwise = error $ "Error: Invalid operand: \"" ++ (intercalate " " tkns) ++ "\""

buildLabelTable :: [Line] -> [(String,Int16)]
buildLabelTable lines = buildLabelTable' 0 lines

buildLabelTable' :: Int16 -> [Line] -> [(String,Int16)]
buildLabelTable' ln (Empty : ll)         = buildLabelTable' ln ll
buildLabelTable' ln ((Label s) : ll)     = (s,ln) : (buildLabelTable' ln ll)
buildLabelTable' ln ((Data ds) : ll)     = buildLabelTable' (ln + (fromIntegral $ length ds)) ll
buildLabelTable' ln ((Instr _ b a) : ll) = buildLabelTable' (ln + 1 + (operandLength False b) + (operandLength True a)) ll
buildLabelTable' ln ((SpInstr _ a) : ll) = buildLabelTable' (ln + 1 + (operandLength  True a)) ll
buildLabelTable' _  []                   = []

operandLength :: Bool -> Operand -> Int16
operandLength _ (MemRegOffs _ _) = 1
operandLength _ (PickN _)        = 1
operandLength _ (Mem _)          = 1
operandLength _ (Lit (VLabel _)) = 1
operandLength a (Lit (VInt v))   = if -1 <= v && v <= 30 && a then 0 else 1
operandLength _ _                = 0

intToBinary :: Int16 -> String
intToBinary a = wordToBinary ((fromIntegral a) :: Word16)

wordToBinary :: Word16 -> String
wordToBinary a = wordToBinary' [] a

wordToBinary' :: String -> Word16 -> String
wordToBinary' acc 0 = acc
wordToBinary' acc a = wordToBinary' (rc:acc) q
  where
    (q,r) = quotRem a 2
    rc = if r == 1 then '1' else '0'

padLeft :: Int -> a -> [a] -> [a]
padLeft tl p s
  | sl < tl = replicate (tl - sl) p ++ s
  | otherwise = s
  where
    sl = length s

buildLine :: [(String,Int16)] -> Line -> [String]
buildLine labelTable Empty           = []
buildLine labelTable (Label s)       = []
buildLine labelTable (Data is)       = map (padLeft 16 '0' . intToBinary) is
buildLine labelTable (Instr i o1 o2) = [(operandToString True o2) ++ (operandToString False o1) ++ (padLeft 5 '0' $ wordToBinary $ fromIntegral i)] ++ (nextWordString True labelTable o2) ++ (nextWordString False labelTable o1)
buildLine labelTable (SpInstr i o)   = [(operandToString True o) ++ (padLeft 5 '0' $ wordToBinary $ fromIntegral i) ++ "00000"] ++ (nextWordString True labelTable o)

operandToString :: Bool -> Operand -> String
operandToString a op = if a then padLeft 6 '0' opTS else opTS
  where opTS = operandToString' a op

operandToString' :: Bool -> Operand -> String
operandToString' _     (Reg r)          = "00" ++ (padLeft 3 '0' $ wordToBinary $ fromIntegral $ fromEnum r)
operandToString' _     (MemReg r)       = "01" ++ (padLeft 3 '0' $ wordToBinary $ fromIntegral $ fromEnum r)
operandToString' _     (MemRegOffs r _) = "10" ++ (padLeft 3 '0' $ wordToBinary $ fromIntegral $ fromEnum r)
operandToString' _     PushPop          = "11000"
operandToString' _     Peek             = "11001"
operandToString' _     (PickN _)        = "11010"
operandToString' _     SP               = "11011"
operandToString' _     PC               = "11100"
operandToString' _     EX               = "11101"
operandToString' _     (Mem _)          = "11110"
operandToString' _     (Lit (VLabel _)) = "11111"
operandToString' False (Lit (VInt _))   = "11111"
operandToString' True  (Lit (VInt i))   = if -1 <= i && i <= 30 then '1' : (padLeft 5 '0' $ intToBinary (i+1)) else "11111"

nextWordString :: Bool -> [(String,Int16)] -> Operand -> [String]
nextWordString _ labelTable (MemRegOffs _ (VLabel s)) = [padLeft 16 '0' $ intToBinary $ lookupLabel s labelTable]
nextWordString _ _          (MemRegOffs _ (VInt i))   = [padLeft 16 '0' $ intToBinary i]
nextWordString _ labelTable (PickN (VLabel s))        = [padLeft 16 '0' $ intToBinary $ lookupLabel s labelTable]
nextWordString _ _          (PickN (VInt i))          = [padLeft 16 '0' $ intToBinary i]
nextWordString _ labelTable (Mem (VLabel s))          = [padLeft 16 '0' $ intToBinary $ lookupLabel s labelTable]
nextWordString _ _          (Mem (VInt i))            = [padLeft 16 '0' $ intToBinary i]
nextWordString _ labelTable (Lit (VLabel s))          = [padLeft 16 '0' $ intToBinary $ lookupLabel s labelTable]
nextWordString a _          (Lit (VInt i))            = if -1 <= i && i <= 30 && a then [] else [padLeft 16 '0' $ intToBinary i]
nextWordString _ _          _                         = []

lookupLabel :: String -> [(String,Int16)] -> Int16
lookupLabel s lt = case lookup s lt of Just i  -> i
                                       Nothing -> error $ "Error: Label not defined: " ++ s

assemble :: String -> String
assemble src = unlines $ concatMap (buildLine lt) lns
  where
    lns = map (analyseLine . tokenise) $ lines src
    lt = buildLabelTable lns

main = interact assemble