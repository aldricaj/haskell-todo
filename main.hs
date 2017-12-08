{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
import Database.MySQL.Base
import qualified System.IO.Streams as Streams

--data TaskTuple = Int [Char] Bool MySQLTimeStamp
--GET request provided by the link that was given to us, because I was trying it a different way and gettting nowhere.
--{-# LANGUAGE OverloadedStrings, DeriveDataTypeable #-}
--import qualified Data.ByteString.Lazy.Char8 as L
--import Happstack.Server
--import Happstack.Server.Types
--import Control.Monad.IO.Class (liftIO)

--import Data.Data (Data, Typeable)

--getBody :: ServerPart L.ByteString
--getBody = do
--    req  <- askRq 
--    body <- liftIO $ takeRequestBody req 
--    case body of 
--        Just rqbody -> return . unBody $ rqbody 
--        Nothing     -> return "" 
--
--myRoute :: ServerPart Response
--myRoute = do
--    body <- getBody
--    let unit = fromJust $ A.decode body :: Unit
--    ok $ toResponse $ A.encode unit

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

main = do
    print =<< get_tasks


data Unit = Unit { x :: Int, y :: Int } deriving (Show, Eq, Data, Typeable)

