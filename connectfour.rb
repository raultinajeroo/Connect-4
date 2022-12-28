# Ruby Assignment Code Skeleton
# Nigel Ward, University of Texas at El Paso
# April 2015, April 2019 
# borrowing liberally from Gregory Brown's tic-tac-toe game

#------------------------------------------------------------------
class Board
  def initialize
  @board = [[nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil] ]
  end

  # process a sequence of moves, each just a column number
  def addDiscs(firstPlayer, moves)
    if firstPlayer == :R
      players = [:R, :O].cycle
    else 
      players = [:O, :R].cycle
    end
    moves.each {|c| addDisc(players.next, c)}
  end 

  def addDisc(player, column)
    if column >= 7 || column < 0
      puts "  addDisc(#{player},#{column}): out of bounds; move forfeit"
      return # Avoids exceptions by exiting when out of bounds
    end 
    firstFreeRow =  @board.transpose.slice(column).rindex(nil)
    if firstFreeRow == nil  
      puts "  addDisc(#{player},#{column}): column full already; move forfeit"
      return # Avoids exceptions by exiting when out of bounds
    end
    update(firstFreeRow, column, player)
  end

  def update(row, col, player)
    @board[row][col] = player
  end

  def pop(column)
    if (0..5).all?{|r| @board[r][column] == nil}
        puts "  pop(#{column}): column empty already; move forfeit"
        return # Exit execution
    end

    for r in 4.downto(0)
        @board[r+1][column] = @board[r][column]
    end
    @board[0][column] = nil
  end

  def print
    puts @board.map {|row| row.map { |e| e || " "}.join("|")}.join("\n")
    puts "\n"
  end

  def hasWon? (player)
    return verticalWin?(player)| horizontalWin?(player) | 
           diagonalUpWin?(player)| diagonalDownWin?(player)
  end 

  def verticalWin? (player)
    (0..6).any? {|c| (0..2).any? {|r| fourFromTowards?(player, r, c, 1, 0)}}
  end

  def horizontalWin? (player)
    (0..3).any? {|c| (0..5).any? {|r| fourFromTowards?(player, r, c, 0, 1)}}
  end

  def diagonalUpWin? (player)
    (0..3).any? {|c| (0..2).any? {|r| fourFromTowards?(player, r, c, 1, 1)}}
  end

  def diagonalDownWin? (player)
    (0..3).any? {|c| (3..5).any? {|r| fourFromTowards?(player, r, c, -1, 1)}}
  end

  def cylindricalHasWon? (player)
    return verticalWin?(player)| cylindricalHorizontalWin?(player) | 
           cylindricalDiagonalUpWin?(player)| cylindricalDiagonalDownWin?(player)
  end 

  def cylindricalHorizontalWin? (player)
    (0..6).any? {|c| (0..5).any? {|r| cylindricalFourFromTowards?(player, r, c, 0, 1)}}
  end

  def cylindricalDiagonalUpWin? (player)
    (0..6).any? {|c| (0..2).any? {|r| cylindricalFourFromTowards?(player, r, c, 1, 1)}}
  end

  def cylindricalDiagonalDownWin? (player)
    (0..6).any? {|c| (3..5).any? {|r| cylindricalFourFromTowards?(player, r, c, -1, 1)}}
  end

  def cylindricalFourFromTowards?(player, r, c, dx, dy)
    return (0..3).all?{|step| @board[r+step*dx][(c+step*dy) % 7] == player}
  end

  def fourFromTowards?(player, r, c, dx, dy)
    return (0..3).all?{|step| @board[r+step*dx][c+step*dy] == player}
  end

  def threeFromTowards?(player, r, c, dx, dy)
    return (0...3).all?{|step| @board[r+step*dx][c+step*dy] == player}
  end

  def nextWinningMove(player, opponent, r, c, dx, dy)    
    if (0..3).one?{|step| @board[r+step*dx][c+step*dy] == nil}
        if (0..3).none?{|step| @board[r+step*dx][c+step*dy] == opponent}
            for step in 0..3
                if @board[r+step*dx][c+step*dy] == nil
                    addDisc(player, c+step*dy)
                end
            end
        end
    end
  end

end # Board
#------------------------------------------------------------------

def robotMove(board)
    if not verticalMove(board)
       if not diagonalDownMove(board)
            if not diagonalUpMove(board)
                if not block(board)
                    board.addDisc(:R, rand(0..6)) # Plays random moves
                end
            end
        end
    end
end

def block(board)
    return (0..3).any? {|c| (0..2).any? {|r| board.nextWinningMove(:R, :R, r, c, 1, 1)}} |
           (0..3).any? {|c| (3..5).any? {|r| board.nextWinningMove(:R, :R, r, c, -1, 1)}} | 
           (0..6).any? {|c| (0..2).any? {|r| board.nextWinningMove(:R, :R, r, c, 1, 0)}} |
           (0..6).any? {|c| (0..5).any? {|r| board.nextWinningMove(:R, :R, r, c, 0, 1)}}
end

def diagonalUpMove (board)
    (0..3).any? {|c| (0..2).any? {|r| board.nextWinningMove(:R, :O, r, c, 1, 1)}}
  end

def diagonalDownMove (board)
    (0..3).any? {|c| (3..5).any? {|r| board.nextWinningMove(:R, :O, r, c, -1, 1)}}
end

def verticalMove(board)
    (0..6).any? {|c| (0..2).any? {|r| board.nextWinningMove(:R, :O, r, c, 1, 0)}}
end


#------------------------------------------------------------------

def gameLoop()
    board = Board.new
    while not board.hasWon?(:R)
        # Show board to player
        board.print
        # Get and process player move
        print "[1] Pop or [2] Add: "
        STDOUT.flush
        choice = gets.chomp.to_i
        print "Choose a column (0 - 6): "
        STDOUT.flush
        column = gets.chomp.to_i
        case choice
        when 1
            board.pop(column)
        else
            board.addDisc(:O,column)
        end
        if board.hasWon?(:O)
            break
        end
        # Process robot move
        robotMove(board)
    end
    puts "GAME FINISHED!"
    board.print
end

gameLoop()


#------------------------------------------------------------------
def testResult(testID, move, targets, intent)
  if targets.member?(move)
    puts("testResult: passed test #{testID}")
  else
    puts("testResult: failed test #{testID}: \n moved to #{move}, which wasn't one of #{targets}; \n failed: #{intent}")
  end
end


=begin
#------------------------------------------------------------------
# test some robot-player behaviors
testboard1 = Board.new
testboard1.addDisc(:R,4)
testboard1.addDisc(:O,4)
testboard1.addDisc(:R,5)
testboard1.addDisc(:O,5)
testboard1.addDisc(:R,6)
testboard1.addDisc(:O,6)
testResult(:hwin, robotMove(:R, testboard1),[3], 'robot should take horizontal win')
testboard1.print

testboard2 = Board.new
testboard2.addDiscs(:R, [3, 1, 3, 2, 3, 4]);
testResult(:vwin, robotMove(:R, testboard2), [3], 'robot should take vertical win')
testboard2.print

testboard3 = Board.new
testboard3.addDiscs(:O, [3, 1, 4, 5, 2, 1, 6, 0, 3, 4, 5, 3, 2, 2, 6 ]);
testResult(:dwin, robotMove(:R, testboard3), [3], 'robot should take diagonal win')
testboard3.print

testboard4 = Board.new
testboard4.addDiscs(:O, [1,1,2,2,3])
testResult(:preventHoriz, robotMove(:R, testboard4), [4], 'robot should avoid giving win')
testboard4.print
=end

#------------------------------------------------------------------
