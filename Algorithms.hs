module Algorithms where

import qualified Data.Set as S
import StandardGraph

{-
    În etapa 1, prin graf înțelegem un graf cu reprezentare standard.
    În etapele următoare, vom experimenta și cu altă reprezentare.

    type introduce un sinonim de tip, similar cu typedef din C.
-}
type Graph a = StandardGraph a

{-
    *** TODO ***

    Funcție generală care abstractizează BFS și DFS pornind dintr-un anumit nod,
    prin funcția de îmbinare a listelor care constituie primul parametru.
    
    Cele două liste primite ca parametru de funcția de îmbinare sunt lista
    elementelor deja aflate în structură (coadă/stivă), respectiv lista
    vecinilor nodului curent, proaspăt expandați.

    Căutarea ar trebui să țină cont de eventualele cicluri.

    Hint: Scrieți o funcție auxiliară care primește ca parametru suplimentar
    o mulțime (set) care reține nodurile vizitate până în momentul curent.
-}

neighbors :: Ord a => a -> [(a,a)] ->[a]
neighbors node pairs = (nub' (map (\(x,y) -> if x == node then y else x) 
                   (filter (\(x,y) -> if x == node then True else False) pairs)))

compareList :: (Eq a) => [a] -> [a] -> Bool
compareList xs ys = foldl (\acc x -> x `elem` ys || acc) False xs

aux :: Ord a => ([a] -> [a] -> [a]) -> a -> Graph a -> S.Set a -> [a]->[a]

aux f node graph set [] = []
aux f node graph set list
                        | node `S.member` set && (tail list) == [] = []
                        | node `S.member` set = [] ++ (aux f (head (tail list)) graph set (tail list))
                        | otherwise = 
                            let newList = (f list (filter (\x -> if(x `S.member` set == True) then False else True) (neighbors node (S.toList (edges graph)))))
                            in (node : (aux f (head newList) graph (S.fromList (node : (S.toList set))) newList))
--(f (S.toList set) list) 
--(neighbors (head list) (S.toList (edges graph)))
search :: Ord a
       => ([a] -> [a] -> [a])  -- funcția de îmbinare a listelor de noduri
       -> a                    -- nodul de pornire
       -> Graph a              -- graful
       -> [a]                  -- lista obținută în urma parcurgerii
search f node graph = 
                    let visited = S.empty
                        list = [node]
                    in ((aux f node graph visited list))

{-
    *** TODO ***

    Strategia BFS, derivată prin aplicarea parțială a funcției search.

    Exemple:

    > bfs 1 graph4
    [1,2,3,4]

    > bfs 4 graph4
    [4,1,2,3]
-}
bfs :: Ord a => a -> Graph a -> [a]
bfs start graph = (search (\x y-> (tail x) ++ y) start graph)

{-
    *** TODO ***

    Strategia DFS, derivată prin aplicarea parțială a funcției search.

    Exemple:

    > dfs 1 graph4 
    [1,2,4,3]
    
    > dfs 4 graph4
    [4,1,2,3]
-}
dfs :: Ord a => a -> Graph a -> [a]
dfs start graph = (search (\x y -> (y ++ reverse(tail x))) start graph)

{-
    *** TODO ***

    Funcția numără câte noduri intermediare expandează strategiile BFS,
    respectiv DFS, în încercarea de găsire a unei căi între un nod sursă
    și unul destinație, ținând cont de posibilitatea absenței acesteia din graf.
    Numărul exclude nodurile sursă și destinație.

    Modalitatea uzuală în Haskell de a preciza că o funcție poate să nu fie
    definită pentru anumite valori ale parametrului este constructorul de tip
    Maybe. Astfel, dacă o cale există, funcția întoarce
    Just (numărBFS, numărDFS), iar altfel, Nothing.

    Hint: funcția span.

    Exemple:

    > countIntermediate 1 3 graph4
    Just (1,2)

    Aici, bfs din nodul 1 întoarce [1,2,3,4], deci există un singur nod
    intermediar (2) între 1 și 3. dfs întoarce [1,2,4,3], deci sunt două noduri
    intermediare (2, 4) între 1 și 3.

    > countIntermediate 3 1 graph4
    Nothing

    Aici nu există cale între 3 și 1.
-}
countIntermediate :: Ord a
                  => a                 -- nodul sursă
                  -> a                 -- nodul destinație
                  -> StandardGraph a   -- graful
                  -> Maybe (Int, Int)  -- numărul de noduri expandate de BFS/DFS
countIntermediate from to graph = 
                                  let numberBFS = (length (fst (span (/=to) (tail (bfs from graph)))))
                                      numberDFS = (length (fst (span (/=to) (tail (dfs from graph)))))
                                  in ((if numberBFS /= 0 && numberDFS /= 0 && to `elem` (tail (bfs from graph))
                                      then Just(numberBFS,numberDFS) else Nothing))
