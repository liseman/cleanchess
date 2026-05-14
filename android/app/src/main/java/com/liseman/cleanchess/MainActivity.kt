package com.liseman.cleanchess

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlin.math.abs

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme {
                Surface(modifier = Modifier.fillMaxSize(), color = Color.White) {
                    CleanChessApp()
                }
            }
        }
    }
}

@Composable
fun CleanChessApp() {
    val game = remember { ChessGameState() }

    BoxWithConstraints(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.White)
            .padding(20.dp)
    ) {
        val boardSize = minOf(maxWidth, maxHeight - 150.dp)

        Column(
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Spacer(modifier = Modifier.height(12.dp))
            Text(
                text = game.statusText.uppercase(),
                fontSize = 17.sp,
                fontWeight = FontWeight.Medium,
                letterSpacing = 1.2.sp,
                color = Color.Black,
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(bottom = 18.dp)
            )

            ChessBoard(game = game, boardSize = boardSize)

            Spacer(modifier = Modifier.height(18.dp))

            Row(
                horizontalArrangement = Arrangement.spacedBy(12.dp),
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                MinimalActionButton("New Game", Modifier.weight(1f)) { game.newGame() }
                MinimalActionButton("Undo", Modifier.weight(1f)) { game.undoMove() }
            }
        }
    }
}

@Composable
fun MinimalActionButton(text: String, modifier: Modifier = Modifier, onClick: () -> Unit) {
    Button(
        onClick = onClick,
        modifier = modifier.widthIn(min = 120.dp),
        colors = ButtonDefaults.buttonColors(
            containerColor = Color.Transparent,
            contentColor = Color.Black
        ),
        shape = RoundedCornerShape(999.dp),
        border = androidx.compose.foundation.BorderStroke(1.5.dp, Color.Black),
        elevation = ButtonDefaults.buttonElevation(defaultElevation = 0.dp, pressedElevation = 0.dp)
    ) {
        Text(text.uppercase(), fontWeight = FontWeight.SemiBold, letterSpacing = 1.sp)
    }
}

@Composable
fun ChessBoard(game: ChessGameState, boardSize: androidx.compose.ui.unit.Dp) {
    Column(
        modifier = Modifier
            .size(boardSize)
            .border(1.5.dp, Color.Black)
    ) {
        for (row in 0 until 8) {
            Row(modifier = Modifier.weight(1f)) {
                for (col in 0 until 8) {
                    val squareColor = if ((row + col) % 2 == 0) Color(0xFFF6F6F6) else Color(0xFFD9D9D9)
                    val isSelected = game.selectedPosition == Position(row, col)
                    val piece = game.board[row][col]
                    val isValidMove = game.validMoves.any { it.row == row && it.col == col }
                    val isCapture = isValidMove && piece != null

                    Box(
                        modifier = Modifier
                            .weight(1f)
                            .fillMaxSize()
                            .background(if (isSelected) Color.Black else squareColor)
                            .clickable { game.handleTap(row, col) },
                        contentAlignment = Alignment.Center
                    ) {
                        if (isValidMove && !isCapture) {
                            Canvas(modifier = Modifier.size(14.dp)) {
                                drawCircle(color = Color.Black.copy(alpha = 0.18f))
                            }
                        }

                        if (isCapture) {
                            Canvas(modifier = Modifier.size(42.dp)) {
                                drawCircle(
                                    color = Color.Black.copy(alpha = 0.75f),
                                    style = Stroke(width = 4f)
                                )
                            }
                        }

                        piece?.let {
                            MinimalPiece(piece = it, inverted = isSelected)
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun MinimalPiece(piece: Piece, inverted: Boolean) {
    Text(
        text = piece.glyph,
        color = if (inverted) Color.White else Color.Black,
        fontSize = 34.sp,
        fontFamily = FontFamily.Serif,
        textAlign = TextAlign.Center,
        modifier = Modifier.fillMaxWidth()
    )
}

enum class Player { WHITE, BLACK }

enum class PieceType { KING, QUEEN, ROOK, BISHOP, KNIGHT, PAWN }

data class Piece(val type: PieceType, val player: Player) {
    val glyph: String
        get() = when (type to player) {
            PieceType.KING to Player.WHITE -> "♔"
            PieceType.QUEEN to Player.WHITE -> "♕"
            PieceType.ROOK to Player.WHITE -> "♖"
            PieceType.BISHOP to Player.WHITE -> "♗"
            PieceType.KNIGHT to Player.WHITE -> "♘"
            PieceType.PAWN to Player.WHITE -> "♙"
            PieceType.KING to Player.BLACK -> "♚"
            PieceType.QUEEN to Player.BLACK -> "♛"
            PieceType.ROOK to Player.BLACK -> "♜"
            PieceType.BISHOP to Player.BLACK -> "♝"
            PieceType.KNIGHT to Player.BLACK -> "♞"
            PieceType.PAWN to Player.BLACK -> "♙"
        }
}

data class Position(val row: Int, val col: Int)

data class CastlingRights(
    var whiteKingSide: Boolean = true,
    var whiteQueenSide: Boolean = true,
    var blackKingSide: Boolean = true,
    var blackQueenSide: Boolean = true
)

data class Move(
    val from: Position,
    val to: Position,
    val piece: Piece,
    val captured: Piece?,
    val player: Player,
    val rookFrom: Position? = null,
    val rookTo: Position? = null,
    val previousCastlingRights: CastlingRights = CastlingRights()
)

class ChessGameState {
    val board = Array(8) { arrayOfNulls<Piece>(8) }
    private val moveHistory = mutableStateListOf<Move>()

    var selectedPosition by mutableStateOf<Position?>(null)
    var validMoves by mutableStateOf<List<Position>>(emptyList())
    var currentPlayer by mutableStateOf(Player.WHITE)
    var statusText by mutableStateOf("White to move")
    private var castlingRights = CastlingRights()

    init {
        newGame()
    }

    fun newGame() {
        val back = arrayOf(
            PieceType.ROOK,
            PieceType.KNIGHT,
            PieceType.BISHOP,
            PieceType.QUEEN,
            PieceType.KING,
            PieceType.BISHOP,
            PieceType.KNIGHT,
            PieceType.ROOK
        )
        for (r in 0 until 8) for (c in 0 until 8) board[r][c] = null
        for (c in 0 until 8) {
            board[0][c] = Piece(back[c], Player.BLACK)
            board[1][c] = Piece(PieceType.PAWN, Player.BLACK)
            board[6][c] = Piece(PieceType.PAWN, Player.WHITE)
            board[7][c] = Piece(back[c], Player.WHITE)
        }
        currentPlayer = Player.WHITE
        selectedPosition = null
        validMoves = emptyList()
        moveHistory.clear()
        castlingRights = CastlingRights()
        updateStatus()
    }

    fun handleTap(row: Int, col: Int) {
        val tapped = board[row][col]
        val selected = selectedPosition
        if (selected != null) {
            val target = Position(row, col)
            if (validMoves.contains(target)) {
                makeMove(selected, target)
                selectedPosition = null
                validMoves = emptyList()
                statusText = when {
                    isCheckmate(currentPlayer) -> if (currentPlayer == Player.WHITE) "Black wins!" else "White wins!"
                    isCheck(currentPlayer) -> if (currentPlayer == Player.WHITE) "White in check" else "Black in check"
                    else -> defaultStatus(currentPlayer)
                }
            } else if (tapped?.player == currentPlayer) {
                selectedPosition = target
                validMoves = getValidMoves(target)
            } else {
                selectedPosition = null
                validMoves = emptyList()
            }
        } else if (tapped?.player == currentPlayer) {
            val pos = Position(row, col)
            selectedPosition = pos
            validMoves = getValidMoves(pos)
        }
    }

    fun undoMove() {
        val last = moveHistory.removeLastOrNull() ?: return
        board[last.from.row][last.from.col] = last.piece
        board[last.to.row][last.to.col] = last.captured
        if (last.rookFrom != null && last.rookTo != null) {
            board[last.rookFrom.row][last.rookFrom.col] = board[last.rookTo.row][last.rookTo.col]
            board[last.rookTo.row][last.rookTo.col] = null
        }
        castlingRights = last.previousCastlingRights.copy()
        currentPlayer = last.player
        selectedPosition = null
        validMoves = emptyList()
        updateStatus()
    }

    private fun updateStatus() {
        statusText = defaultStatus(currentPlayer)
    }

    private fun defaultStatus(player: Player): String = if (player == Player.WHITE) "White to move" else "Black to move"

    private fun makeMove(from: Position, to: Position) {
        val piece = board[from.row][from.col] ?: return
        val captured = board[to.row][to.col]
        val previousRights = castlingRights.copy()
        var rookFrom: Position? = null
        var rookTo: Position? = null

        board[to.row][to.col] = piece
        board[from.row][from.col] = null

        if (piece.type == PieceType.KING && abs(to.col - from.col) == 2) {
            val sourceCol = if (to.col > from.col) 7 else 0
            val destinationCol = if (to.col > from.col) to.col - 1 else to.col + 1
            rookFrom = Position(from.row, sourceCol)
            rookTo = Position(from.row, destinationCol)
            board[rookTo.row][rookTo.col] = board[rookFrom.row][rookFrom.col]
            board[rookFrom.row][rookFrom.col] = null
        }

        updateCastlingRights(piece, from, captured, to)
        moveHistory += Move(from, to, piece, captured, currentPlayer, rookFrom, rookTo, previousRights)

        if (piece.type == PieceType.PAWN && ((piece.player == Player.WHITE && to.row == 0) || (piece.player == Player.BLACK && to.row == 7))) {
            board[to.row][to.col] = Piece(PieceType.QUEEN, piece.player)
        }

        currentPlayer = if (currentPlayer == Player.WHITE) Player.BLACK else Player.WHITE
    }

    private fun getValidMoves(from: Position): List<Position> {
        val piece = board[from.row][from.col] ?: return emptyList()
        val raw = when (piece.type) {
            PieceType.PAWN -> getPawnMoves(from, piece.player)
            PieceType.ROOK -> getSlidingMoves(from, piece.player, listOf(1 to 0, -1 to 0, 0 to 1, 0 to -1))
            PieceType.KNIGHT -> getKnightMoves(from, piece.player)
            PieceType.BISHOP -> getSlidingMoves(from, piece.player, listOf(1 to 1, 1 to -1, -1 to 1, -1 to -1))
            PieceType.QUEEN -> getSlidingMoves(from, piece.player, listOf(1 to 0, -1 to 0, 0 to 1, 0 to -1, 1 to 1, 1 to -1, -1 to 1, -1 to -1))
            PieceType.KING -> getKingMoves(from, piece.player, includeCastling = true)
        }
        return raw.filterNot { leavesKingInCheck(from, it, piece.player) }
    }

    private fun getPawnMoves(from: Position, player: Player): List<Position> {
        val moves = mutableListOf<Position>()
        val direction = if (player == Player.WHITE) -1 else 1
        val startRow = if (player == Player.WHITE) 6 else 1
        val one = Position(from.row + direction, from.col)
        if (isInBounds(one) && board[one.row][one.col] == null) {
            moves += one
            val two = Position(from.row + 2 * direction, from.col)
            if (from.row == startRow && board[two.row][two.col] == null) moves += two
        }
        for (dc in listOf(-1, 1)) {
            val capture = Position(from.row + direction, from.col + dc)
            if (isInBounds(capture)) {
                val target = board[capture.row][capture.col]
                if (target != null && target.player != player) moves += capture
            }
        }
        return moves
    }

    private fun getPawnAttackMoves(from: Position, player: Player): List<Position> {
        val direction = if (player == Player.WHITE) -1 else 1
        return listOf(-1, 1).mapNotNull { dc ->
            Position(from.row + direction, from.col + dc).takeIf(::isInBounds)
        }
    }

    private fun getKnightMoves(from: Position, player: Player): List<Position> {
        val offsets = listOf(2 to 1, 2 to -1, -2 to 1, -2 to -1, 1 to 2, 1 to -2, -1 to 2, -1 to -2)
        return offsets.mapNotNull { (dr, dc) ->
            val pos = Position(from.row + dr, from.col + dc)
            if (!isInBounds(pos)) return@mapNotNull null
            val target = board[pos.row][pos.col]
            if (target == null || target.player != player) pos else null
        }
    }

    private fun getKingMoves(from: Position, player: Player, includeCastling: Boolean): List<Position> {
        val moves = mutableListOf<Position>()
        val offsets = listOf(1 to 0, -1 to 0, 0 to 1, 0 to -1, 1 to 1, 1 to -1, -1 to 1, -1 to -1)
        for ((dr, dc) in offsets) {
            val pos = Position(from.row + dr, from.col + dc)
            if (!isInBounds(pos)) continue
            val target = board[pos.row][pos.col]
            if (target == null || target.player != player) moves += pos
        }
        if (includeCastling) {
            if (canCastle(from, player, true)) moves += Position(from.row, from.col + 2)
            if (canCastle(from, player, false)) moves += Position(from.row, from.col - 2)
        }
        return moves
    }

    private fun canCastle(from: Position, player: Player, kingSide: Boolean): Boolean {
        if (from.col != 4) return false
        val homeRow = if (player == Player.WHITE) 7 else 0
        if (from.row != homeRow) return false

        val rightAvailable = if (player == Player.WHITE) {
            if (kingSide) castlingRights.whiteKingSide else castlingRights.whiteQueenSide
        } else {
            if (kingSide) castlingRights.blackKingSide else castlingRights.blackQueenSide
        }
        if (!rightAvailable) return false

        val rookCol = if (kingSide) 7 else 0
        val rook = board[homeRow][rookCol] ?: return false
        if (rook.type != PieceType.ROOK || rook.player != player) return false

        val emptyCols = if (kingSide) listOf(5, 6) else listOf(1, 2, 3)
        if (emptyCols.any { board[homeRow][it] != null }) return false

        if (isCheck(player)) return false
        val attacker = if (player == Player.WHITE) Player.BLACK else Player.WHITE
        val transitCol = if (kingSide) 5 else 3
        val destinationCol = if (kingSide) 6 else 2
        if (isSquareAttacked(Position(homeRow, transitCol), attacker)) return false
        if (isSquareAttacked(Position(homeRow, destinationCol), attacker)) return false

        return true
    }

    private fun getSlidingMoves(from: Position, player: Player, directions: List<Pair<Int, Int>>): List<Position> {
        val moves = mutableListOf<Position>()
        for ((dr, dc) in directions) {
            var row = from.row + dr
            var col = from.col + dc
            while (isInBounds(Position(row, col))) {
                val target = board[row][col]
                if (target == null) {
                    moves += Position(row, col)
                } else {
                    if (target.player != player) moves += Position(row, col)
                    break
                }
                row += dr
                col += dc
            }
        }
        return moves
    }

    private fun findKing(player: Player): Position? {
        for (r in 0 until 8) for (c in 0 until 8) {
            val piece = board[r][c]
            if (piece?.type == PieceType.KING && piece.player == player) return Position(r, c)
        }
        return null
    }

    private fun isCheck(player: Player): Boolean {
        val king = findKing(player) ?: return false
        val attacker = if (player == Player.WHITE) Player.BLACK else Player.WHITE
        return isSquareAttacked(king, attacker)
    }

    private fun isSquareAttacked(target: Position, attacker: Player): Boolean {
        for (r in 0 until 8) for (c in 0 until 8) {
            val piece = board[r][c] ?: continue
            if (piece.player != attacker) continue
            val pos = Position(r, c)
            val moves = when (piece.type) {
                PieceType.PAWN -> getPawnAttackMoves(pos, attacker)
                PieceType.ROOK -> getSlidingMoves(pos, attacker, listOf(1 to 0, -1 to 0, 0 to 1, 0 to -1))
                PieceType.KNIGHT -> getKnightMoves(pos, attacker)
                PieceType.BISHOP -> getSlidingMoves(pos, attacker, listOf(1 to 1, 1 to -1, -1 to 1, -1 to -1))
                PieceType.QUEEN -> getSlidingMoves(pos, attacker, listOf(1 to 0, -1 to 0, 0 to 1, 0 to -1, 1 to 1, 1 to -1, -1 to 1, -1 to -1))
                PieceType.KING -> getKingMoves(pos, attacker, includeCastling = false)
            }
            if (moves.any { it == target }) return true
        }
        return false
    }

    private fun leavesKingInCheck(from: Position, to: Position, player: Player): Boolean {
        val moving = board[from.row][from.col]
        val captured = board[to.row][to.col]
        board[to.row][to.col] = moving
        board[from.row][from.col] = null
        val result = isCheck(player)
        board[from.row][from.col] = moving
        board[to.row][to.col] = captured
        return result
    }

    private fun isCheckmate(player: Player): Boolean {
        if (!isCheck(player)) return false
        for (r in 0 until 8) for (c in 0 until 8) {
            val piece = board[r][c] ?: continue
            if (piece.player == player && getValidMoves(Position(r, c)).isNotEmpty()) return false
        }
        return true
    }

    private fun updateCastlingRights(piece: Piece, from: Position, captured: Piece?, to: Position) {
        when (piece.type) {
            PieceType.KING -> if (piece.player == Player.WHITE) {
                castlingRights.whiteKingSide = false
                castlingRights.whiteQueenSide = false
            } else {
                castlingRights.blackKingSide = false
                castlingRights.blackQueenSide = false
            }
            PieceType.ROOK -> if (piece.player == Player.WHITE) {
                if (from.row == 7 && from.col == 0) castlingRights.whiteQueenSide = false
                if (from.row == 7 && from.col == 7) castlingRights.whiteKingSide = false
            } else {
                if (from.row == 0 && from.col == 0) castlingRights.blackQueenSide = false
                if (from.row == 0 && from.col == 7) castlingRights.blackKingSide = false
            }
            else -> Unit
        }

        if (captured?.type == PieceType.ROOK) {
            if (captured.player == Player.WHITE) {
                if (to.row == 7 && to.col == 0) castlingRights.whiteQueenSide = false
                if (to.row == 7 && to.col == 7) castlingRights.whiteKingSide = false
            } else {
                if (to.row == 0 && to.col == 0) castlingRights.blackQueenSide = false
                if (to.row == 0 && to.col == 7) castlingRights.blackKingSide = false
            }
        }
    }

    private fun isInBounds(pos: Position): Boolean = pos.row in 0..7 && pos.col in 0..7
}

@Preview(showBackground = true)
@Composable
fun CleanChessPreview() {
    MaterialTheme {
        CleanChessApp()
    }
}
