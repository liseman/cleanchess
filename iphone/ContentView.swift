import SwiftUI

struct ContentView: View {
    @StateObject private var game = ChessGame()
    
    var body: some View {
        GeometryReader { geometry in
            let horizontalPadding: CGFloat = 20
            let verticalPadding: CGFloat = 24
            let reservedHeight: CGFloat = 150
            let boardSize = min(
                geometry.size.width - horizontalPadding * 2,
                geometry.size.height - reservedHeight
            )

            VStack(spacing: 18) {
                Text(game.statusText.uppercased())
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .tracking(1.2)
                    .foregroundColor(.black)
                    .padding(.top, 12)
                
                ChessBoardView(game: game)
                    .frame(width: max(boardSize, 0), height: max(boardSize, 0))
                
                HStack(spacing: 12) {
                    MinimalButton(title: "New Game") { game.newGame() }
                    MinimalButton(title: "Undo") { game.undoMove() }
                }
                .padding(.bottom, 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(Color.white)
        }
    }
}

struct MinimalButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title.uppercased())
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .tracking(1)
                .foregroundColor(.black)
                .frame(minWidth: 120)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .overlay(
                    Capsule()
                        .stroke(Color.black, lineWidth: 1.5)
                )
        }
        .buttonStyle(.plain)
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
                            .fill((row + col) % 2 == 0 ? Color(red: 0.965, green: 0.965, blue: 0.965) : Color(red: 0.85, green: 0.85, blue: 0.85))
                            .frame(width: squareSize, height: squareSize)
                            .position(x: CGFloat(col) * squareSize + squareSize/2,
                                    y: CGFloat(row) * squareSize + squareSize/2)
                    }
                }
                
                if let selected = game.selectedSquare {
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: squareSize, height: squareSize)
                        .position(x: CGFloat(selected.col) * squareSize + squareSize/2,
                                y: CGFloat(selected.row) * squareSize + squareSize/2)
                }
                
                ForEach(game.validMoves, id: \.self) { move in
                    Circle()
                        .fill(game.board[move.row][move.col].isEmpty ? Color.black.opacity(0.18) : Color.clear)
                        .frame(width: squareSize * 0.2, height: squareSize * 0.2)
                        .position(x: CGFloat(move.col) * squareSize + squareSize/2,
                                y: CGFloat(move.row) * squareSize + squareSize/2)
                    
                    Circle()
                        .stroke(Color.black.opacity(0.75), lineWidth: 2)
                        .frame(width: squareSize * 0.78, height: squareSize * 0.78)
                        .position(x: CGFloat(move.col) * squareSize + squareSize/2,
                                y: CGFloat(move.row) * squareSize + squareSize/2)
                        .opacity(game.board[move.row][move.col].isEmpty ? 0 : 1)
                }
                
                ForEach(0..<8) { row in
                    ForEach(0..<8) { col in
                        if let piece = game.board[row][col].piece {
                            MinimalPieceView(piece: piece, inverted: game.selectedSquare == Position(row: row, col: col))
                                .frame(width: squareSize * 0.64, height: squareSize * 0.64)
                                .position(x: CGFloat(col) * squareSize + squareSize/2,
                                        y: CGFloat(row) * squareSize + squareSize/2)
                        }
                    }
                }
                
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
            .overlay(
                Rectangle()
                    .stroke(Color.black, lineWidth: 1.5)
            )
        }
    }
}

struct MinimalPieceView: View {
    let piece: Piece
    let inverted: Bool

    var body: some View {
        if piece.type == .pawn {
            PawnPieceView(isWhite: piece.player == .white, inverted: inverted)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            Text(piece.glyph)
                .font(.system(size: 34, weight: .regular, design: .serif))
                .minimumScaleFactor(0.4)
                .lineLimit(1)
                .foregroundColor(inverted ? .white : .black)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct PawnPieceView: View {
    let isWhite: Bool
    let inverted: Bool

    var body: some View {
        let fill = inverted ? Color.white : (isWhite ? Color.white : Color.black)
        let stroke = inverted ? Color.white : Color.black

        return GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                Circle()
                    .fill(fill)
                    .overlay(Circle().stroke(stroke, lineWidth: 1.5))
                    .frame(width: w * 0.28, height: h * 0.28)
                    .offset(y: -h * 0.18)
                PawnBodyShape()
                    .fill(fill)
                    .overlay(PawnBodyShape().stroke(stroke, lineWidth: 1.5))
                    .frame(width: w * 0.38, height: h * 0.32)
                    .offset(y: h * 0.02)
                RoundedRectangle(cornerRadius: h * 0.05)
                    .fill(fill)
                    .overlay(RoundedRectangle(cornerRadius: h * 0.05).stroke(stroke, lineWidth: 1.5))
                    .frame(width: w * 0.46, height: h * 0.1)
                    .offset(y: h * 0.3)
            }
        }
    }
}

struct PawnBodyShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.2, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.minY), control: CGPoint(x: rect.minX + rect.width * 0.28, y: rect.minY + rect.height * 0.18))
        path.addQuadCurve(to: CGPoint(x: rect.maxX - rect.width * 0.2, y: rect.maxY), control: CGPoint(x: rect.maxX - rect.width * 0.28, y: rect.minY + rect.height * 0.18))
        path.closeSubpath()
        return path
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
    private var castlingRights = CastlingRights()
    
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
        castlingRights = CastlingRights()
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
        let previousRights = castlingRights
        var rookFrom: Position?
        var rookTo: Position?
        
        board[to.row][to.col] = .piece(piece.type, piece.player)
        board[from.row][from.col] = .empty

        if piece.type == .king && abs(to.col - from.col) == 2 {
            let sourceCol = to.col > from.col ? 7 : 0
            let destinationCol = to.col > from.col ? to.col - 1 : to.col + 1
            rookFrom = Position(row: from.row, col: sourceCol)
            rookTo = Position(row: from.row, col: destinationCol)
            board[rookTo!.row][rookTo!.col] = board[rookFrom!.row][rookFrom!.col]
            board[rookFrom!.row][rookFrom!.col] = .empty
        }

        updateCastlingRights(moving: piece, from: from, captured: captured, to: to)
        moveHistory.append(Move(from: from, to: to, piece: piece, captured: captured, player: currentPlayer, rookFrom: rookFrom, rookTo: rookTo, previousCastlingRights: previousRights))
        
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
        if let rookFrom = lastMove.rookFrom, let rookTo = lastMove.rookTo {
            board[rookFrom.row][rookFrom.col] = board[rookTo.row][rookTo.col]
            board[rookTo.row][rookTo.col] = .empty
        }
        castlingRights = lastMove.previousCastlingRights
        
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
            moves = getKingMoves(from: position, player: piece.player, includeCastling: true)
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
    
    func getKingMoves(from pos: Position, player: Player, includeCastling: Bool = true) -> [Position] {
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

        if includeCastling {
            if canCastle(from: pos, player: player, kingSide: true) {
                moves.append(Position(row: pos.row, col: pos.col + 2))
            }
            if canCastle(from: pos, player: player, kingSide: false) {
                moves.append(Position(row: pos.row, col: pos.col - 2))
            }
        }
        
        return moves
    }

    func canCastle(from pos: Position, player: Player, kingSide: Bool) -> Bool {
        guard pos.col == 4 else { return false }
        let homeRow = player == .white ? 7 : 0
        guard pos.row == homeRow else { return false }

        let rightAvailable: Bool
        if player == .white {
            rightAvailable = kingSide ? castlingRights.whiteKingSide : castlingRights.whiteQueenSide
        } else {
            rightAvailable = kingSide ? castlingRights.blackKingSide : castlingRights.blackQueenSide
        }
        guard rightAvailable else { return false }

        let rookCol = kingSide ? 7 : 0
        let emptyCols = kingSide ? [5, 6] : [1, 2, 3]
        let transitCol = kingSide ? 5 : 3
        let destinationCol = kingSide ? 6 : 2

        guard let rook = board[homeRow][rookCol].piece, rook.type == .rook, rook.player == player else {
            return false
        }
        guard emptyCols.allSatisfy({ board[homeRow][$0].isEmpty }) else { return false }
        guard !isCheck(player: player) else { return false }
        guard !leavesKingInCheck(from: pos, to: Position(row: homeRow, col: transitCol), player: player) else { return false }
        guard !leavesKingInCheck(from: pos, to: Position(row: homeRow, col: destinationCol), player: player) else { return false }

        return true
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
        case .pawn: return getPawnAttackMoves(from: position, player: player)
        case .rook: return getRookMoves(from: position, player: player)
        case .knight: return getKnightMoves(from: position, player: player)
        case .bishop: return getBishopMoves(from: position, player: player)
        case .queen: return getQueenMoves(from: position, player: player)
        case .king: return getKingMoves(from: position, player: player, includeCastling: false)
        }
    }

    func getPawnAttackMoves(from pos: Position, player: Player) -> [Position] {
        let direction = player == .white ? -1 : 1
        return [-1, 1].compactMap { dc in
            let newRow = pos.row + direction
            let newCol = pos.col + dc
            guard isInBounds(row: newRow, col: newCol) else { return nil }
            return Position(row: newRow, col: newCol)
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

    func updateCastlingRights(moving piece: Piece, from: Position, captured: Piece?, to: Position) {
        switch piece.type {
        case .king:
            if piece.player == .white {
                castlingRights.whiteKingSide = false
                castlingRights.whiteQueenSide = false
            } else {
                castlingRights.blackKingSide = false
                castlingRights.blackQueenSide = false
            }
        case .rook:
            if piece.player == .white {
                if from.row == 7 && from.col == 0 { castlingRights.whiteQueenSide = false }
                if from.row == 7 && from.col == 7 { castlingRights.whiteKingSide = false }
            } else {
                if from.row == 0 && from.col == 0 { castlingRights.blackQueenSide = false }
                if from.row == 0 && from.col == 7 { castlingRights.blackKingSide = false }
            }
        default:
            break
        }

        if let captured = captured, captured.type == .rook {
            if captured.player == .white {
                if to.row == 7 && to.col == 0 { castlingRights.whiteQueenSide = false }
                if to.row == 7 && to.col == 7 { castlingRights.whiteKingSide = false }
            } else {
                if to.row == 0 && to.col == 0 { castlingRights.blackQueenSide = false }
                if to.row == 0 && to.col == 7 { castlingRights.blackKingSide = false }
            }
        }
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
    
    var glyph: String {
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
        case (.pawn, .black): return "♙"
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
    let rookFrom: Position?
    let rookTo: Position?
    let previousCastlingRights: CastlingRights
}

struct CastlingRights {
    var whiteKingSide = true
    var whiteQueenSide = true
    var blackKingSide = true
    var blackQueenSide = true
}

#Preview {
    ContentView()
}
