function copyTable(a)local b={}for c,d in pairs(a)do if type(d)=="table"then b[c]=copyTable(d)else b[c]=d end end;return b end;function getTableSize(e)local f=0;for g,h in pairs(e)do f=f+1 end;return f end;ChessGame={board={20,18,19,21,22,19,18,20,17,17,17,17,17,17,17,17,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,09,09,09,09,09,09,09,09,12,10,11,13,14,11,10,12},turn=1,castling={[1]={kingSide=true,queenSide=true},[2]={kingSide=true,queenSide=true}},enPassant=nil,halfmoveClock=0,totalMoves=1,legalMoves={},targetSquares=nil}ChessGame.pieceInfo={[1]={defaultCapturing=false,capturingSquares={[1]={{-1,-1},{1,-1}},[2]={{-1,1},{1,1}}},defaultMoves={[1]={{0,-1}},[2]={{0,1}}},specialMoves=function(i,j,k,l,m,n)local o={}local p=math.floor((j-1)/8)if i==1 then if p==6 then if k[j-8]==0 and k[j-16]==0 then o[j-16]={boardUpdates={[j-16]=9,[j]=0},isCapture=false,enPassant=j-8}end elseif p==3 then if j-9==m or j-7==m then o[m]={boardUpdates={[m]=9,[m+8]=0,[j]=0},isCapture=true}end elseif p==1 then if k[j-8]==0 then o[j-8]={boardUpdates={[j]=0,[j-8]=i*8},isCapture=false}end;if j~=9 then local q=k[j-9]local r=math.floor(q/8)if q~=0 and r~=i then o[j-9]={boardUpdates={[j]=0,[j-9]=i*8},isCapture=true}end end;if j~=16 then if rightSquare~=0 and rightSquareColor~=i then local rightSquare=k[j-7]local rightSquareColor=math.floor(rightSquare/8)o[j-7]={boardUpdates={[j]=0,[j-7]=i*8},isCapture=true}end end end else if p==1 then if k[j+8]==0 and k[j+16]==0 then o[j+16]={boardUpdates={[j+16]=17,[j]=0},isCapture=false,enPassant=j+8}end elseif p==4 then if j+9==m or j+7==m then o[m]={boardUpdates={[m]=17,[m-8]=0,[j]=0},isCapture=true}end elseif p==6 then if k[j+8]==0 then o[j+8]={boardUpdates={[j]=0,[j+8]=i*8},isCapture=false}end;if j~=56 then local q=k[j+9]local r=math.floor(q/8)if q~=0 and r~=i then o[j+9]={boardUpdates={[j]=0,[j+9]=i*8},isCapture=true}end end;if j~=49 then if rightSquare~=0 and rightSquareColor~=i then local rightSquare=k[j+7]local rightSquareColor=math.floor(rightSquare/8)o[j+7]={boardUpdates={[j]=0,[j+7]=i*8},isCapture=true}end end end end;return o end},[2]={defaultCapturing=true,defaultMoves={[1]={{2,1},{-2,1},{2,-1},{-2,-1},{1,2},{-1,2},{1,-2},{-1,-2}}}},[3]={defaultCapturing=true,moveDirections={{-1,-1},{-1,1},{1,-1},{1,1}}},[4]={defaultCapturing=true,moveDirections={{-1,0},{1,0},{0,-1},{0,1}}},[5]={defaultCapturing=true,moveDirections={{-1,-1},{-1,0},{-1,1},{0,-1},{0,1},{1,-1},{1,0},{1,1}}},[6]={defaultCapturing=true,defaultMoves={[1]={{-1,-1},{-1,0},{-1,1},{0,-1},{0,1},{1,-1},{1,0},{1,1}}},specialMoves=function(i,j,k,l,m,n)local o={}if l[i].kingSide then if i==1 then if not(n[61]or n[62]or n[63])and k[62]==0 and k[63]==0 and k[64]==12 then o[63]={boardUpdates={[61]=0,[62]=12,[63]=14,[64]=0},isCapture=false,castling={[1]={kingSide=false,queenSide=false}}}end else if not(n[5]or n[6]or n[7])and k[6]==0 and k[7]==0 and k[8]==20 then o[7]={boardUpdates={[5]=0,[6]=20,[7]=22,[8]=0},isCapture=false,castling={[2]={kingSide=false,queenSide=false}}}end end end;if l[i].queenSide then if i==1 then if not(n[61]or n[60]or n[59])and k[60]==0 and k[59]==0 and k[58]==0 and k[57]==12 then o[60]={boardUpdates={[57]=0,[59]=12,[60]=14,[61]=0},isCapture=false,castling={[1]={kingSide=false,queenSide=false}}}end else if not(n[5]or n[4]or n[3])and k[4]==0 and k[3]==0 and k[2]==0 and k[1]==20 then o[3]={boardUpdates={[5]=0,[4]=20,[3]=22,[1]=0},isCapture=false,castling={[2]={kingSide=false,queenSide=false}}}end end end;return o end}}function ChessGame:new(s)s=s or{}setmetatable(s,self)self.__index=self;s.board=copyTable(s.board)s.castling=copyTable(s.castling)s.legalMoves={}s.targetSquares=s:getTargetSquares(s.board,s.turn)return s end;function ChessGame:isOver()local t=false;for u,v in pairs(self.board)do if self.turn==1 then if v==14 then if self.legalMoves[u]==nil then self.legalMoves[u]=self:getLegalMoves(u)end end else if v==22 then if self.legalMoves[u]==nil then self.legalMoves[u]=self:getLegalMoves(u)end end end;if self.legalMoves[u]~=nil then if getTableSize(self.legalMoves[u])>0 then t=true;break end end end;if not t then for u,v in pairs(self.board)do if self.legalMoves[u]==nil then self.legalMoves[u]=self:getLegalMoves(u)if getTableSize(self.legalMoves[u])>0 then t=true;break end end end end;if not t then if self.turn==2 then return 1 else return 2 end elseif self.halfmoveClock>=50 then return 3 else return 0 end end;function ChessGame:simulateMove(w)local k=copyTable(self.board)for u,v in pairs(w.boardUpdates)do k[u]=v end;return k end;function ChessGame:playMove(j,w,x)if x==nil then x=5 end;if self.board[j]%8==1 or w.isCapture then self.halfmoveClock=0 else self.halfmoveClock=self.halfmoveClock+1 end;for u,v in pairs(w.boardUpdates)do local y,i=v%8,math.floor(v/8)if v~=0 and y==0 then self.board[u]=v+x else self.board[u]=v end end;if w.castling~=nil then for z,A in pairs(w.castling)do for B,C in pairs(A)do self.castling[z][B]=C end end end;if self.turn==1 then self.turn=2 else self.turn=1 end;self.enPassant=w.enPassant;self.legalMoves={}self.targetSquares=self:getTargetSquares(self.board,self.turn)end;function ChessGame:isCheck(k,D)if k==nil then k=self.board end;local E;for u,v in pairs(k)do if D==1 then if v==14 then E=u;break end else if v==22 then E=u;break end end end;local n=self:getTargetSquares(k,D)return n[E]==true end;function ChessGame:getTargetSquares(k,D)if k==nil then k=self.board end;if D==nil then D=self.turn end;local n={}for u,v in pairs(k)do if v~=0 then local y,i=v%8,math.floor(v/8)local F,p=(u-1)%8,math.floor((u-1)/8)local G=self.pieceInfo[y]if i~=D then if G.moveDirections~=nil and G.defaultCapturing then for H,I in pairs(G.moveDirections)do local J,K=F,p;while true do J=J+I[1]K=K+I[2]if not(0<=J and J<8 and 0<=K and K<8)then break end;local L=J+K*8+1;n[L]=true;if k[L]~=0 then break end end end end;if G.defaultMoves~=nil and G.defaultCapturing then local M=G.defaultMoves[i]or G.defaultMoves[1]for H,N in pairs(M)do local J,K=F+N[1],p+N[2]if 0<=J and J<8 and 0<=K and K<8 then local L=J+K*8+1;n[L]=true end end end;if G.capturingSquares~=nil then local O=G.capturingSquares[i]or G.capturingSquares[1]for H,N in pairs(O)do local J,K=F+N[1],p+N[2]if 0<=J and J<8 and 0<=K and K<8 then local L=J+K*8+1;n[L]=true end end end end end end;return n end;function ChessGame:getLegalMoves(u)if self.legalMoves[u]~=nil then return self.legalMoves[u]end;if self.targetSquares==nil then self.targetSquares=ChessGame:getTargetSquares(self.board,self.turn)end;local v=self.board[u]local y,i=v%8,math.floor(v/8)if v==0 or self.turn~=i then return{}end;local E;for P,Q in pairs(self.board)do if i==1 then if Q==14 then E=P;break end else if Q==22 then E=P;break end end end;local R={}local F,p=(u-1)%8,math.floor((u-1)/8)local G=self.pieceInfo[y]if G.moveDirections~=nil then for H,I in pairs(G.moveDirections)do local J,K=F,p;while true do J=J+I[1]K=K+I[2]if 0>J or J>7 or 0>K or K>7 then break end;local S=J+K*8+1;local T=self.board[S]local U=math.floor(T/8)if T==0 or G.defaultCapturing and U~=i then R[S]={boardUpdates={[u]=0,[S]=v},isCapturing=T~=0}end;if T~=0 then break end end end end;if G.defaultMoves~=nil then local M=G.defaultMoves[i]or G.defaultMoves[1]for H,N in pairs(M)do local J,K=F+N[1],p+N[2]if 0<=J and J<8 and 0<=K and K<8 then local S=J+K*8+1;local T=self.board[S]local U=math.floor(T/8)if T==0 or G.defaultCapturing and U~=i then R[S]={boardUpdates={[u]=0,[S]=v},isCapturing=T~=0}end end end end;if G.capturingSquares~=nil then local O=G.capturingSquares[i]or G.capturingSquares[1]for H,N in pairs(O)do local J,K=F+N[1],p+N[2]if 0<=J and J<8 and 0<=K and K<8 then local S=J+K*8+1;local T=self.board[S]local U=math.floor(T/8)if T~=0 and U~=i then R[S]={boardUpdates={[u]=0,[S]=v},isCapturing=true}end end end end;for S,w in pairs(R)do if y==6 then w.castling={[i]={kingSide=false,queenSide=false}}elseif y==4 then if i==1 then if u==57 then w.castling={[1]={queenSide=false}}elseif u==64 then w.castling={[1]={kingSide=false}}end else if u==1 then w.castling={[2]={queenSide=false}}elseif u==8 then w.castling={[2]={kingSide=false}}end end end end;if G.specialMoves~=nil then local V=G.specialMoves(i,u,self.board,self.castling,self.enPassant,self.targetSquares)for S,w in pairs(V)do R[S]=w end end;local W={}for S,w in pairs(R)do local X=self:simulateMove(w)local Y=self:isCheck(X,i)if not Y then W[S]=w end end;return W end;function ChessGame:getAllLegalMoves()local R={}local n={}for u,v in pairs(self.board)do if self.legalMoves[u]==nil then R[u]={}if v~=0 then local y,i=v%8,math.floor(v/8)local F,p=(u-1)%8,math.floor((u-1)/8)local G=self.pieceInfo[y]if G.moveDirections~=nil then for H,I in pairs(G.moveDirections)do local J,K=F,p;while true do J=J+I[1]K=K+I[2]if not(0<=J and J<8 and 0<=K and K<8)then break end;local S=J+K*8+1;local T=self.board[S]local U=math.floor(T/8)if T==0 or G.defaultCapturing and U~=i then if self.turn==i then R[u][S]={boardUpdates={[u]=0,[S]=v},isCapture=T~=0}if y==6 then R[u][S].castling={[i]={kingSide=false,queenSide=false}}elseif y==4 then if i==1 then if u==57 then R[u][S].castling={[1]={queenSide=false}}end else if u==64 then R[u][S].castling={[2]={kingSide=false}}end end end else n[S]=true end end;if T~=0 then break end end end end;if G.defaultMoves~=nil then local M=G.defaultMoves[i]or G.defaultMoves[1]for H,N in pairs(M)do local J,K=N[1]+F,N[2]+p;if 0<=J and J<8 and 0<=K and K<8 then local S=J+K*8+1;local T=self.board[S]local U=math.floor(T/8)if T==0 or G.defaultCapturing and U~=i then if self.turn==i then R[u][S]={boardUpdates={[u]=0,[S]=v},isCapture=T~=0}if y==4 or y==6 then R[u][S].castling={[i]={kingSide=false,queenSide=false}}end else n[S]=true end end end end end;if G.capturingSquares~=nil then local O=G.capturingSquares[i]or G.capturingSquares[1]for H,N in pairs(O)do local J,K=N[1]+F,N[2]+p;if 0<=J and J<8 and 0<=K and K<8 then local S=J+K*8+1;if self.board[S]~=0 and math.floor(self.board[S]/8)~=i then if self.turn==i then R[u][S]={boardUpdates={[u]=0,[S]=v},isCapturing=true}else n[S]=true end end end end end end end end;for u,v in pairs(self.board)do if v~=0 then local y,i=v%8,math.floor(v/8)local G=self.pieceInfo[y]if self.turn==i and G.specialMoves~=nil then local V=G.specialMoves(i,u,self.board,self.castling,self.enPassant,n)for S,w in pairs(V)do R[u][S]=w end end end end;local Z={}for u,_ in pairs(R)do for S,w in pairs(_)do local X=self:simulateMove(w)local Y=self:isCheck(X,self.turn)if Y then table.insert(Z,{u,S})end end end;for c,d in pairs(Z)do local u,S=d[1],d[2]R[u][S]=nil end;return R end;local a0={en={["White"]="White",["Black"]="Black",["Last game"]="Last game",["White won"]="White won",["Black won"]="Black won",["Tie"]="Tie",["W"]="W",["B"]="B",["Resign"]="Resign",["Promotion"]="Promotion",["Queue"]="Queue",["Queen"]="Queen",["Rook"]="Rook",["Bishop"]="Bishop",["Knight"]="Knight"},tr={["White"]="Beyaz",["Black"]="Siyah",["Last game"]="Son oyun",["White won"]="Beyaz kazandı",["Black won"]="Siyah kazandı",["Tie"]="Berabere",["W"]="B",["B"]="S",["Resign"]="Terk et",["Promotion"]="Terfi",["Queue"]="Sıra",["Queen"]="Vezir",["Rook"]="Kale",["Bishop"]="Fil",["Knight"]="At"}}local a1={}for a2,a3 in pairs(a0)do table.insert(a1,a2)end;local a4='<C><P /><Z><S /><D /><O /></Z></C>'local a5={wk="182bc3b5b77.png",bk="182bc3ba8f0.png",wq="182bc3bf6ed.png",bq="182bc3c4558.png",wr="182bc3c933c.png",br="182bc3ce152.png",wb="182bc3d2f4a.png",bb="182bc3d7d6a.png",wn="182bc3dcbb7.png",bn="182bc3e19c3.png",wp="182bc3e67c8.png",bp="182bc3eb608.png",board="182bc3f033d.png",legalMove="182bc3f522a.png",nextPosition="182bc3fa064.png",previousPosition="182bc3fee8f.png"}local a6={[09]=a5.wp,[10]=a5.wn,[11]=a5.wb,[12]=a5.wr,[13]=a5.wq,[14]=a5.wk,[17]=a5.bp,[18]=a5.bn,[19]=a5.bb,[20]=a5.br,[21]=a5.bq,[22]=a5.bk}local a7={}local a8=ChessGame:new()local a9={}local aa={}local ab={Q=5,R=4,B=3,N=2}local ac={Q="Queen",R="Rook",B="Bishop",N="Knight"}local ad={}local ae={}local af={}local ag={}local ah={result=0}local ai={}function isPlayerPlaying(aj)if af[1]==aj then return 1 elseif af[2]==aj then return 2 else return false end end;function updateTextAreaLanguage(ak,aj,al,am)local an=tfm.get.room.playerList[aj]local a3=a0[ai[aj]]or a0[an.language]or a0["en"]local ao={}for H,ap in pairs(am)do ao[H]=a3[ap]end;local aq=string.format(al,table.unpack(ao))ui.updateTextArea(ak,aq,aj)end;function updateTextAreaLanguageAll(ak,al,am)for aj,an in pairs(tfm.get.room.playerList)do updateTextAreaLanguage(ak,aj,al,am)end end;function selectPlayers()af={}local ar=getTableSize(tfm.get.room.playerList)if ar>=2 then if math.random(0,1)==1 then af[1]=ag[1]af[2]=ag[2]else af[1]=ag[2]af[2]=ag[1]end;updateTextAreaLanguage(1,af[1],"<J><a href='event:resign'>%s</a></J>",{"Resign"})updateTextAreaLanguage(1,af[2],"<J><a href='event:resign'>%s</a></J>",{"Resign"})updateTextAreaLanguageAll(3,"<font color='#eeeeee'>%s</font>\n"..af[1].."\n<font color='#111111'>%s</font>\n"..af[2],{"White","Black"})else updateTextAreaLanguageAll(3,"<font color='#eeeeee'>%s</font>\n-\n<font color='#111111'>%s</font>\n-",{"White","Black"})end end;function getResults()if ah.result==0 then return{args={},text=""}elseif ah.result==1 then return{args={"Last game","White won","W","B"},text="<J>%s</J>\n<VI>%s</VI>\n<font color='#eeeeee'>(%s)</font> "..ah.white.."\n<font color='#111111'>(%s)</font> "..ah.black}elseif ah.result==2 then return{args={"Last game","Black won","W","B"},text="<J>%s</J>\n<VI>%s</VI>\n<font color='#eeeeee'>(%s)</font> "..ah.white.."\n<font color='#111111'>(%s)</font> "..ah.black}elseif ah.result==3 then return{args={"Last game","Tie","W","B"},text="<J>%s</J>\n<VI>%s</VI>\n<font color='#eeeeee'>(%s)</font> "..ah.white.."\n<font color='#111111'>(%s)</font> "..ah.black}end end;function updateLanguage(aj)local aq=getResults()if isPlayerPlaying(aj)then updateTextAreaLanguage(1,aj,"<J><a href='event:resign'>%s</a></J>",{"Resign"})else updateTextAreaLanguage(1,aj,"<N2>%s</N2>",{"Resign"})end;updateTextAreaLanguage(2,aj,"<J>%s</J>\n<a href='event:promotionQ'>Q</a> <a href='event:promotionR'>R</a> <a href='event:promotionB'>B</a> <a href='event:promotionN'>N</a>",{"Promotion"})if#af==2 then updateTextAreaLanguage(3,aj,"<font color='#eeeeee'>%s</font>\n"..af[1].."\n<font color='#111111'>%s</font>\n"..af[2],{"White","Black"})else updateTextAreaLanguage(3,aj,"<font color='#eeeeee'>%s</font>\n-\n<font color='#111111'>%s</font>\n-",{"White","Black"})end;updateTextAreaLanguage(4,aj,aq.text,aq.args)updateTextAreaLanguageAll(5,"<J>%s</J>\n"..table.concat(ag,"\n"),{"Queue"})end;function eventNewPlayer(aj)table.insert(ag,aj)system.bindMouse(aj,true)updateLanguage(aj)if#ag==2 then selectPlayers()end end;function eventPlayerLeft(aj)if#af==2 then if af[1]==aj then gameOverSignal(2,false)elseif af[2]==aj then gameOverSignal(1,false)else for u,as in pairs(ag)do if aj==as then table.remove(ag,u)break end end end;updateTextAreaLanguageAll(5,"<J>%s</J>\n"..table.concat(ag,"\n"),{"Queue"})end end;function eventNewGame()for aj,an in pairs(tfm.get.room.playerList)do tfm.exec.killPlayer(aj)end end;function gameOverSignal(at,au)ah={result=at,white=af[1],black=af[2]}local aq=getResults()updateTextAreaLanguageAll(4,aq.text,aq.args)if au or at==1 then table.insert(ag,af[1])updateTextAreaLanguage(1,af[1],"<N2>%s</N2>",{"Resign"})end;if au or at==2 then table.insert(ag,af[2])updateTextAreaLanguage(1,af[2],"<N2>%s</N2>",{"Resign"})end;if at==1 or at==2 then tfm.exec.setPlayerScore(af[at],1,true)end;table.remove(ag,1)table.remove(ag,1)for g,h in pairs(ad)do tfm.exec.removeImage(h)end;ad={}for g,h in pairs(ae)do tfm.exec.removeImage(h)end;ae={}a9={}a8=ChessGame:new()renderBoard()selectPlayers()end;function eventMouse(aj,F,p)local av,aw=math.floor((F-220)/45),math.floor((p-30)/45)local L=av+aw*8+1;if av<0 or av>7 or aw<0 or aw>7 or#af~=2 or af[a8.turn]~=aj then return end;if a9[aj]==nil then if a8.legalMoves[L]==nil then a8.legalMoves[L]=a8:getLegalMoves(L)end;if getTableSize(a8.legalMoves[L])>0 then for S,w in pairs(a8.legalMoves[L])do local J,K=(S-1)%8,math.floor((S-1)/8)local ax=tfm.exec.addImage(a5.legalMove,"?"..#ad+128,220+J*45,30+K*45,aj)table.insert(ad,ax)end;a9[aj]=L end else local ay=a9[aj]if a8.legalMoves[ay][L]~=nil then a8:playMove(ay,a8.legalMoves[ay][L],aa[aj])renderBoard()for g,h in pairs(ae)do tfm.exec.removeImage(h)end;local az,aA=(ay-1)%8,math.floor((ay-1)/8)local aB,aC=(L-1)%8,math.floor((L-1)/8)ae[1]=tfm.exec.addImage(a5.previousPosition,"?256",220+az*45,30+aA*45,nil)ae[2]=tfm.exec.addImage(a5.nextPosition,"?256",220+aB*45,30+aC*45,nil)local at=a8:isOver()if at~=0 then gameOverSignal(at,true)end end;a9[aj]=nil;for g,h in pairs(ad)do tfm.exec.removeImage(h)end;ad={}end end;function renderBoard()for g,h in pairs(a7)do tfm.exec.removeImage(h)end;a7={}for u,v in pairs(a8.board)do if a6[v]~=nil then local F,p=(u-1)%8,math.floor((u-1)/8)a7[u]=tfm.exec.addImage(a6[v],"?"..u,220+F*45,30+p*45,nil)end end end;function eventTextAreaCallback(ak,aj,aD)if aD=="resign"then if af[1]==aj then gameOverSignal(2,true)elseif af[2]==aj then gameOverSignal(1,true)end elseif string.sub(aD,0,9)=="promotion"then local aE=string.sub(aD,10,10)local an=tfm.get.room.playerList[aj]local a3=a0[ai[aj]]or a0[an.language]or a0["en"]aa[aj]=ab[aE]ui.addTextArea(tfm.get.room.playerList[aj].id*16+18,a3[ac[aE]],aj,100,75)end end;function eventChatCommand(aj,aF)local aG={}for aH in string.gmatch(aF,"%a+")do table.insert(aG,aH)end;local aI=aG[1]table.remove(aG,1)if aI=="lang"then if#aG==0 then ui.addPopup(1,0,"Available Languages\n"..table.concat(a1,"\n"),aj)else ai[aj]=aG[1]updateLanguage(aj)end end end;ui.addTextArea(1,"",nil,0,30,90,15)ui.addTextArea(2,"",nil,0,60,90,30)ui.addTextArea(3,"",nil,0,105,200,60)ui.addTextArea(4,"",nil,0,315,200,75)ui.addTextArea(5,"",nil,600,30,200,360)tfm.exec.disableAutoNewGame()tfm.exec.disableAutoShaman()tfm.exec.disableAfkDeath()tfm.exec.disableAutoScore()tfm.exec.disableMortCommand()system.disableChatCommandDisplay(nil,true)tfm.exec.newGame(a4)ui.setMapName("Chess by Adanakebapi#0000")for aj,an in pairs(tfm.get.room.playerList)do eventNewPlayer(aj)end;tfm.exec.addImage(a5.board,"?0",220,30,nil)renderBoard()