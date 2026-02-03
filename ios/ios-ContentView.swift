import SwiftUI

struct ContentView: View {
    @StateObject private var game = ChessGame()
    
    var body: some View {
        VStack(spacing: 20) {
            Text(game.statusText)
                .font(.title2)
                .foregroundColor(.white)
                .padding()
            
            ChessBoardView(game: game)
                .aspectRatio(1, contentMode: .fit)
                .padding()
            
            HStack(spacing: 20) {
                Button(action: { game.newGame() }) {
                    Text("New Game")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 140, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                Button(action: { game.undoMove() }) {
                    Text("Undo Move")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 140, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.17, green: 0.24, blue: 0.31))
    }
}

struct ChessBoardView: View {
    @ObservedObject var game: ChessGame
    
    var body: some View {
        GeometryReader { geometry in
            let squareSize = geometry.size.width / 8
            
            ZStack {
                // Board squares
                ForEach(0..<8) { row in
                    ForEach(0..<8) { col in
                        Rectangle()
                            .fill((row + col) % 2 == 0 ? 
                                  Color(red: 0.94, green: 0.85, blue: 0.71) : 
                                  Color(red: 0.71, green: 0.53, blue: 0.39))
                            .frame(width: squareSize, height: squareSize)
                            .position(x: CGFloat(col) * squareSize + squareSize/2,
                                    y: CGFloat(row) * squareSize + squareSize/2)
                    }
                }
                
                // Selected square highlight
                if let selected = game.selectedSquare {
                    Rectangle()
                        .fill(Color.green.opacity(0.5))
                        .frame(width: squareSize, height: squareSize)
                        .position(x: CGFloat(selected.col) * squareSize + squareSize/2,
                                y: CGFloat(selected.row) * squareSize + squareSize/2)
                }
                
                // Valid move indicators
                ForEach(game.validMoves, id: \.self) { move in
                    Circle()
                        .fill(game.board[move.row][move.col].isEmpty ? 
                              Color.green.opacity(0.5) : Color.clear)
                        .frame(width: squareSize * 0.3, height: squareSize * 0.3)
                        .position(x: CGFloat(move.col) * squareSize + squareSize/2,
                                y: CGFloat(move.row) * squareSize + squareSize/2)
                    
                    Circle()
                        .stroke(Color.red.opacity(0.7), lineWidth: 3)
                        .frame(width: squareSize * 0.85, height: squareSize * 0.85)
                        .position(x: CGFloat(move.col) * squareSize + squareSize/2,
                                y: CGFloat(move.row) * squareSize + squareSize/2)
                        .opacity(game.board[move.row][move.col].isEmpty ? 0 : 1)
                }
                
                // Pieces
                ForEach(0..<8) { row in
                    ForEach(0..<8) { col in
                        if let piece = game.board[row][col].piece {
                            Text(piece.symbol)
                                .font(.system(size: squareSize * 0.7))
                                .position(x: CGFloat(col) * squareSize + squareSize/2,
                                        y: CGFloat(row) * squareSize + squareSize/2)
                        }
                    }
                }
                
                // Tap gesture
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { value in
                                let col = Int(value.location.x / squareSize)
                                let row = Int(value.location.y / squareSize)
                                if row >= 0 && row < 8 && col >= 0 && col < 8 {
                                    game.handleTap(row: row, col: col)
                                }
                            }
                    )
            }
        }
    }
}

// MARK: - Chess Game Logic

class ChessGame: ObservableObject {
    @Published var board: [[Square]] = []
    @Published var selectedSquare: Position?
    @Published var validMoves: [Position] = []
    @Published var currentPlayer: Player = .white
    @Published var statusText: String = "White to move"
    
    private var moveHistory: [Move] = []
    
    init() {
        newGame()
    }
    
    func newGame() {
        board = [
            [.piece(.rook, .black), .piece(.knight, .black), .piece(.bishop, .black), .piece(.queen, .black), .piece(.king, .black), .piece(.bishop, .black), .piece(.knight, .black), .piece(.rook, .black)],
            Array(repeating: Square.piece(.pawn, .black), count: 8),
            Array(repeating: Square.empty, count: 8),
            Array(repeating: Square.empty, count: 8),
            Array(repeating: Square.empty, count: 8),
            Array(repeating: Square.empty, count: 8),
            Array(repeating: Square.piece(.pawn, .white), count: 8),
            [.piece(.rook, .white), .piece(.knight, .white), .piece(.bishop, .white), .piece(.queen, .white), .piece(.king, .white), .piece(.bishop, .white), .piece(.knight, .white), .piece(.rook, .white)]
        ]
        currentPlayer = .white
        selectedSquare = nil
        validMoves = []
        moveHistory = []
        updateStatus()
    }
    
    func handleTap(row: Int, col: Int) {
        if let selected = selectedSquare {
            let move = Position(row: row, col: col)
            if validMoves.contains(move) {
                makeMove(from: selected, to: move)
                selectedSquare = nil
                validMoves = []
                
                if isCheckmate(player: currentPlayer) {
                    statusText = "\(currentPlayer == .white ? "Black" : "White") wins!"
                } else if isCheck(player: currentPlayer) {
                    statusText = "\(currentPlayer == .white ? "White" : "Black") in check"
                } else {
                    updateStatus()
                }
            } else if let piece = board[row][col].piece, piece.player == currentPlayer {
                selectedSquare = Position(row: row, col: col)
                validMoves = getValidMoves(from: Position(row: row, col: col))
            } else {
                selectedSquare = nil
                validMoves = []
            }
        } else if let piece = board[row][col].piece, piece.player == currentPlayer {
            selectedSquare = Position(row: row, col: col)
            validMoves = getValidMoves(from: Position(row: row, col: col))
        }
    }
    
    func makeMove(from: Position, to: Position) {
        let piece = board[from.row][from.col].piece!
        let captured = board[to.row][to.col].piece
        
        moveHistory.append(Move(from: from, to: to, piece: piece, captured: captured, player: currentPlayer))
        
        board[to.row][to.col] = .piece(piece.type, piece.player)
        board[from.row][from.col] = .empty
        
        // Pawn promotion
        if piece.type == .pawn {
            if (piece.player == .white && to.row == 0) || (piece.player == .black && to.row == 7) {
                board[to.row][to.col] = .piece(.queen, piece.player)
            }
        }
        
        currentPlayer = currentPlayer == .white ? .black : .white
    }
    
    func undoMove() {
        guard let lastMove = moveHistory.popLast() else { return }
        
        board[lastMove.from.row][lastMove.from.col] = .piece(lastMove.piece.type, lastMove.piece.player)
        if let captured = lastMove.captured {
            board[lastMove.to.row][lastMove.to.col] = .piece(captured.type, captured.player)
        } else {
            board[lastMove.to.row][lastMove.to.col] = .empty
        }
        
        currentPlayer = lastMove.player
        selectedSquare = nil
        validMoves = []
        updateStatus()
    }
    
    func updateStatus() {
        statusText = "\(currentPlayer == .white ? "White" : "Black") to move"
    }
    
    func getValidMoves(from position: Position) -> [Position] {
        guard let piece = board[position.row][position.col].piece else { return [] }
        
        var moves: [Position] = []
        
        switch piece.type {
        case .pawn:
            moves = getPawnMoves(from: position, player: piece.player)
        case .rook:
            moves = getRookMoves(from: position, player: piece.player)
        case .knight:
            moves = getKnightMoves(from: position, player: piece.player)
        case .bishop:
            moves = getBishopMoves(from: position, player: piece.player)
        case .queen:
            moves = getQueenMoves(from: position, player: piece.player)
        case .king:
            moves = getKingMoves(from: position, player: piece.player)
        }
        
        return moves.filter { move in
            !leavesKingInCheck(from: position, to: move, player: piece.player)
        }
    }
    
    func getPawnMoves(from pos: Position, player: Player) -> [Position] {
        var moves: [Position] = []
        let direction = player == .white ? -1 : 1
        let startRow = player == .white ? 6 : 1
        
        // Forward move
        let newRow = pos.row + direction
        if isInBounds(row: newRow, col: pos.col) && board[newRow][pos.col].isEmpty {
            moves.append(Position(row: newRow, col: pos.col))
            
            // Double move from start
            if pos.row == startRow {
                let doubleRow = pos.row + 2 * direction
                if board[doubleRow][pos.col].isEmpty {
                    moves.append(Position(row: doubleRow, col: pos.col))
                }
            }
        }
        
        // Captures
        for dc in [-1, 1] {
            let newCol = pos.col + dc
            if isInBounds(row: newRow, col: newCol) {
                if let targetPiece = board[newRow][newCol].piece, targetPiece.player != player {
                    moves.append(Position(row: newRow, col: newCol))
                }
            }
        }
        
        return moves
    }
    
    func getRookMoves(from pos: Position, player: Player) -> [Position] {
        return getSlidingMoves(from: pos, directions: [(1,0), (-1,0), (0,1), (0,-1)], player: player)
    }
    
    func getBishopMoves(from pos: Position, player: Player) -> [Position] {
        return getSlidingMoves(from: pos, directions: [(1,1), (1,-1), (-1,1), (-1,-1)], player: player)
    }
    
    func getQueenMoves(from pos: Position, player: Player) -> [Position] {
        return getSlidingMoves(from: pos, directions: [(1,0), (-1,0), (0,1), (0,-1), (1,1), (1,-1), (-1,1), (-1,-1)], player: player)
    }
    
    func getKnightMoves(from pos: Position, player: Player) -> [Position] {
        var moves: [Position] = []
        let offsets = [(2,1), (2,-1), (-2,1), (-2,-1), (1,2), (1,-2), (-1,2), (-1,-2)]
        
        for (dr, dc) in offsets {
            let newRow = pos.row + dr
            let newCol = pos.col + dc
            if isInBounds(row: newRow, col: newCol) {
                if board[newRow][newCol].isEmpty || board[newRow][newCol].piece!.player != player {
                    moves.append(Position(row: newRow, col: newCol))
                }
            }
        }
        
        return moves
    }
    
    func getKingMoves(from pos: Position, player: Player) -> [Position] {
        var moves: [Position] = []
        let offsets = [(1,0), (-1,0), (0,1), (0,-1), (1,1), (1,-1), (-1,1), (-1,-1)]
        
        for (dr, dc) in offsets {
            let newRow = pos.row + dr
            let newCol = pos.col + dc
            if isInBounds(row: newRow, col: newCol) {
                if board[newRow][newCol].isEmpty || board[newRow][newCol].piece!.player != player {
                    moves.append(Position(row: newRow, col: newCol))
                }
            }
        }
        
        return moves
    }
    
    func getSlidingMoves(from pos: Position, directions: [(Int, Int)], player: Player) -> [Position] {
        var moves: [Position] = []
        
        for (dr, dc) in directions {
            var newRow = pos.row + dr
            var newCol = pos.col + dc
            
            while isInBounds(row: newRow, col: newCol) {
                if board[newRow][newCol].isEmpty {
                    moves.append(Position(row: newRow, col: newCol))
                } else {
                    if board[newRow][newCol].piece!.player != player {
                        moves.append(Position(row: newRow, col: newCol))
                    }
                    break
                }
                newRow += dr
                newCol += dc
            }
        }
        
        return moves
    }
    
    func isInBounds(row: Int, col: Int) -> Bool {
        return row >= 0 && row < 8 && col >= 0 && col < 8
    }
    
    func findKing(player: Player) -> Position? {
        for row in 0..<8 {
            for col in 0..<8 {
                if let piece = board[row][col].piece, piece.type == .king && piece.player == player {
                    return Position(row: row, col: col)
                }
            }
        }
        return nil
    }
    
    func isCheck(player: Player) -> Bool {
        guard let kingPos = findKing(player: player) else { return false }
        let opponent = player == .white ? Player.black : .white
        
        for row in 0..<8 {
            for col in 0..<8 {
                if let piece = board[row][col].piece, piece.player == opponent {
                    let moves = getRawMoves(from: Position(row: row, col: col), player: opponent)
                    if moves.contains(kingPos) {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    func getRawMoves(from position: Position, player: Player) -> [Position] {
        guard let piece = board[position.row][position.col].piece else { return [] }
        
        switch piece.type {
        case .pawn: return getPawnMoves(from: position, player: player)
        case .rook: return getRookMoves(from: position, player: player)
        case .knight: return getKnightMoves(from: position, player: player)
        case .bishop: return getBishopMoves(from: position, player: player)
        case .queen: return getQueenMoves(from: position, player: player)
        case .king: return getKingMoves(from: position, player: player)
        }
    }
    
    func leavesKingInCheck(from: Position, to: Position, player: Player) -> Bool {
        let originalFrom = board[from.row][from.col]
        let originalTo = board[to.row][to.col]
        
        board[to.row][to.col] = board[from.row][from.col]
        board[from.row][from.col] = .empty
        
        let inCheck = isCheck(player: player)
        
        board[from.row][from.col] = originalFrom
        board[to.row][to.col] = originalTo
        
        return inCheck
    }
    
    func isCheckmate(player: Player) -> Bool {
        if !isCheck(player: player) { return false }
        
        for row in 0..<8 {
            for col in 0..<8 {
                if let piece = board[row][col].piece, piece.player == player {
                    if !getValidMoves(from: Position(row: row, col: col)).isEmpty {
                        return false
                    }
                }
            }
        }
        
        return true
    }
}

// MARK: - Data Models

enum Player {
    case white, black
}

enum PieceType {
    case king, queen, rook, bishop, knight, pawn
}

struct Piece {
    let type: PieceType
    let player: Player
    
    var symbol: String {
        switch (type, player) {
        case (.king, .white): return "♔"
        case (.queen, .white): return "♕"
        case (.rook, .white): return "♖"
        case (.bishop, .white): return "♗"
        case (.knight, .white): return "♘"
        case (.pawn, .white): return "♙"
        case (.king, .black): return "♚"
        case (.queen, .black): return "♛"
        case (.rook, .black): return "♜"
        case (.bishop, .black): return "♝"
        case (.knight, .black): return "♞"
        case (.pawn, .black): return "♟"
        }
    }
}

enum Square {
    case empty
    case piece(PieceType, Player)
    
    var isEmpty: Bool {
        if case .empty = self { return true }
        return false
    }
    
    var piece: Piece? {
        if case .piece(let type, let player) = self {
            return Piece(type: type, player: player)
        }
        return nil
    }
}

struct Position: Hashable {
    let row: Int
    let col: Int
}

struct Move {
    let from: Position
    let to: Position
    let piece: Piece
    let captured: Piece?
    let player: Player
}

#Preview {
    ContentView()
}
