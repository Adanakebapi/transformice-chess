local languages = {
    en = {
        ["White"] = "White",
        ["Black"] = "Black",
        ["Last game"] = "Last game",
        ["White won"] = "White won",
        ["Black won"] = "Black won",
        ["Tie"] = "Tie",
        ["W"] = "W",
        ["B"] = "B",
        ["Resign"] = "Resign",
        ["Promotion"] = "Promotion",
        ["Queue"] = "Queue",
        ["Queen"] = "Queen",
        ["Rook"] = "Rook",
        ["Bishop"] = "Bishop",
        ["Knight"] = "Knight"
    },
    tr = {
        ["White"] = "Beyaz",
        ["Black"] = "Siyah",
        ["Last game"] = "Son oyun",
        ["White won"] = "Beyaz kazandı",
        ["Black won"] = "Siyah kazandı",
        ["Tie"] = "Berabere",
        ["W"] = "B",
        ["B"] = "S",
        ["Resign"] = "Terk et",
        ["Promotion"] = "Terfi",
        ["Queue"] = "Sıra",
        ["Queen"] = "Vezir",
        ["Rook"] = "Kale",
        ["Bishop"] = "Fil",
        ["Knight"] = "At"
    }
}

local availableLanguages = {}

for languageName, lang in pairs(languages) do
    table.insert(availableLanguages,languageName)
end

local mapXML = '<C><P /><Z><S /><D /><O /></Z></C>'

local images = {
    wk = "182bc3b5b77.png",
    bk = "182bc3ba8f0.png",
    wq = "182bc3bf6ed.png",
    bq = "182bc3c4558.png",
    wr = "182bc3c933c.png",
    br = "182bc3ce152.png",
    wb = "182bc3d2f4a.png",
    bb = "182bc3d7d6a.png",
    wn = "182bc3dcbb7.png",
    bn = "182bc3e19c3.png",
    wp = "182bc3e67c8.png",
    bp = "182bc3eb608.png",
    board = "182bc3f033d.png",
    legalMove = "182bc3f522a.png",
    nextPosition = "182bc3fa064.png",
    previousPosition = "182bc3fee8f.png"
}

local pieceToImage = {
    [09] = images.wp,
    [10] = images.wn,
    [11] = images.wb,
    [12] = images.wr,
    [13] = images.wq,
    [14] = images.wk,
    [17] = images.bp,
    [18] = images.bn,
    [19] = images.bb,
    [20] = images.br,
    [21] = images.bq,
    [22] = images.bk
}

local boardImages = {}
local newGame = ChessGame:new()

local playerSelection = {}

local playerPromotion = {}
local promotionLookup = {
    Q=5,
    R=4,
    B=3,
    N=2
}
local promotionFullName = {
    Q="Queen",
    R="Rook",
    B="Bishop",
    N="Knight"
}

local moveIllustrator = {}
local positionIllustrator = {}

local playerTable = {}
local playerQueue = {}
local lastGameResults = {
    result = 0
}

local playerLanguage = {}

function isPlayerPlaying(playerName)
    if (playerTable[1] == playerName) then
        return 1
    elseif (playerTable[2] == playerName) then
        return 2
    else
        return false
    end
end

function updateTextAreaLanguage(id,playerName,globalText,langBasedTexts)
    local player = tfm.get.room.playerList[playerName]
    local lang = languages[playerLanguage[playerName]] or languages[player.language] or languages["en"]
    local translatedTexts = {}
    for i, text in pairs(langBasedTexts) do
        translatedTexts[i] = lang[text]
    end
    local result = string.format(globalText,table.unpack(translatedTexts))
    ui.updateTextArea(id,result,playerName)
end

function updateTextAreaLanguageAll(id,globalText,langBasedTexts)
    for playerName, player in pairs(tfm.get.room.playerList) do
        updateTextAreaLanguage(id,playerName,globalText,langBasedTexts)
    end
end

function selectPlayers()
    playerTable = {}
    local playerCount = getTableSize(tfm.get.room.playerList)
    if playerCount >= 2 then
        if math.random(0,1) == 1 then
            playerTable[1] = playerQueue[1]
            playerTable[2] = playerQueue[2]
        else
            playerTable[1] = playerQueue[2]
            playerTable[2] = playerQueue[1]
        end
        updateTextAreaLanguage(1,playerTable[1],"<J><a href='event:resign'>%s</a></J>",{"Resign"})
        updateTextAreaLanguage(1,playerTable[2],"<J><a href='event:resign'>%s</a></J>",{"Resign"})
        updateTextAreaLanguageAll(3,"<font color='#eeeeee'>%s</font>\n"..playerTable[1].."\n<font color='#111111'>%s</font>\n"..playerTable[2],{"White","Black"})
    else
        updateTextAreaLanguageAll(3,"<font color='#eeeeee'>%s</font>\n-\n<font color='#111111'>%s</font>\n-",{"White","Black"})
    end
end

function getResults()
    if lastGameResults.result == 0 then
        return {args={},text=""}
    elseif lastGameResults.result == 1 then
        return {args={"Last game","White won","W","B"},text="<J>%s</J>\n<VI>%s</VI>\n<font color='#eeeeee'>(%s)</font> "..lastGameResults.white.."\n<font color='#111111'>(%s)</font> "..lastGameResults.black}
    elseif lastGameResults.result == 2 then
        return {args={"Last game","Black won","W","B"},text="<J>%s</J>\n<VI>%s</VI>\n<font color='#eeeeee'>(%s)</font> "..lastGameResults.white.."\n<font color='#111111'>(%s)</font> "..lastGameResults.black}
    elseif lastGameResults.result == 3 then
        return {args={"Last game","Tie","W","B"},text="<J>%s</J>\n<VI>%s</VI>\n<font color='#eeeeee'>(%s)</font> "..lastGameResults.white.."\n<font color='#111111'>(%s)</font> "..lastGameResults.black}
    end
end

function updateLanguage(playerName)
    local result = getResults()
    if isPlayerPlaying(playerName) then
        updateTextAreaLanguage(1,playerName,"<J><a href='event:resign'>%s</a></J>",{"Resign"})
    else
        updateTextAreaLanguage(1,playerName,"<N2>%s</N2>",{"Resign"})
    end
    updateTextAreaLanguage(2,playerName,"<J>%s</J>\n<a href='event:promotionQ'>Q</a> <a href='event:promotionR'>R</a> <a href='event:promotionB'>B</a> <a href='event:promotionN'>N</a>",{"Promotion"})
    if #playerTable == 2 then
        updateTextAreaLanguage(3,playerName,"<font color='#eeeeee'>%s</font>\n"..playerTable[1].."\n<font color='#111111'>%s</font>\n"..playerTable[2],{"White","Black"})
    else
        updateTextAreaLanguage(3,playerName,"<font color='#eeeeee'>%s</font>\n-\n<font color='#111111'>%s</font>\n-",{"White","Black"})
    end
    updateTextAreaLanguage(4,playerName,result.text,result.args)
    updateTextAreaLanguageAll(5,"<J>%s</J>\n"..table.concat(playerQueue,"\n"),{"Queue"})
end

function eventNewPlayer(playerName)
    table.insert(playerQueue,playerName)
    system.bindMouse(playerName,true)
    updateLanguage(playerName)
    if #playerQueue == 2 then
        selectPlayers()
    end
end

function eventPlayerLeft(playerName)
    if (#playerTable == 2) then
        if playerTable[1] == playerName then
            gameOverSignal(2,false)
        elseif playerTable[2] == playerName then
            gameOverSignal(1,false)
        else
            for pos, targetPlayer in pairs(playerQueue) do
                if playerName == targetPlayer then
                    table.remove(playerQueue,pos)
                    break
                end
            end
        end
        updateTextAreaLanguageAll(5,"<J>%s</J>\n"..table.concat(playerQueue,"\n"),{"Queue"})
    end
end

function eventNewGame()
    for playerName, player in pairs(tfm.get.room.playerList) do
        tfm.exec.killPlayer(playerName)
    end
end

function gameOverSignal(isOverResult,addBackToQueue)
    lastGameResults = {
        result = isOverResult,
        white = playerTable[1],
        black = playerTable[2]
    }
    local result = getResults()
    updateTextAreaLanguageAll(4,result.text,result.args)
    if addBackToQueue or isOverResult == 1 then
        table.insert(playerQueue,playerTable[1])
        updateTextAreaLanguage(1,playerTable[1],"<N2>%s</N2>",{"Resign"})
    end
    if addBackToQueue or isOverResult == 2 then
        table.insert(playerQueue,playerTable[2])
        updateTextAreaLanguage(1,playerTable[2],"<N2>%s</N2>",{"Resign"})
    end
    if (isOverResult == 1) or (isOverResult == 2) then
        tfm.exec.setPlayerScore(playerTable[isOverResult],1,true)
    end
    table.remove(playerQueue,1)
    table.remove(playerQueue,1)
    for k, v in pairs(moveIllustrator) do
        tfm.exec.removeImage(v)
    end
    moveIllustrator = {}
    for k, v in pairs(positionIllustrator) do
        tfm.exec.removeImage(v)
    end
    positionIllustrator = {}
    playerSelection = {}
    newGame = ChessGame:new()
    renderBoard()
    selectPlayers()
end

function eventMouse(playerName,x,y)
    local bx, by = math.floor((x - 220) / 45), math.floor((y - 30) / 45)
    local targetPos = bx + by * 8 + 1
    if (bx < 0) or (bx > 7) or (by < 0) or (by > 7) or (#playerTable ~= 2) or (playerTable[newGame.turn] ~= playerName) then
        return
    end
    if playerSelection[playerName] == nil then
        if newGame.legalMoves[targetPos] == nil then
            newGame.legalMoves[targetPos] = newGame:getLegalMoves(targetPos)
        end
        if getTableSize(newGame.legalMoves[targetPos]) > 0 then
            for nextPos, move in pairs(newGame.legalMoves[targetPos]) do
                local px, py = (nextPos - 1) % 8, math.floor((nextPos - 1) / 8)
                local greenDot = tfm.exec.addImage(images.legalMove,"?"..(#moveIllustrator + 128),220+px*45,30+py*45,playerName)
                table.insert(moveIllustrator,greenDot)
            end
            playerSelection[playerName] = targetPos
        end
    else
        local oldPos = playerSelection[playerName]
        if newGame.legalMoves[oldPos][targetPos] ~= nil then
            newGame:playMove(oldPos,newGame.legalMoves[oldPos][targetPos],playerPromotion[playerName])
            renderBoard()
            for k, v in pairs(positionIllustrator) do
                tfm.exec.removeImage(v)
            end
            local oldPosX, oldPosY = (oldPos-1) % 8, math.floor((oldPos-1) / 8)
            local targetPosX, targetPosY = (targetPos-1) % 8, math.floor((targetPos-1) / 8)
            positionIllustrator[1] = tfm.exec.addImage(images.previousPosition,"?256",220+oldPosX*45,30+oldPosY*45,nil)
            positionIllustrator[2] = tfm.exec.addImage(images.nextPosition,"?256",220+targetPosX*45,30+targetPosY*45,nil)
            local isOverResult = newGame:isOver()
            if isOverResult ~= 0 then
                gameOverSignal(isOverResult,true)
            end
        end
        playerSelection[playerName] = nil
        for k, v in pairs(moveIllustrator) do
            tfm.exec.removeImage(v)
        end
        moveIllustrator = {}
    end
end

function renderBoard()
    for k, v in pairs(boardImages) do
        tfm.exec.removeImage(v)
    end
    boardImages = {}
    for pos, pieceCode in pairs(newGame.board) do
        if pieceToImage[pieceCode] ~= nil then
            local x, y = (pos-1)%8, math.floor((pos-1)/8)
            boardImages[pos] = tfm.exec.addImage(pieceToImage[pieceCode],"?"..pos,220+x*45,30+y*45,nil)
        end
    end
end

function eventTextAreaCallback(id,playerName,callback)
    if callback == "resign" then
        if playerTable[1] == playerName then
            gameOverSignal(2,true)
        elseif playerTable[2] == playerName then
            gameOverSignal(1,true)
        end
    elseif string.sub(callback,0,9) == "promotion" then
        local pieceType = string.sub(callback,10,10)
        local player = tfm.get.room.playerList[playerName]
        local lang = languages[playerLanguage[playerName]] or languages[player.language] or languages["en"]
        playerPromotion[playerName] = promotionLookup[pieceType]
        ui.addTextArea(tfm.get.room.playerList[playerName].id*16+18,lang[promotionFullName[pieceType]],playerName,100,75)
    end
end

function eventChatCommand(playerName,message)
    local args = {}
    for arg in string.gmatch(message,"%a+") do
        table.insert(args,arg)
    end
    local command = args[1]
    table.remove(args,1)
    if command == "lang" then
        if #args == 0 then
            ui.addPopup(1,0,"Available Languages\n"..table.concat(availableLanguages,"\n"),playerName)
        else
            playerLanguage[playerName] = args[1]
            updateLanguage(playerName)
        end
    end
end

ui.addTextArea(1,"",nil,0,30,90,15)
ui.addTextArea(2,"",nil,0,60,90,30)
ui.addTextArea(3,"",nil,0,105,200,60)
ui.addTextArea(4,"",nil,0,315,200,75)
ui.addTextArea(5,"",nil,600,30,200,360)

tfm.exec.disableAutoNewGame()
tfm.exec.disableAutoShaman()
tfm.exec.disableAfkDeath()
tfm.exec.disableAutoScore()
tfm.exec.disableMortCommand()

system.disableChatCommandDisplay(nil,true)

tfm.exec.newGame(mapXML)
ui.setMapName("Chess by Adanakebapi#0000")

for playerName, player in pairs(tfm.get.room.playerList) do
    eventNewPlayer(playerName)
end

tfm.exec.addImage(images.board,"?0",220,30,nil)
renderBoard()