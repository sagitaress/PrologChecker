from Tkinter import *
from pyswip import Prolog

class Pawn():
    def __init__(self,name,row,col,color,r=80):
        self.name = name
        self.row = row
        self.col = col
        self.radius = r
        self.color = color
        self.hos = False

    def move(self,row,col):
        self.col = col
        self.row = row

    def hos(self):
        self.hos = True

    def getName(self):
        return self.name

    def getRow(self):
        return self.row

    def getColumn(self):
        return self.col


class Board(Frame):
    def __init__(self,pawnList1,pawnList2,r,root,game):
        Frame.__init__(self,root)
        self.radius = r
        self.game = game
        self.canvas = Canvas(width=self.radius*8-2,height=self.radius*8-2,bg='white')
        self.canvas.bind("<Button-1>",self.clicked)
        self.canvas.pack()

        self.pawnList1 = pawnList1
        self.pawnList2 = pawnList2

        self.stateTable = [[None for i in range(8)] for j in range(8)]
        self.initializeTable()

        self.drawBoard()
        self.drawPawns()

    def checkTurn(self, p):
        if self.game.playerOne and p in self.pawnList1:
            return True
        elif not self.game.playerOne and p in self.pawnList2:
            return True
        else:
            return False

    def clicked(self,event):
        row = event.y//self.radius
        col = event.x//self.radius
        p = self.getPawnFromCoord(row,col)
        newPos = row*10+col
        if p!=None and not self.game.pawnSelected and self.checkTurn(p) and not self.game.chaining:
            self.game.selectPawn(p)
            self.highlightPawn(p)
        elif p==None:#clciked on a blank space
            if self.game.selectedPawn !=None: #pawn selected
                self.deletePawn(self.game.selectedPawn)
                self.game.move(newPos)
                if self.game.selectedPawn != None:
                    self.drawPawn(self.game.selectedPawn)
            if not self.game.chaining:
                self.game.unselectPawn()
            else:
                self.highlightPawn(self.game.selectedPawn)

    def highlightPawn(self,p):
        rowCoord = p.row*p.radius
        colCoord = p.col*p.radius
        self.canvas.create_oval(colCoord,rowCoord,colCoord+p.radius,rowCoord+p.radius,fill= 'yellow')

    def getPawnFromCoord(self,row,col):
        for pawn in self.pawnList1:
            if self.isIn(row,col,pawn):
                return pawn
        for pawn in self.pawnList2:
            if self.isIn(row,col,pawn):
                return pawn


    def isIn(self,row,col,p):
        if p.row == row and p.col ==col:
            return True
        else:
            return False


    def initializeTable(self):
        for i in range(8):
            row1 = self.pawnList1[i].row
            col1 = self.pawnList1[i].col
            row2 = self.pawnList2[i].row
            col2 = self.pawnList2[i].col
            self.stateTable[row1][col1] = self.pawnList1[i]
            self.stateTable[row2][col2] = self.pawnList2[i]

    def drawBoard(self):
        for i in range(8):
            for j in range(8):
                if (i+j)%2 ==0:
                    color = 'black'
                else:
                    color = 'white'
                rowCoord = i*self.radius
                colCoord = j*self.radius
                self.canvas.create_rectangle(rowCoord,colCoord,rowCoord+self.radius,colCoord+self.radius,fill=color)

    def drawPawns(self):
        for i in range(8):
            self.drawPawn(self.pawnList1[i])
            self.drawPawn(self.pawnList2[i])

    def drawPawn(self,p):
        rowCoord = p.row*p.radius
        colCoord = p.col*p.radius
        self.canvas.create_oval(colCoord,rowCoord,colCoord+p.radius,rowCoord+p.radius,fill= p.color)

    def deletePawn(self,p):
        rowCoord = p.row*p.radius
        colCoord = p.col*p.radius
        self.canvas.create_oval(colCoord,rowCoord,colCoord+p.radius,rowCoord+p.radius,fill= 'black')

class Game():
    def __init__(self,radius=80):
        self.win = Tk()
        self.radius = radius
        self.pawnList1 = []
        self.pawnList2 = []
        self.generatePawns()
        self.playerOne = True
        self.pawnSelected = False
        self.chaining = False
        self.capturing = False
        self.selectedPawn = None
        self.captured = None
        self.prolog = Prolog()
        self.prolog.consult("clauses.pl")
        self.prolog.asserta("hos(dummy)")
        self.defaultPosition()
        self.board = Board(self.pawnList1,self.pawnList2,self.radius,self.win,self)
        self.board.mainloop()

    def getPawnByName(self,name):
        for p in self.pawnList1:
            if p.getName() == name:
                return p
        for p in self.pawnList2:
            if p.getName() == name:
                return p

    def checkMove(self,pos):
        validMoveQuery = "canMove("+self.selectedPawn.getName()+",NewPos)"
        l = list(self.prolog.query(validMoveQuery))
        validMoves = []
        for i in l:
            validMoves.extend(i.values())
        if pos in validMoves:
            return True
        else:
            return False

    def queryCapturing(self,p):
        capturingQuery = "canEat("+p.getName()+",Target,NewPos)"
        l = list(self.prolog.query(capturingQuery))
        posAfterCapturing = []
        for i in l:
            posAfterCapturing.extend(i.values())
        return posAfterCapturing

    def checkCapturing(self,pos):
        posAfterCapturing = self.queryCapturing(self.selectedPawn)
        if pos in posAfterCapturing:
            self.captured = self.getPawnByName(posAfterCapturing[posAfterCapturing.index(pos)+1])
            self.capturing = True
            return True
        else:
            return False

    def defaultPosition(self):
        positions = ["position(a1,60)",
                     "position(b1,71)",
                     "position(c1,62)",
                     "position(d1,73)",
                     "position(e1,64)",
                     "position(f1,75)",
                     "position(g1,66)",
                     "position(h1,77)",
                     "position(a2,00)",
                     "position(b2,11)",
                     "position(c2,02)",
                     "position(d2,13)",
                     "position(e2,04)",
                     "position(f2,15)",
                     "position(g2,06)",
                     "position(h2,17)"]
        for position in positions:
            self.prolog.assertz(position)
        for pos in self.prolog.query("position(X,Y)"):
            print pos["X"], pos["Y"]

    def modifyPosition(self):
        for position in self.prolog.query("retractall(position(_,_))"):
            pass

        for pawn in self.pawnList1:
            self.prolog.asserta(
                "position(" + pawn.getName() + "," +
                str(pawn.getRow()) + str(pawn.getColumn()) + ")")
        
        for pawn in self.pawnList2:
            self.prolog.assertz(
                "position(" + pawn.getName() + "," +
                str(pawn.getRow()) + str(pawn.getColumn()) + ")")
            
    def generatePawns(self):
        for i in range(8):
            name = chr(97+i)
            self.pawnList1.append(Pawn(name+"1",6+(i%2),i,'blue',self.radius))
            self.pawnList2.append(Pawn(name+"2",0+(i%2),i,'red',self.radius))

    def selectPawn(self,p):
        self.pawnSelected = True
        self.selectedPawn = p
#        self.board.highlightPawn(p)

    def unselectPawn(self):
        self.pawnSelected = False
#        self.board.drawPawn(self.selectedPawn)
        self.selectedPawn = None

    def addHos(self,pawn):
        for position in self.prolog.query("retractall(hos(_))"):
            pass
        self.prolog.asserta("hos("+pawn.getName()+")")

    def checkHos(self,pawn):
        if pawn in self.pawnList1:
            if pawn.row == 0:
                pawn.hos = True
                self.addHos(pawn)
        elif pawn in self.pawnList2:
            if pawn.row == 7:
                pawn.hos = True
                self.addHos(pawn)

    def punish(self):
        if self.playerOne:
            for p in self.pawnList1:
                if len(self.queryCapturing(p)) > 0:
                    self.deletePawn(p)
        else:
            for p in self.pawnList2:
                if len(self.queryCapturing(p)) > 0:
                    self.deletePawn(p)

    def move(self,pos):
        if self.checkCapturing(pos) or self.checkMove(pos):
            self.selectedPawn.move(pos//10,pos%10)
            if self.capturing:
                self.deletePawn(self.captured)
            moved = True
        else:
            moved = False

        if moved:
            self.checkHos(self.selectedPawn)
            self.chaining = True
            if not self.capturing:
                self.punish()
            self.modifyPosition()
            if self.selectedPawn == None or (len(self.queryCapturing(self.selectedPawn)) == 0 and self.capturing or not self.capturing):
                self.playerOne = not self.playerOne
                self.chaining = False
                self.capturing = False
                self.captured = None
            print "---------"
            for pos in self.prolog.query("position(X,Y)"):
                print pos["X"], pos["Y"]
        
    def deletePawn(self,pawn):
        if pawn in self.pawnList1:
            self.pawnList1.remove(pawn)
        else:
            self.pawnList2.remove(pawn)
        self.board.deletePawn(pawn)
        if pawn == self.selectedPawn:
            self.selectedPawn = None

Game(80)

