{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
import Database.MySQL.Base
import qualified System.IO.Streams as Streams
import Web.Scotty
import Data.List.Split
import Data.String



--data TaskTuple = Int [Char] Bool MySQLTimeStamp

get_tasks = do 
    conn <- connect defaultConnectInfo {ciUser="root", ciPassword="UCBearcat$",ciDatabase="ToDo",ciHost="54.186.118.144"}
    (defs, is) <- query_ conn "SELECT id, task_desc, completed, last_updated FROM tasks"
    lst <- Streams.toList is
    return (lst)

insert_task task_desc = do
    conn <- connect defaultConnectInfo {ciUser="root", ciPassword="UCBearcat$",ciDatabase="ToDo",ciHost="54.186.118.144"}
    s <- prepareStmt conn "INSERT INTO tasks(task_desc) VALUES (?)"
    (defs, is) <- queryStmt conn s [MySQLText task_desc]
    return 1


update_task id task_desc complete = do 
    conn <- connect defaultConnectInfo {ciUser="root", ciPassword="UCBearcat$",ciDatabase="ToDo",ciHost="54.186.118.144"}
    s <- prepareStmt conn "UPDATE tasks SET task_desc = ?, completed = ? WHERE id = ?"
    (defs, is) <- queryStmt conn s [MySQLText task_desc, MySQLInt8 (if complete then 1 else 0), MySQLInt32 id]
    return 1

check_insert = 
    get "/create/:word" $ do
        todo <- param "word"

        insert_task (fromString todo)

        html $ mconcat ["Task created"]

check_update = 
    get "/update/:word" $ do
        url_text <- param "word"

        let params = splitOn "|" url_text

        let idT = params!!0
        let id = read idT :: Int 

        let completeT = params!!1
        let complete = read completeT :: Bool 

        let todo = params!!2

        update_task (fromIntegral id) (fromString todo) complete

        html $ mconcat ["Task Updated"]

main = scotty 3000 $ do 

    check_insert
    check_update
