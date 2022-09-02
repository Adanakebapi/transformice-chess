function copyTable(oldTable)
    local newTable = {}
    for key, value in pairs(oldTable) do
        if type(value) == "table" then
            newTable[key] = copyTable(value)
        else
            newTable[key] = value
        end
    end
    return newTable
end

function getTableSize(list)
    local counter = 0
    for k, v in pairs(list) do
        counter = counter + 1
    end
    return counter
end

ChessGame = {
    board = {
        20,18,19,21,22,19,18,20,
        17,17,17,17,17,17,17,17,
        00,00,00,00,00,00,00,00,
        00,00,00,00,00,00,00,00,
        00,00,00,00,00,00,00,00,
        00,00,00,00,00,00,00,00,
        09,09,09,09,09,09,09,09,
        12,10,11,13,14,11,10,12
    },
    turn = 1,
    castling = {
        [1] = {
            kingSide = true,
            queenSide = true
        },
        [2] = {
            kingSide = true,
            queenSide = true
        }
    },
    enPassant = nil,
    halfmoveClock = 0,
    totalMoves = 1,
    legalMoves = {},
    targetSquares = nil
}

ChessGame.pieceInfo = {
    [1] = {
        defaultCapturing = false,
        capturingSquares = {
            [1] = {
                {-1,-1},
                {1,-1}
            },
            [2] = {
                {-1,1},
                {1,1}
            }
        },
        defaultMoves = {
            [1] = {
                {0,-1}
            },
            [2] = {
                {0,1}
            }
        },
        specialMoves = function(color,position,board,castling,enPassant,targetSquares)
            local moves = {}
            local y = math.floor((position-1) / 8)
            if color == 1 then
                if y == 6 then
                    if (board[position-8] == 0) and (board[position-16] == 0) then
                        moves[position-16] = {
                            boardUpdates = {
                                [position-16] = 9,
                                [position] = 0
                            },
                            isCapture = false,
                            enPassant = position-8
                        }
                    end
                elseif y == 3 then
                    if (position-9 == enPassant) or (position-7 == enPassant) then
                        moves[enPassant] = {
                            boardUpdates = {
                                [enPassant] = 9,
                                [enPassant+8] = 0,
                                [position] = 0
                            },
                            isCapture = true
                        }
                    end
                elseif y == 1 then
                    if board[position-8] == 0 then
                        moves[position-8] = {
                            boardUpdates = {
                                [position] = 0,
                                [position-8] = color*8
                            },
                            isCapture = false
                        }
                    end
                    if (position ~= 9) then
                        local leftSquare = board[position-9]
                        local leftSquareColor = math.floor(leftSquare / 8)
                        if (leftSquare ~= 0) and (leftSquareColor ~= color) then
                            moves[position-9] = {
                                boardUpdates = {
                                    [position] = 0,
                                    [position-9] = color*8
                                },
                                isCapture = true
                            }
                        end
                    end
                    if (position ~= 16) then
                        if (rightSquare ~= 0) and (rightSquareColor ~= color) then
                            local rightSquare = board[position-7]
                            local rightSquareColor = math.floor(rightSquare / 8)
                            moves[position-7] = {
                                boardUpdates = {
                                    [position] = 0,
                                    [position-7] = color*8
                                },
                                isCapture = true
                            }
                        end
                    end
                end
            else
                if y == 1 then
                    if (board[position+8] == 0) and (board[position+16] == 0) then
                        moves[position+16] = {
                            boardUpdates = {
                                [position+16] = 17,
                                [position] = 0
                            },
                            isCapture = false,
                            enPassant = position+8
                        }
                    end
                elseif y == 4 then
                    if (position+9 == enPassant) or (position+7 == enPassant) then
                        moves[enPassant] = {
                            boardUpdates = {
                                [enPassant] = 17,
                                [enPassant-8] = 0,
                                [position] = 0
                            },
                            isCapture = true
                        }
                    end
                elseif y == 6 then
                    if board[position+8] == 0 then
                        moves[position+8] = {
                            boardUpdates = {
                                [position] = 0,
                                [position+8] = color*8
                            },
                            isCapture = false
                        }
                    end
                    if (position ~= 56) then
                        local leftSquare = board[position+9]
                        local leftSquareColor = math.floor(leftSquare / 8)
                        if (leftSquare ~= 0) and (leftSquareColor ~= color) then
                            moves[position+9] = {
                                boardUpdates = {
                                    [position] = 0,
                                    [position+9] = color*8
                                },
                                isCapture = true
                            }
                        end
                    end
                    if (position ~= 49) then
                        if (rightSquare ~= 0) and (rightSquareColor ~= color) then
                            local rightSquare = board[position+7]
                            local rightSquareColor = math.floor(rightSquare / 8)
                            moves[position+7] = {
                                boardUpdates = {
                                    [position] = 0,
                                    [position+7] = color*8
                                },
                                isCapture = true
                            }
                        end
                    end
                end
            end
            return moves
        end
    },
    [2] = {
        defaultCapturing = true,
        defaultMoves = {
            [1] = {
                {2,1},
                {-2,1},
                {2,-1},
                {-2,-1},
                {1,2},
                {-1,2},
                {1,-2},
                {-1,-2}
            }
        }
    },
    [3] = {
        defaultCapturing = true,
        moveDirections = {
            {-1,-1},
            {-1,1},
            {1,-1},
            {1,1}
        }
    },
    [4] = {
        defaultCapturing = true,
        moveDirections = {
            {-1,0},
            {1,0},
            {0,-1},
            {0,1}
        }
    },
    [5] = {
        defaultCapturing = true,
        moveDirections = {
            {-1,-1},
            {-1,0},
            {-1,1},
            {0,-1},
            {0,1},
            {1,-1},
            {1,0},
            {1,1}
        }
    },
    [6] = {
        defaultCapturing = true,
        defaultMoves = {
            [1] = {
                {-1,-1},
                {-1,0},
                {-1,1},
                {0,-1},
                {0,1},
                {1,-1},
                {1,0},
                {1,1}
            }
        },
        specialMoves = function(color,position,board,castling,enPassant,targetSquares)
            local moves = {}
            if castling[color].kingSide then
                if color == 1 then
                    if not (targetSquares[61] or targetSquares[62] or targetSquares[63])
                    and (board[62] == 0) and (board[63] == 0) and (board[64] == 12) then
                        moves[63] = {
                            boardUpdates = {
                                [61] = 0,
                                [62] = 12,
                                [63] = 14,
                                [64] = 0
                            },
                            isCapture = false,
                            castling = {
                                [1] = {
                                    kingSide = false,
                                    queenSide = false
                                }
                            }
                        }
                    end
                else
                    if not (targetSquares[5] or targetSquares[6] or targetSquares[7])
                    and (board[6] == 0) and (board[7] == 0) and (board[8] == 20) then
                        moves[7] = {
                            boardUpdates = {
                                [5] = 0,
                                [6] = 20,
                                [7] = 22,
                                [8] = 0
                            },
                            isCapture = false,
                            castling = {
                                [2] = {
                                    kingSide = false,
                                    queenSide = false
                                }
                            }
                        }
                    end
                end
            end
            if castling[color].queenSide then
                if color == 1 then
                    if not (targetSquares[61] or targetSquares[60] or targetSquares[59])
                    and (board[60] == 0) and (board[59] == 0) and (board[58] == 0) and (board[57] == 12) then
                        moves[60] = {
                            boardUpdates = {
                                [57] = 0,
                                [59] = 12,
                                [60] = 14,
                                [61] = 0
                            },
                            isCapture = false,
                            castling = {
                                [1] = {
                                    kingSide = false,
                                    queenSide = false
                                }
                            }
                        }
                    end
                else
                    if not (targetSquares[5] or targetSquares[4] or targetSquares[3])
                    and (board[4] == 0) and (board[3] == 0) and (board[2] == 0) and (board[1] == 20) then
                        moves[3] = {
                            boardUpdates = {
                                [5] = 0,
                                [4] = 20,
                                [3] = 22,
                                [1] = 0
                            },
                            isCapture = false,
                            castling = {
                                [2] = {
                                    kingSide = false,
                                    queenSide = false
                                }
                            }
                        }
                    end
                end
            end
            return moves
        end
    }
}

function ChessGame:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.board = copyTable(o.board)
    o.castling = copyTable(o.castling)
    o.legalMoves = {}
    o.targetSquares = o:getTargetSquares(o.board,o.turn)
    return o
end

function ChessGame:isOver()
    local isThereAnyMoves = false
    for pos, pieceCode in pairs(self.board) do
        if self.turn == 1 then
            if pieceCode == 14 then
                if self.legalMoves[pos] == nil then
                    self.legalMoves[pos] = self:getLegalMoves(pos)
                end
            end
        else
            if pieceCode == 22 then
                if self.legalMoves[pos] == nil then
                    self.legalMoves[pos] = self:getLegalMoves(pos)
                end
            end
        end
        if (self.legalMoves[pos] ~= nil) then
            if getTableSize(self.legalMoves[pos]) > 0 then
                isThereAnyMoves = true
                break
            end
        end
    end
    if not isThereAnyMoves then
        for pos, pieceCode in pairs(self.board) do
            if self.legalMoves[pos] == nil then
                self.legalMoves[pos] = self:getLegalMoves(pos)
                if getTableSize(self.legalMoves[pos]) > 0 then
                    isThereAnyMoves = true
                    break
                end
            end
        end
    end
    if not isThereAnyMoves then
        if self.turn == 2 then
            return 1
        else
            return 2
        end
    elseif self.halfmoveClock >= 50 then
        return 3
    else
        return 0
    end
end

function ChessGame:simulateMove(move)
    local board = copyTable(self.board)
    for pos, pieceCode in pairs(move.boardUpdates) do
        board[pos] = pieceCode
    end
    return board
end

function ChessGame:playMove(position,move,promotingPiece)
    if promotingPiece == nil then
        promotingPiece = 5
    end
    if (self.board[position] % 8 == 1) or move.isCapture then
        self.halfmoveClock = 0
    else
        self.halfmoveClock = self.halfmoveClock + 1
    end
    for pos, pieceCode in pairs(move.boardUpdates) do
        local piece, color = pieceCode % 8, math.floor(pieceCode / 8)
        if (pieceCode ~= 0) and (piece == 0) then
            self.board[pos] = pieceCode + promotingPiece
        else
            self.board[pos] = pieceCode
        end
    end
    if move.castling ~= nil then
        for key1, value1 in pairs(move.castling) do
            for key2, value2 in pairs(value1) do
                self.castling[key1][key2] = value2
            end
        end
    end
    if self.turn == 1 then
        self.turn = 2
    else
        self.turn = 1
    end
    self.enPassant = move.enPassant
    self.legalMoves = {}
    self.targetSquares = self:getTargetSquares(self.board,self.turn)
end

function ChessGame:isCheck(board,forColor)
    if board == nil then
        board = self.board
    end
    local kingPos
    for pos, pieceCode in pairs(board) do
        if forColor == 1 then
            if pieceCode == 14 then
                kingPos = pos
                break
            end
        else
            if pieceCode == 22 then
                kingPos = pos
                break
            end
        end
    end
    local targetSquares = self:getTargetSquares(board,forColor)
    return targetSquares[kingPos] == true
end

function ChessGame:getTargetSquares(board,forColor)
    if board == nil then
        board = self.board
    end
    if forColor == nil then
        forColor = self.turn
    end
    local targetSquares = {}
    for pos, pieceCode in pairs(board) do
        if pieceCode ~= 0 then
            local piece, color = pieceCode % 8, math.floor(pieceCode / 8)
            local x, y = (pos-1) % 8, math.floor((pos-1) / 8)
            local pieceInfo = self.pieceInfo[piece]
            if color ~= forColor then
                if (pieceInfo.moveDirections ~= nil) and pieceInfo.defaultCapturing then
                    for i, direction in pairs(pieceInfo.moveDirections) do
                        local px, py = x, y
                        while true do
                            px = px + direction[1]
                            py = py + direction[2]
                            if not ((0 <= px) and (px < 8) and (0 <= py) and (py < 8)) then
                                break
                            end
                            local targetPos = px + py*8 + 1
                            targetSquares[targetPos] = true
                            if board[targetPos] ~= 0 then
                                break
                            end
                        end
                    end
                end
                if (pieceInfo.defaultMoves ~= nil) and pieceInfo.defaultCapturing then
                    local defaultMoves = pieceInfo.defaultMoves[color] or pieceInfo.defaultMoves[1]
                    for i, moveOffset in pairs(defaultMoves) do
                        local px, py = x + moveOffset[1], y + moveOffset[2]
                        if (0 <= px) and (px < 8) and (0 <= py) and (py < 8) then
                            local targetPos = px + py*8 + 1
                            targetSquares[targetPos] = true
                        end
                    end
                end
                if (pieceInfo.capturingSquares ~= nil) then
                    local capturingSquares = pieceInfo.capturingSquares[color] or pieceInfo.capturingSquares[1]
                    for i, moveOffset in pairs(capturingSquares) do
                        local px, py = x + moveOffset[1], y + moveOffset[2]
                        if (0 <= px) and (px < 8) and (0 <= py) and (py < 8) then
                            local targetPos = px + py*8 + 1
                            targetSquares[targetPos] = true
                        end
                    end
                end
            end
        end
    end
    return targetSquares
end

function ChessGame:getLegalMoves(pos)
    if self.legalMoves[pos] ~= nil then
        return self.legalMoves[pos]
    end
    if self.targetSquares == nil then
        self.targetSquares = ChessGame:getTargetSquares(self.board,self.turn)
    end
    local pieceCode = self.board[pos]
    local piece, color = pieceCode % 8, math.floor(pieceCode / 8)
    if (pieceCode == 0) or (self.turn ~= color) then
        return {}
    end
    local kingPos
    for checkPos, checkPieceCode in pairs(self.board) do
        if color == 1 then
            if checkPieceCode == 14 then
                kingPos = checkPos
                break
            end
        else
            if checkPieceCode == 22 then
                kingPos = checkPos
                break
            end
        end
    end
    local legalMoves = {}
    local x, y = (pos-1) % 8, math.floor((pos-1) / 8)
    local pieceInfo = self.pieceInfo[piece]
    if pieceInfo.moveDirections ~= nil then
        for i, direction in pairs(pieceInfo.moveDirections) do
            local px, py = x, y
            while true do
                px = px + direction[1]
                py = py + direction[2]
                if (0 > px) or (px > 7) or (0 > py) or (py > 7) then
                    break
                end
                local nextPos = px + py*8 + 1
                local nextSquare = self.board[nextPos]
                local nextColor = math.floor(nextSquare / 8)
                if (nextSquare == 0) or (pieceInfo.defaultCapturing and (nextColor ~= color)) then
                    legalMoves[nextPos] = {
                        boardUpdates = {
                            [pos] = 0,
                            [nextPos] = pieceCode
                        },
                        isCapturing = nextSquare ~= 0
                    }
                end
                if nextSquare ~= 0 then
                    break
                end
            end
        end
    end
    if pieceInfo.defaultMoves ~= nil then
        local defaultMoves = pieceInfo.defaultMoves[color] or pieceInfo.defaultMoves[1]
        for i, moveOffset in pairs(defaultMoves) do
            local px, py = x + moveOffset[1], y + moveOffset[2]
            if (0 <= px) and (px < 8) and (0 <= py) and (py < 8) then
                local nextPos = px + py*8 + 1
                local nextSquare = self.board[nextPos]
                local nextColor = math.floor(nextSquare / 8)
                if (nextSquare == 0) or (pieceInfo.defaultCapturing and (nextColor ~= color)) then
                    legalMoves[nextPos] = {
                        boardUpdates = {
                            [pos] = 0,
                            [nextPos] = pieceCode
                        },
                        isCapturing = nextSquare ~= 0
                    }
                end
            end
        end
    end
    if pieceInfo.capturingSquares ~= nil then
        local capturingSquares = pieceInfo.capturingSquares[color] or pieceInfo.capturingSquares[1]
        for i, moveOffset in pairs(capturingSquares) do
            local px, py = x + moveOffset[1], y + moveOffset[2]
            if (0 <= px) and (px < 8) and (0 <= py) and (py < 8) then
                local nextPos = px + py*8 + 1
                local nextSquare = self.board[nextPos]
                local nextColor = math.floor(nextSquare / 8)
                if (nextSquare ~= 0) and (nextColor ~= color) then
                    legalMoves[nextPos] = {
                        boardUpdates = {
                            [pos] = 0,
                            [nextPos] = pieceCode
                        },
                        isCapturing = true
                    }
                end
            end
        end
    end
    for nextPos, move in pairs(legalMoves) do
        if piece == 6 then
            move.castling = {
                [color] = {
                    kingSide = false,
                    queenSide = false
                }
            }
        elseif piece == 4 then
            if color == 1 then
                if pos == 57 then
                    move.castling = {
                        [1] = {
                            queenSide = false
                        }
                    }
                elseif pos == 64 then
                    move.castling = {
                        [1] = {
                            kingSide = false
                        }
                    }
                end
            else
                if pos == 1 then
                    move.castling = {
                        [2] = {
                            queenSide = false
                        }
                    }
                elseif pos == 8 then
                    move.castling = {
                        [2] = {
                            kingSide = false
                        }
                    }
                end
            end
        end
    end
    if pieceInfo.specialMoves ~= nil then
        local extraMoves = pieceInfo.specialMoves(color,pos,self.board,self.castling,self.enPassant,self.targetSquares)
        for nextPos, move in pairs(extraMoves) do
            legalMoves[nextPos] = move
        end
    end
    local validatedMoves = {}
    for nextPos, move in pairs(legalMoves) do
        local customBoard = self:simulateMove(move)
        local isCheck = self:isCheck(customBoard,color)
        if not isCheck then
            validatedMoves[nextPos] = move
        end
    end
    return validatedMoves
end

function ChessGame:getAllLegalMoves()
    local legalMoves = {}
    local targetSquares = {}
    for pos, pieceCode in pairs(self.board) do
        if self.legalMoves[pos] == nil then
            legalMoves[pos] = {}
            if (pieceCode ~= 0) then
                local piece, color = pieceCode % 8, math.floor(pieceCode / 8)
                local x, y = (pos-1) % 8, math.floor((pos-1) / 8)
                local pieceInfo = self.pieceInfo[piece]
                if pieceInfo.moveDirections ~= nil then
                    for i, direction in pairs(pieceInfo.moveDirections) do
                        local px, py = x, y
                        while true do
                            px = px + direction[1]
                            py = py + direction[2]
                            if not ((0 <= px) and (px < 8) and (0 <= py) and (py < 8)) then
                                break
                            end
                            local nextPos = px + py*8 + 1
                            local nextSquare = self.board[nextPos]
                            local nextColor = math.floor(nextSquare / 8)
                            if (nextSquare == 0) or (pieceInfo.defaultCapturing and (nextColor ~= color)) then
                                if self.turn == color then
                                    legalMoves[pos][nextPos] = {
                                        boardUpdates = {
                                            [pos] = 0,
                                            [nextPos] = pieceCode
                                        },
                                        isCapture = nextSquare ~= 0
                                    }
                                    if piece == 6 then
                                        legalMoves[pos][nextPos].castling = {
                                            [color] = {
                                                kingSide = false,
                                                queenSide = false
                                            }
                                        }
                                    elseif piece == 4 then
                                        if color == 1 then
                                            if pos == 57 then
                                                legalMoves[pos][nextPos].castling = {
                                                    [1] = {
                                                        queenSide = false
                                                    }
                                                }
                                            end
                                        else
                                            if pos == 64 then
                                                legalMoves[pos][nextPos].castling = {
                                                    [2] = {
                                                        kingSide = false
                                                    }
                                                }
                                            end
                                        end
                                    end
                                else
                                    targetSquares[nextPos] = true
                                end
                            end
                            if nextSquare ~= 0 then
                                break
                            end
                        end
                    end
                end
                if pieceInfo.defaultMoves ~= nil then
                    local defaultMoves = pieceInfo.defaultMoves[color] or pieceInfo.defaultMoves[1]
                    for i, moveOffset in pairs(defaultMoves) do
                        local px, py = moveOffset[1] + x, moveOffset[2] + y
                        if (0 <= px) and (px < 8) and (0 <= py) and (py < 8) then
                            local nextPos = px + py*8 + 1
                            local nextSquare = self.board[nextPos]
                            local nextColor = math.floor(nextSquare / 8)
                            if (nextSquare == 0) or (pieceInfo.defaultCapturing and (nextColor ~= color)) then
                                if self.turn == color then
                                    legalMoves[pos][nextPos] = {
                                        boardUpdates = {
                                            [pos] = 0,
                                            [nextPos] = pieceCode
                                        },
                                        isCapture = nextSquare ~= 0
                                    }
                                    if (piece == 4) or (piece == 6) then
                                        legalMoves[pos][nextPos].castling = {
                                            [color] = {
                                                kingSide = false,
                                                queenSide = false
                                            }
                                        }
                                    end
                                else
                                    targetSquares[nextPos] = true
                                end
                            end
                        end
                    end
                end
                if pieceInfo.capturingSquares ~= nil then
                    local capturingSquares = pieceInfo.capturingSquares[color] or pieceInfo.capturingSquares[1]
                    for i, moveOffset in pairs(capturingSquares) do
                        local px, py = moveOffset[1] + x, moveOffset[2] + y
                        if (0 <= px) and (px < 8) and (0 <= py) and (py < 8) then
                            local nextPos = px + py*8 + 1
                            if (self.board[nextPos] ~= 0) and (math.floor(self.board[nextPos] / 8) ~= color) then
                                if self.turn == color then
                                    legalMoves[pos][nextPos] = {
                                        boardUpdates = {
                                            [pos] = 0,
                                            [nextPos] = pieceCode
                                        },
                                        isCapturing = true
                                    }
                                else
                                    targetSquares[nextPos] = true
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    for pos, pieceCode in pairs(self.board) do
        if (pieceCode ~= 0) then
            local piece, color = pieceCode % 8, math.floor(pieceCode / 8)
            local pieceInfo = self.pieceInfo[piece]
            if (self.turn == color) and (pieceInfo.specialMoves ~= nil) then
                local extraMoves = pieceInfo.specialMoves(color,pos,self.board,self.castling,self.enPassant,targetSquares)
                for nextPos, move in pairs(extraMoves) do
                    legalMoves[pos][nextPos] = move
                end
            end
        end
    end
    local invalidMoves = {}
    for pos, innerMoves in pairs(legalMoves) do
        for nextPos, move in pairs(innerMoves) do
            local customBoard = self:simulateMove(move)
            local isCheck = self:isCheck(customBoard,self.turn)
            if isCheck then
                table.insert(invalidMoves,{pos,nextPos})
            end
        end
    end
    for key, value in pairs(invalidMoves) do
        local pos, nextPos = value[1], value[2]
        legalMoves[pos][nextPos] = nil
    end
    return legalMoves
end